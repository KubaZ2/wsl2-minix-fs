#!/bin/sh
set -e

program="$0"

build=n
branch=""
load=y
sudo=sudo
cache_dir=""

while [ $# -gt 0 ]
do
    case "$1" in
        -b|--build) build=y;;
        --branch)
            if [ $# -lt 2 ]
            then
                echo "Missing argument for --branch, exiting..." >&2
                exit 1
            fi
            branch="$2"
            shift;;
        --no-load) load=n;;
        --no-sudo) sudo="";;
        --cache-dir)
            if [ $# -lt 2 ]
            then
                echo "Missing argument for --cache-dir, exiting..." >&2
                exit 1
            fi
            cache_dir="$2"
            shift;;
        -h|--help)
            echo "Usage: $(basename "$0") [-b|--build] [--branch <branch>] [--no-load] [--no-sudo] [--cache-dir <dir>] [-h|--help]"
            exit 0;;
        *)
            echo "Unknown option '$1', exiting..." >&2
            exit 1;;
    esac
    shift
done

if [ -z "$cache_dir" ]
then
    cache_dir="$(dirname "$program")/cache"
fi

if [ "$build" != "y" ] && [ ! -e "$cache_dir/minix.ko" ]
then
    echo "File $cache_dir/minix.ko not found, assuming --build"
    build=y
fi

if [ "$build" = "y" ]
then
    if [ -z "$branch" ]
    then
        branch="linux-msft-wsl-$(uname -r | cut -d "-" -f 1)"
        echo "Using automatically detected kernel version: $1"
    fi

    kernel_dir="$cache_dir/wsl2-linux-kernel"

    cleanup() {
        echo "Cleaning up..."
        rm -rf "$kernel_dir"
        echo "Finished cleaning up"
    }

    trap cleanup EXIT

    echo "Cloning branch $branch..."
    git clone --depth 1 --single-branch --branch "$branch" https://github.com/microsoft/wsl2-linux-kernel "$kernel_dir"

    echo "Building..."

    arch=$(uname -m)
    case "$arch" in
        x86_64) config_suffix="";;
        aarch64) config_suffix="-arm64";;
        *) echo "Unknown architecture $arch, exiting..." >&2; exit 1;;
    esac

    cp "$kernel_dir/Microsoft/config-wsl$config_suffix" "$kernel_dir/.config"

    (cd "$kernel_dir" && ./scripts/config -m CONFIG_MINIX_FS --refresh)

    make modules_prepare -j"$(nproc)" -C "$kernel_dir"

    make M=fs/minix KBUILD_MODPOST_WARN=1 -j"$(nproc)" -C "$kernel_dir"

    cp -f "$kernel_dir/fs/minix/minix.ko" "$cache_dir"

    echo "Build finished"
fi

if [ "$load" != "y" ]
then
    echo "Skipping module load"
    exit 0
fi

if $sudo rmmod -f minix >/dev/null 2>&1
then
    echo "Unloaded module minix"
fi

echo "Loading module minix..."

$sudo insmod "$cache_dir/minix.ko"

echo "Loaded module minix"
