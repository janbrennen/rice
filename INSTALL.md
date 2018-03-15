Tested on Fedora Core 26 at 1600x900 resolution:

Install prerequisites:

    $ dnf install lua htop mplayer sox youtube-dl

Configure gnome-terminal

    Set the color scheme to (built-in) Green on Black
    Set the color palette to xterm

    $ perl 256color.pl

    You're looking for an image like this:
    ![256colors](docs/example_256_color.png)
    
    If all of the colors are visible, continue. Otherwise, you may need to
    find a suitable 256-color terminal.

Install tmux from source. This may not be neccessary, but it is tested

    $ git clone https://github.com/tmux/tmux
    $ cd tmux
    $ ./configure && make
    $ make install

Install cli-visualizer

    $ dnf install fftw-devel ncurses-devel pulseaudio-libs-devel
    $ git clone https://github.com/dpayne/cli-visualizer
    $ cd cli-visualizer
    $ ./install.sh
    $ cd ~
    $ vis
    (Verify the bars are moving while playing audio, q to exit)

Install and verify cmatrix:

    $ git clone https://github.com/abishekvashok/cmatrix
    $ cd cmatrix
    $ autoreconf -i
    $ ./configure
    $ sudo make install
    $ cd ~
    $ cmatrix
    (ctrl-c to exit)


Verify spooky:

    $ lua 3spooky.lua 
    (Press ctrl-Z to stop, then pkill lua to terminate)

Verify hack.exe
    
    $ ./hack.exe
    (Type 'exit' to stop, then ctrl-c to terminate)

Verify hack.exe
    
    $ ./hack.exe yahoo.com
    (Type 'exit' to stop, then ctrl-c to terminate)

Verify pipes.sh

    $ ./pipes.sh
    (Control-C to exit)
    # If you want pipes precisely like shown in the original gif, you'll
    # need to install pipes from: https://github.com/pipeseroni/pipes.sh

Configure htop:

    $ htop
    (Press F2, In Left column, delete CPUs (1/1) [Bar]
     Add CPU average from available meters to left column, it will change
     it's name to just CPU [Bar])
    (Press q to quit htop)

Start a new gnome-terminal window

    These settings are for a 1600x900 screen resolution:

    Create a new profile called "hackermode", make the following settings:
    Font: monospace regular 9 point
    Color scheme: green on black
    Color palette:  xterm
    Turn off scroll bar
    Turn off menu bar


