#!/usr/bin/env bash
youtube-dl -q -o- "$*" | mplayer -loop 0 -vo null -af scaletempo  -softvol -softvol-max 400  -cache 8192  -

# Usage:
#     youtube-mplayer.sh https://www.youtube.com/watch?v=v-OS-DgxuFo
#
# From: https://gist.github.com/elFua/48f804f0994bb968c3952f3fea69bc23
