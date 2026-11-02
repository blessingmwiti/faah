# faah

`faah` plays a short audio clip from the command line.  It is a tiny
POSIX shell wrapper: it locates a suitable audio player on the system
and hands it the bundled `faah.mp3`.

## Usage

    $ faah              # play the clip
    $ faah --help
    $ faah --version
    $ FAAH_PLAYER=mpv faah

The audio player is chosen in this order: `mpg123`, `mpg321`, `ffplay`,
`mpv`, `cvlc`, `gst-play-1.0`, `mplayer`, `play`, `afplay`.

## Build and install

    $ make
    $ sudo make install PREFIX=/usr

This installs `/usr/bin/faah`, `/usr/share/faah/faah.mp3` and the man
page.  On Debian, build the package instead:

    $ ./build-deb.sh

The resulting `.deb`, `.dsc` and source tarball are placed in `dist/`.

## License

The `faah` script and documentation are licensed under the MIT license;
see `LICENSE`.

The bundled recording `faah.mp3` is attributed to **aleki1** and is
licensed under Creative Commons Attribution 4.0 International
(CC BY 4.0); see `LICENSE.audio` and `debian/copyright`.

## Author

Blessing Mwiti <me@blessingmwiti.com> — <https://blessingmwiti.com>
