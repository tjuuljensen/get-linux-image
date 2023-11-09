# get-linux-image

## This repo is archived
I have implemented the functionality of ths repo in my ride-fedora repository, and that is where I will maintain it in the future.

## About
Tool to help download image files for all major Linux distributions

Syntax (planned):  [--all | --minimal | --distro fedora|ubuntu|debian|raspian|slackware|arch|suse|kali] [--torrent | --iso] [--lts | --latest] --amd64 --i386 --lite --dvd --help --target-directory

default: --all --torrent --amd64 --i386

**Selection criteria**
* distro (all/minimal/single)
* filetype (torrent/iso)

**Sub criteria**
* architecture (amd64/i386)
* imagesize (lite/dvd)
* option (latest/lts)

**Minor criteria**
* type (server/workstation/desktop)
