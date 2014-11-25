#!/bin/bash
# A really hacked together script - I don't even understand it anymore
# Rm9yayAhQm9tYnpaeUNBawo=

help() {
	cat <<'END'
	-q "quit at" n keypresses
	-l "length per typed character" default: 4
	-f "fail at hacking"
	-s "succeed at hacking"
	-g "be green"
	-h "show this help..."

	Example: -l 20 -q 10 -f -g
		each keypress will output 20 characters
		this continues 10 times (10 keypresses before it ends)
		once it ends, it will fail
		all the text is green

	Also note that pressing ` will skip you straight to "hacking" (or failing)
	This code is quite messy, I might consider a cleanup later on
	(Try to use sane values for -q and -l)
END
exit
}
while getopts "q:l:fshg" opt "$@"; do
	case "$opt" in
		q)
		 stopat=$OPTARG
		 ;;
		l)
		 len=$OPTARG
		 ;;
		f)
		 fail=1
		 ;;
		s)
		 hack=1
		 ;;
		g)
		 echo -e "\033[00;32m"
		 ;;
		h)
		 help
		 ;;
		*)
		 help
		 ;;
	esac
done

hack() {
	for i in `seq 0 100`; do echo $i; sleep 0.05; done | whiptail --title "Hacking..." --clear --gauge "   Hacking in progress, please wait" 20 70 0
	whiptail --title "Hacking..." --msgbox '   Success.' 20 70
	whiptail --title "Hacking..." --passwordbox "Enter Password?" 20 70
	clear
	echo -en '\033[00;0mroot# '
	sleep 5
	echo ""
	exit
}
fail() {
	whiptail --title "Hacking..." --msgbox '   FAILED !!' 20 70
	echo -e '\033[00;0m' # Just in case your $PS1 doesn't set colour
	clear
	exit
}
end() {
	if [ $fail ]; then
		fail
	else
		hack
	fi
}
text=`cat << 'ENDOFSTUFF'
/* init to 2 - one for init_task, one to ensure it is never freed */
struct group_info init_groups = { .usage = ATOMIC_INIT(2) };

struct group_info *groups_alloc(int gidsetsize)
{
	struct group_info *group_info;
	int nblocks;
	int i;

	nblocks = (gidsetsize + NGROUPS_PER_BLOCK - 1) / NGROUPS_PER_BLOCK;
	/* Make sure we always allocate at least one indirect block pointer */
	nblocks = nblocks ? : 1;
	group_info = kmalloc(sizeof(*group_info) + nblocks*sizeof(gid_t *), GFP_USER);
	if (!group_info)
		return NULL;
	group_info->ngroups = gidsetsize;
	group_info->nblocks = nblocks;
	atomic_set(&group_info->usage, 1);

	if (gidsetsize <= NGROUPS_SMALL)
		group_info->blocks[0] = group_info->small_block;
	else {
		for (i = 0; i < nblocks; i++) {
			gid_t *b;
			b = (void *)__get_free_page(GFP_USER);
			if (!b)
				goto out_undo_partial_alloc;
			group_info->blocks[i] = b;
		}
	}
	return group_info;

out_undo_partial_alloc:
	while (--i >= 0) {
		free_page((unsigned long)group_info->blocks[i]);
	}
	kfree(group_info);
	return NULL;
}

EXPORT_SYMBOL(groups_alloc);

void groups_free(struct group_info *group_info)
{
	if (group_info->blocks[0] != group_info->small_block) {
		int i;
		for (i = 0; i < group_info->nblocks; i++)
			free_page((unsigned long)group_info->blocks[i]);
	}
	kfree(group_info);
}

EXPORT_SYMBOL(groups_free);

/* export the group_info to a user-space array */
static int groups_to_user(gid_t __user *grouplist,
			  const struct group_info *group_info)
{
	int i;
	unsigned int count = group_info->ngroups;

	for (i = 0; i < group_info->nblocks; i++) {
		unsigned int cp_count = min(NGROUPS_PER_BLOCK, count);
		unsigned int len = cp_count * sizeof(*grouplist);

		if (copy_to_user(grouplist, group_info->blocks[i], len))
			return -EFAULT;

		grouplist += NGROUPS_PER_BLOCK;
		count -= cp_count;
	}
	return 0;
}

/* fill a group_info from a user-space array - it must be allocated already */
static int groups_from_user(struct group_info *group_info,
    gid_t __user *grouplist)
{
	int i;
	unsigned int count = group_info->ngroups;

	for (i = 0; i < group_info->nblocks; i++) {
		unsigned int cp_count = min(NGROUPS_PER_BLOCK, count);
		unsigned int len = cp_count * sizeof(*grouplist);

		if (copy_from_user(group_info->blocks[i], grouplist, len))
			return -EFAULT;

		grouplist += NGROUPS_PER_BLOCK;
		count -= cp_count;
	}
	return 0;
}

/* a simple Shell sort */
static void groups_sort(struct group_info *group_info)
{
	int base, max, stride;
	int gidsetsize = group_info->ngroups;

	for (stride = 1; stride < gidsetsize; stride = 3 * stride + 1)
		; /* nothing */
	stride /= 3;

	while (stride) {
		max = gidsetsize - stride;
		for (base = 0; base < max; base++) {
			int left = base;
			int right = left + stride;
			gid_t tmp = GROUP_AT(group_info, right);

			while (left >= 0 && GROUP_AT(group_info, left) > tmp) {
				GROUP_AT(group_info, right) =
				    GROUP_AT(group_info, left);
				right = left;
				left -= stride;
			}
			GROUP_AT(group_info, right) = tmp;
		}
		stride /= 3;
	}
}

/* a simple bsearch */
int groups_search(const struct group_info *group_info, gid_t grp)
{
	unsigned int left, right;

	if (!group_info)
		return 0;

	left = 0;
	right = group_info->ngroups;
	while (left < right) {
		unsigned int mid = (left+right)/2;
		if (grp > GROUP_AT(group_info, mid))
			left = mid + 1;
		else if (grp < GROUP_AT(group_info, mid))
			right = mid;
		else
			return 1;
	}
	return 0;
}

/**
 * set_groups - Change a group subscription in a set of credentials
 * @new: The newly prepared set of credentials to alter
 * @group_info: The group list to install
 *
 * Validate a group subscription and, if valid, insert it into a set
 * of credentials.
 */
int set_groups(struct cred *new, struct group_info *group_info)
{
	put_group_info(new->group_info);
	groups_sort(group_info);
	get_group_info(group_info);
	new->group_info = group_info;
	return 0;
}

EXPORT_SYMBOL(set_groups);

/**
 * set_current_groups - Change current's group subscription
 * @group_info: The group list to impose
 *
 * Validate a group subscription and, if valid, impose it upon current's task
 * security record.
 */
int set_current_groups(struct group_info *group_info)
{
	struct cred *new;
	int ret;

	new = prepare_creds();
	if (!new)
		return -ENOMEM;

	ret = set_groups(new, group_info);
	if (ret < 0) {
		abort_creds(new);
		return ret;
	}

	return commit_creds(new);
}

EXPORT_SYMBOL(set_current_groups);

SYSCALL_DEFINE2(getgroups, int, gidsetsize, gid_t __user *, grouplist)
{
	const struct cred *cred = current_cred();
	int i;

	if (gidsetsize < 0)
		return -EINVAL;

	/* no need to grab task_lock here; it cannot change */
	i = cred->group_info->ngroups;
	if (gidsetsize) {
		if (i > gidsetsize) {
			i = -EINVAL;
			goto out;
		}
		if (groups_to_user(grouplist, cred->group_info)) {
			i = -EFAULT;
			goto out;
		}
	}
out:
	return i;
}

/*
 *	SMP: Our groups are copy-on-write. We can set them safely
 *	without another task interfering.
 */

SYSCALL_DEFINE2(setgroups, int, gidsetsize, gid_t __user *, grouplist)
{
	struct group_info *group_info;
	int retval;

	if (!nsown_capable(CAP_SETGID))
		return -EPERM;
	if ((unsigned)gidsetsize > NGROUPS_MAX)
		return -EINVAL;

	group_info = groups_alloc(gidsetsize);
	if (!group_info)
		return -ENOMEM;
	retval = groups_from_user(group_info, grouplist);
	if (retval) {
		put_group_info(group_info);
		return retval;
	}

	retval = set_current_groups(group_info);
	put_group_info(group_info);

	return retval;
}

/*
 * Check whether we\'re fsgid/egid or in the supplemental group..
 */
int in_group_p(gid_t grp)
{
	const struct cred *cred = current_cred();
	int retval = 1;

	if (grp != cred->fsgid)
		retval = groups_search(cred->group_info, grp);
	return retval;
}

EXPORT_SYMBOL(in_group_p);

int in_egroup_p(gid_t grp)
{
	const struct cred *cred = current_cred();
	int retval = 1;

	if (grp != cred->egid)
		retval = groups_search(cred->group_info, grp);
	return retval;
}

EXPORT_SYMBOL(in_egroup_p);
ENDOFSTUFF`


start=0
length=$((`echo "$text" | wc -c` / ${len:=4}))
for (( go = 1 ; go <= ${stopat:=length} ; go++ ))
        do echo -n "${text:$start:${len:=4}}"
        (( start = start + ${len:=4} ))
        read -sn 1 inpoot
	if [ "$inpoot" == '`' ]; then
		end
	else
		continue
	fi
done
end
exit 0
