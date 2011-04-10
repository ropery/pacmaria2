Overview
========

_pacmaria2_ aims to boost package download speed by pulling files from multiple
mirrors. pacmaria2 can be used to download packages faster, or to output a
metalink file for later use.

Requirements
============

* pacmaria2 is written in [BASH][].
* [aria2][] is used to download files.
* [reflector][] is used for the --r option.

  [bash]: http://www.gnu.org/software/bash/
  [aria2]: http://aria2.sourceforge.net/
  [reflector]: http://xyne.archlinux.ca/projects/reflector/

Usage
=====

    USAGE: pacmaria2.sh [--d <directory>] [--p] [--r] <arguments>

    OPTIONS:
      -h,--help       Print this message and exit.
      --d <directory> Download files to directory.
      --m <file>      Use file as mirrorlist file.
      --p             Print metalink to stdout and don't download.
      --r             Run reflector to retrieve server list.

    NOTES:
      Arguments are passed to pacman in addition to -Sp.
      If no arguments are passed, -u is passed to pacman.

Examples
========

Download packages to current directory, then install with pacman.

    $ pacmaria2 --r --d . sound-juicer && sudo pacman -S sound-juicer --cachedir .

Generate a metalink file and download later.

    $ pacmaria2 --r --p k3b > k3b.metalink
    $ aria2c --metalink-file=k3b.metalink

Notes
=====

* Since there's no configuration file and few command line options, users are
encourageed to modify the aria2c / reflector options in the script.
* By default, packages are downloaded to _/var/cache/pacman/pkg/_. Make sure
you have write permission to it.
* If aria2c couldn't finish the download, you will get left-over .aria2 files
and incomplete packages in your download directory.

See Also
========

* aria2c man page: [aria2c(1)][]

  [aria2c(1)]: http://aria2.sourceforge.net/aria2c.1.html

