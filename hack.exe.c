/*	I SAID I WOULD CLEAN THIS UP BEFORE I PUBLISHED IT BUT THEN DIDN'T

	DISCLAIMER: THIS IS HORRIBLY WRITTEN.
	I AM AWARE HOW DUMB A LOT OF THE PARTS OF THIS PROGRAM ARE
	FEEL FREE TO CRITISIZE ANYWAY.

	REMEMBER TO COMPILE WITH -lpthread !


	HACK.EXE[.C]
	NOW WITH 100% MORE 1337 AND 0% MORE WINDOWS COMPATABILITY.
	SUGGESTIONS AND EDITS MAY BE ACCEPTED BASED ON A COMPLEX FOMULA
	INVOLVING HOW GOOD I THINK THE CHANGES MIGHT BE AND THE EFFORT
	NEEDED TO DO THEM, AS WELL AS HOW LAZY I AM AT THE TIME.

	MY CAPS LOCK IS BROKEN BUT I MUST POST THIS.
*/

#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <unistd.h>

#include <netdb.h>
#include <arpa/inet.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>

#include <pthread.h>

#define VTCGRN          "[\033[00;32m" // Default colour, green
#define VTCRED		"[\033[00;31m" // Failure colour, red
#define VTCRST          "\033[00;0m]"  // Reset to default colour
#define SLPTIME         20000          // Sleep time, microsecons
#define GETIPV6         1             // Resolve ipv6? (0 = none, >0 = max)
#define GETIPV4         1             // Resolve ipv4? (0 = none, >0 = max)
#define SPOOPYASCII     printf("\
          .                                                      .\n\
	.n                   .                 .                  n.\n\
  .   .dP                  dP                   9b                 9b.    .\n\
 4    qXb         .       dX                     Xb       .        dXp     t\n\
dX.    9Xb      .dXb    __                         __    dXb.     dXP     .Xb\n\
9XXb._       _.dXXXXb dXXXXbo.                 .odXXXXb dXXXXb._       _.dXXP\n\
 9XXXXXXXXXXXXXXXXXXXVXXXXXXXXOo.           .oOXXXXXXXXVXXXXXXXXXXXXXXXXXXXP\n\
  `9XXXXXXXXXXXXXXXXXXXXX'~   ~`OOO8b   d8OOO'~   ~`XXXXXXXXXXXXXXXXXXXXXP'\n\
    `9XXXXXXXXXXXP' `9XX'   DIE    `98v8P'  HUMAN   `XXP' `9XXXXXXXXXXXP'\n\
	~~~~~~~       9X.          .db|db.          .XP       ~~~~~~~\n\
			)b.  .dbo.dP'`v'`9b.odb.  .dX(\n\
		      ,dXXXXXXXXXXXb     dXXXXXXXXXXXb.\n\
		     dXXXXXXXXXXXP'   .   `9XXXXXXXXXXXb\n\
		    dXXXXXXXXXXXXb   d|b   dXXXXXXXXXXXXb\n\
		    9XXb'   `XXXXXb.dX|Xb.dXXXXX'   `dXXP\n\
		     `'      9XXXXXX(   )XXXXXXP      `'\n\
			      XXXX X.`v'.X XXXX\n\
			      XP^X'`b   d'`X^XX\n\
			      X. 9  `   '  P )X\n\
			      `b  `       '  d'\n\
			       `             '\n\n\
");

pthread_t thread;
enum { FAIL, SUCCESS };


char dotchar = '.';
//global variable easier than creating structs for just one thread.

void dot(int i)
{
	while(i--) {
		putchar(dotchar);
		fflush(stdout);
		usleep(SLPTIME);
	}

}

void printsuccess(int success)
{
	
	success ? printf(VTCGRN"COMPLETE"VTCRST): printf(VTCRED" FAILED "VTCRST);
	printf("\n");
}

void getip(char *host)
{
	struct addrinfo hints, *res;
	char ipstr[INET6_ADDRSTRLEN];
	int status, v4, v6;

	memset(&hints, 0, sizeof(hints));

	hints.ai_socktype = SOCK_STREAM;
#if (GETIPV6 > 0)
	hints.ai_family = AF_UNSPEC;
#elif (GETIPV6 == 0)
	hints.ai_family = AF_INET;
#endif

	pthread_create(&thread, NULL, (void*)dot, (void*)40);
	/* Literally start a new thread for the dots thing just so
	 * if the lookup takes long, we can still get a return in time, maybe
	 */
	status = getaddrinfo(host, NULL, &hints, &res);
	pthread_join(thread, NULL);
	if(status) {
		printsuccess(FAIL);
		fprintf(stderr, " [-] Error: %s: %s\n", host, gai_strerror(status));
		exit(2);
	} else {
		printsuccess(SUCCESS);
		printf(" [+] Host: %s\n", host);

		for(v4 = v6 = 0; res != NULL; res = res->ai_next) {
			void *addr;

			if(res->ai_family == AF_INET && v4++ < GETIPV4) {
				struct sockaddr_in *ipv4 = (struct sockaddr_in*)res->ai_addr;
				addr = &(ipv4->sin_addr);
				inet_ntop(res->ai_family, addr, ipstr, sizeof(ipstr));
				printf(" [+] IPv4: %s\n", ipstr);
			}
			else if(res->ai_family == AF_INET6 && v6++ < GETIPV6) {
				struct sockaddr_in6 *ipv6 = (struct sockaddr_in6*)res->ai_addr;
				addr = &(ipv6->sin6_addr);
				inet_ntop(res->ai_family, addr, ipstr, sizeof(ipstr));
				printf(" [+] IPv6: %s\n", ipstr);
			}
		}
	}
}

void fxport(char* port, int slp)
{
	int i = '0';
	while(*port != '\0') {
		usleep(slp);
		putchar(i);
		if(i++ == *port) {
			port++;
			i = '0';
		} else {
			putchar('\b');
		}
		fflush(stdout);
	}
}

void launchproxy()
{
	dot(20);
	printsuccess(SUCCESS);
	printf(" [+] SSL entry point on 127.0.0.1:");
	fxport("31337", SLPTIME*4);
	putchar('\n');
}

void chainproxy()
{
	int i=26,c=0;
	char *countries[] = { "BEL","AUS","JAP","CHI","NOR","FIN","UKR" };
	char **cuntrees = countries;
	char line[] = " [+] 0/7 proxies chained {   >   >   >   >   >   >   }";

	dot(42);
	printsuccess(SUCCESS);

	while(i < strlen(line)) {
		line[i++] = (*cuntrees)[c++];
		if(c == 3) {
			line[5]++;
			c = 0;
			i++;
			cuntrees++;
			printf("\r%s", line);
			fflush(stdout);
			usleep(SLPTIME*4);
		}
	}
	putchar('\n');
}

void portknock()
{
	char *ports[] = { "143", "993", "587", "456", "25", "587", "993", "80", NULL };
	char **p = ports;
	dot(26);
	printsuccess(SUCCESS);
	printf(" [+] Knock on TCP<");
	while (*p != NULL) {
		fxport(*p++, SLPTIME);
		putchar(',');
	}
	printf("\b>\n");
}
	
void w00tw00t()
{
	dot(10);
	printsuccess(SUCCESS);
	printf(" [+] Stack override ***** w00t w00t g0t r00t!\n\n");

	putchar('[');
	dotchar = '=';	
	dot(65);
	printf(">]\n\n");
	
}

void prompt(char* host)
{
	int c = '\n';	// lol wow literally the best fix ever
	do {
		if(c == '\n') {
			printf("root@%s:/# ", host);
		} else if(c == EOF) {
			putchar('\n'); //"clean up"??
			break;
		}
	} while((c = getchar()));
}
		
		

int main(int argc, char *argv[])
{
	if(argc != 2) {
		printf("Call this program with a domain as an argument, eg:\n\
\t%s google.com\n", argv[0]); // Do not question my use of newlines.
		exit(1);
	}

	SPOOPYASCII
	printf("Enumerating Target");
	getip(argv[1]);
	sleep(1);

	printf("Opening SOCKS5 ports on infected hosts");
	launchproxy();
	sleep(1);

	printf("Chaining proxies");
	chainproxy();
	sleep(1);

	printf("Launching port knocking sequence");
	portknock();

	printf("Sending PCAP datagrams for fragmentation overlap");
	w00tw00t();

	prompt(argv[1]);

	return 0;
}
