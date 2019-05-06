#!/bin/bash
# get-linux-image.sh
#
# Author: Torsten Juul-Jensen
# April 27, 2019
# Original idea by: https://github.com/ppaskowsky/Bash
#
# Script to download torrent files for all major Linux distributions

#default download directory
DOWNLOADDIR=.

_help () {
  echo "Syntax: get-linux-image.sh [--all | --minimal | --distro fedora|ubuntu|debian|raspian|slackware|arch|suse|kali] [--target-directory <path to save output>] [--help]"
  #echo "             amd64 i386 lite* dvd server desktop"
  #echo "debian        x     x    x     x                "
  #echo "ubuntu        x     x                      x    "
  #echo "centos        x                x                "
  #echo "fedora        x     x                x     x**  "
  #echo "arch          x                                 "
  #echo "kali                                            "
  #echo "raspbian      x          x                 x    "
  #echo "slackware     x     x                           "
  #echo "suse          x          x                      "
  #echo
  #echo "* lite covers NetInstall, lite and light versions"
  #echo "** desktop corresponds to Workstation releases"
}

_set-flags-init () {
    # Distribution flags
    DEBIANFLAG=0
    UBUNTUFLAG=0
    CENTOSFLAG=0
    FEDORAFLAG=0
    ARCHFLAG=0
    KALIFLAG=0
    RASPBIANFLAG=0
    SLACKWAREFLAG=0
    SUSEFLAG=0
    # Other flags
    FILETYPE=torrent   #FILETYPE=iso
    LITE=0
    DVD=0
    AMD64=0
    I386=0
}

_set-flags-minimal () {
    # Distribution flags
    DEBIANFLAG=0
    UBUNTUFLAG=0
    CENTOSFLAG=1
    FEDORAFLAG=1
    ARCHFLAG=0
    KALIFLAG=0
    RASPBIANFLAG=0
    SLACKWAREFLAG=0
    SUSEFLAG=0
    # Other flags
    FILETYPE=torrent   #FILETYPE=iso
    LITE=1
    DVD=0
    AMD64=1
    I386=0
}

_set-flags-all () {
    # Distribution flags
    DEBIANFLAG=1
    UBUNTUFLAG=1
    CENTOSFLAG=1
    FEDORAFLAG=1
    ARCHFLAG=1
    KALIFLAG=1
    RASPBIANFLAG=1
    SLACKWAREFLAG=1
    SUSEFLAG=1
    # Other flags
    FILETYPE=torrent   #FILETYPE=iso
    LITE=1
    DVD=1
    AMD64=1
    I386=1
}

_parse_arguments () {

  #_set-flags-init
  _set-flags-init

  if [[ $# -eq 0 ]] ; then _set-flags-all ; fi

  while [[ $# -gt 0 ]]
  do

  case $1 in
    -a | --all)
      _set-flags-all
      shift
      ;;

    -m | --minimal)
      _set-flags-minimal
      shift
      ;;

    -d | --distro)
      DISTRIBUTION="$2"
      if [[ $DISTRIBUTION == "debian" ]] ; then DEBIANFLAG=1
        elif [[ $DISTRIBUTION == "ubuntu" ]] ; then UBUNTUFLAG=1
        elif [[ $DISTRIBUTION == "centos" ]] ; then CENTOSFLAG=1
        elif [[ $DISTRIBUTION == "fedora" ]] ; then FEDORAFLAG=1
        elif [[ $DISTRIBUTION == "arch" ]] ; then ARCHFLAG=1
        elif [[ $DISTRIBUTION == "kali" ]] ; then KALIFLAG=1
        elif [[ $DISTRIBUTION == "raspbian" ]] ; then RASPBIANFLAG=1
        elif [[ $DISTRIBUTION == "slackware" ]] ; then SLACKWAREFLAG=1
        elif [[ $DISTRIBUTION == "suse" ]] ; then SUSEFLAG=1
      else
        echo Distribution not found.
        exit 1
      fi
      shift
      shift
      ;;

    -t | --target-directory)
      if realpath -e -q $2 1>/dev/null ; then
        DOWNLOADDIR=$2
      else
        echo Target directory does not exist
        exit 2
      fi
      shift
      shift
      ;;

    -h | --help)
      _help
      exit 1
      shift
      ;;

    *)  # unknown parameter
      echo Unknown option.
      _help
      exit 1
      shift
      ;;
  esac
  done

}

_get-debian () {
  # debian amd64/i386 cd/dvd
  #Debian DVD amd64
  URL=https://cdimage.debian.org/debian-cd/current/amd64/bt-dvd/
  wget -q --show-progress -r -nH --cut-dirs=4 --no-parent -A "*.torrent" -R  "*mac*" $URL/ -P $DOWNLOADDIR/

  #Debian CD amd64
  URL=https://cdimage.debian.org/debian-cd/current/amd64/bt-cd/
  wget -q --show-progress -r -nH --cut-dirs=4 --no-parent -A "*netinst*" -R  "*mac*" $URL/ -P $DOWNLOADDIR/

  #Debian DVD i386
  URL=https://cdimage.debian.org/debian-cd/current/i386/bt-dvd/
  wget -q --show-progress -r -nH --cut-dirs=4 --no-parent -A "*.torrent" -R  "*mac*" $URL/ -P $DOWNLOADDIR/

  #Debian CD i386
  URL=https://cdimage.debian.org/debian-cd/current/i386/bt-cd/
  wget -q --show-progress -r -nH --cut-dirs=4 --no-parent -A "*netinst*" -R  "*mac*" $URL/ -P $DOWNLOADDIR/

}

_get-ubuntu () {
  # Ubuntu desktop torrent
  URL="https://www.ubuntu.com/download/alternative-downloads"
  curl $URL 2>&1 | grep -o -E 'href="([^"#]+)"' | grep -E 'http|https' | \
    grep releases | grep desktop | cut -d'"' -f2 | sort -n -r | awk NR==1 | xargs --no-run-if-empty wget -q --show-progress -P $DOWNLOADDIR/

  # Ubuntu server torrent
  URL="https://www.ubuntu.com/download/alternative-downloads"
  curl $URL 2>&1 | grep -o -E 'href="([^"#]+)"' | grep -E 'http|https' \
    | grep releases | grep server | cut -d'"' -f2 | sort -n -r | awk NR==1 | xargs --no-run-if-empty wget -q --show-progress -P $DOWNLOADDIR/
}

_get-centos () {
  # CentOS
  # Version: DVD, Everything, LiveGNOME, LiveKDE, Minimal, NetInstall
  # Build the download path from substrings
  CENTOSMIRROR=http://mirrors.dotsrc.org/centos/
  CENTOSRELEASE=$(curl $CENTOSMIRROR 2>&1 | grep -o -E 'href="([^"#]+)"' | cut -d'"' -f2 | sed 's/\/*$//g' | sort -n -r | awk NR==1)
  CENTOSLATESTDIR=$CENTOSMIRROR$CENTOSRELEASE/isos/x86_64/
  FILENAME=$(curl $CENTOSLATESTDIR 2>&1 | grep -o -E 'href="([^"#]+)"' | cut -d'"' -f2 | grep DVD | grep torrent | sort -n -r | awk NR==1)

  wget -q --show-progress -P $DOWNLOADDIR/ $CENTOSLATESTDIR$FILENAME

  # Checksum files ARE part of torrent downloads
  #Checksum file can be downloaded like this:
  #SHA256FILENAME=$(curl $CENTOSLATESTDIR 2>&1 | grep -o -E 'href="([^"#]+)"' | cut -d'"' -f2 | grep sha256sum | awk NR==1)
  #wget -q --show-progress -P $DOWNLOADDIR/ $CENTOSLATESTDIR$SHA256FILENAME


}

_get-fedora () {
  #Fedora Workstation i386
  URL=https://torrent.fedoraproject.org/
  curl $URL 2>&1 | grep -Eoi '<a [^>]+>' | grep -E 'http|https' | cut -d'"' -f2 \
    | grep Workstation | grep -v Atomic | grep -v Beta | grep i386  |sort -n -r | awk NR==1 | xargs --no-run-if-empty wget -q --show-progress -P $DOWNLOADDIR/

  #Fedora Workstation x86_64
  URL=https://torrent.fedoraproject.org/
  curl $URL 2>&1 | grep -Eoi '<a [^>]+>' | grep -E 'http|https' | cut -d'"' -f2 \
    | grep Workstation | grep -v Atomic | grep -v Beta | grep x86_64  |sort -n -r | awk NR==1 | xargs --no-run-if-empty wget -q --show-progress -P $DOWNLOADDIR/

  #Fedora Server i386
  URL=https://torrent.fedoraproject.org/
  curl $URL 2>&1 | grep -Eoi '<a [^>]+>' | grep -E 'http|https' | cut -d'"' -f2 \
    | grep Server | grep -v Beta | grep -e i386 | sort -n -r | awk NR==1 | xargs --no-run-if-empty wget -q --show-progress -P $DOWNLOADDIR/

  #Fedora Server x86_64
  URL=https://torrent.fedoraproject.org/
  curl $URL 2>&1 | grep -Eoi '<a [^>]+>' | grep -E 'http|https' | cut -d'"' -f2 \
    | grep Server | grep -v Beta | grep -e x86_64 | sort -n -r | awk NR==1 | xargs --no-run-if-empty wget -q --show-progress -P $DOWNLOADDIR/
}

_get-arch () {
  #Arch Linux
  BASEURL=https://www.archlinux.org/
  URL=https://www.archlinux.org/download/
  TORRENTPATH=$(curl $URL 2>&1 | grep -v Download | grep torrent |  cut -d'"' -f2 )
  wget --content-disposition  -q --show-progress  $BASEURL$TORRENTPATH -P $DOWNLOADDIR/

}

_get-kali () {
  #Kali
  URL=https://www.kali.org/downloads/
  curl $URL 2>&1 |  grep -Eoi '<a [^>]+>' | grep -E 'http|https' | cut -d'"' -f2 \
    | grep torrent | grep -v e17 | grep -v xfce | grep -v kde | grep -v lxde | grep -v mate | grep -v armhf | xargs --no-run-if-empty wget -q --show-progress -P $DOWNLOADDIR/
}

_get-raspbian () {
  #Raspian downloads
  # Download zip files like this: wget --content-disposition https://downloads.raspberrypi.org/raspbian_full_latest

  # Raspbian Stretch with desktop and recommended software (FULL)
  URL=https://www.raspberrypi.org/downloads/raspbian/
  curl $URL 2>&1 |  grep -Eoi '<a [^>]+>' | grep -E 'http|https' | cut -d'"' -f2 \
    | grep torrent | grep full | xargs --no-run-if-empty wget -q --show-progress -P $DOWNLOADDIR/

  # Raspbian Stretch with desktop
  URL=https://www.raspberrypi.org/downloads/raspbian/
  curl $URL 2>&1 |  grep -Eoi '<a [^>]+>' | grep -E 'http|https' | cut -d'"' -f2 \
    | grep torrent | grep raspbian_latest | xargs --no-run-if-empty wget -q --show-progress -P $DOWNLOADDIR/

  # Raspbian Stretch Lite
  URL=https://www.raspberrypi.org/downloads/raspbian/
  curl $URL 2>&1 |  grep -Eoi '<a [^>]+>' | grep -E 'http|https' | cut -d'"' -f2 \
    | grep torrent | grep lite | xargs --no-run-if-empty wget -q --show-progress -P $DOWNLOADDIR/

  # Get SHA-256 sums for all three files directly from web page using this function:
  # wget -qO- $URL | grep -oP 'SHA-256:.*'  | cut -f 3 -d ">" | cut -f 1 -d "<"
  # curl $URL 2>&1 |  grep -Eoi '<a [^>]+>' | grep -E 'http|https' | cut -d'"' -f2  | grep torrent | sed 's/torrent/zip/g'

}

_get-slackware () {
  #Slackware

  #Slackware 64bit
  URL=http://www.slackware.com/torrents/
  FILENAME=$(curl $URL 2>&1 |  grep -Eoi '<a [^>]+>' | cut -d'"' -f2  | grep torrent | sort -n -r | awk NR==1 |  cut -f3 -d '/')
  wget -q --show-progress $URL$FILENAME -P $DOWNLOADDIR/

  #Slackware 32bit
  URL=http://www.slackware.com/torrents/
  FILENAME=$(curl $URL 2>&1 |  grep -Eoi '<a [^>]+>' | cut -d'"' -f2  | grep torrent | sort -n -r | awk NR==1 |  cut -f3 -d '/' | sed 's/slackware64/slackware/g')
  wget -q --show-progress $URL$FILENAME -P $DOWNLOADDIR/

}

_get-suse () {
  #OpenSUSE
  URL=https://software.opensuse.org/distributions/leap
  curl $URL 2>&1 | grep -Eoi '<a [^>]+>' | grep -E 'http|https' | cut -d'"' -f2 \
      | grep torrent | grep DVD | sort -n -r | awk NR==1 | xargs --no-run-if-empty wget -q --show-progress -P $DOWNLOADDIR/

  #NetInstall
  curl $URL 2>&1 | grep -Eoi '<a [^>]+>' | grep -E 'http|https' | cut -d'"' -f2 \
      | grep torrent | grep NET | sort -n -r | awk NR==1 | xargs --no-run-if-empty wget -q --show-progress -P $DOWNLOADDIR/

}

_download_files () {

  (( $DEBIANFLAG == 1)) && _get-debian
  (( $UBUNTUFLAG == 1)) && _get-ubuntu
  (( $CENTOSFLAG == 1)) && _get-centos
  (( $FEDORAFLAG == 1)) && _get-fedora
  (( $ARCHFLAG == 1)) &&  _get-arch
  (( $KALIFLAG == 1)) && _get-kali
  (( $RASPBIANFLAG == 1)) && _get-raspbian
  (( $SLACKWAREFLAG == 1)) && _get-slackware
  (( $SUSEFLAG == 1)) && _get-suse

}

_cleanup () {
  #unfortunately wget leaves traces after some download, so this section is for cleaning
  #remove leftovers from wget
  rm $DOWNLOADDIR/robots.txt.tmp 2> /dev/null
}


# MAIN
_parse_arguments $@
_download_files
_cleanup
