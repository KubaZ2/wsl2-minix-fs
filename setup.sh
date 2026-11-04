#!/bin/sh
set -e

dir=`dirname "$0"`

build=n
branch=""
load=y
use_sudo=y

while [ -n "$1" ]
do
    case "$1" in
        -b|--build) build=y;;
        --branch) branch="$2"; shift;;
        --no-load) load=n;;
        --no-sudo) use_sudo=n;;
        -h|--help) echo "usage: `basename "$0"` [-b|--build] [--branch <branch>] [--no-load] [--no-sudo]"; exit 0;;
        *) echo "unknown option $1, exiting..." 1>&2; exit 1;;
    esac
    shift
done

if [ "$build" != "y" ] && [ ! -e "$dir/minix.ko" ]
then
    echo "File $dir/minix.ko not found, assuming --build"
    build=y
fi

if [ "$build" = "y" ]
then
    if [ -z "$branch" ]
    then
        prev_ifs=$IFS
        IFS="-"
        set -- `uname -r`
        branch="linux-msft-wsl-$1"
        IFS="$prev_ifs"

        echo "Using automatically detected kernel version: $1"
    fi

    kernel_dir="$dir/wsl2-linux-kernel"

    cleanup() {
        echo "Cleaning up..."
        rm -rf "$kernel_dir"
        echo "Finished cleaning up"
    }

    trap cleanup EXIT

    echo "Cloning branch $branch..."
    git clone --depth 1 --single-branch --branch "$branch" https://github.com/microsoft/wsl2-linux-kernel "$kernel_dir"

    echo "Building..."

    cp "$kernel_dir/Microsoft/config-wsl" "$kernel_dir/.config"

    (cd "$kernel_dir" && "./scripts/config" -m CONFIG_MINIX_FS --refresh)

    make modules_prepare -j`nproc` -C "$kernel_dir"

    make M=fs/minix KBUILD_MODPOST_WARN=1 -j`nproc` -C "$kernel_dir"

    cp -f "$kernel_dir/fs/minix/minix.ko" "$dir"

    echo "Build finished"
fi

if [ "$load" != "y" ]
then
    echo "Skipping module load"
    exit 0
fi

if [ "$use_sudo" = "y" ]
then
    sudo="sudo"
else
    sudo=""
fi

if $sudo rmmod -f minix 1>/dev/null 2>&1
then
    echo "Unloaded module minix"
fi

echo "Loading module minix..."

$sudo insmod "$dir/minix.ko"

echo "Loaded module minix"
