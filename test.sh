#!/bin/sh
set -e

sudo=sudo

while [ $# -gt 0 ]
do
    case "$1" in
        --no-sudo) sudo="";;
        *)
            echo "Unknown option '$1', exiting..." >&2
            exit 1;;
    esac
    shift
done

test_dir="/tmp/minix-fs-test"

cleanup() {
    echo "Cleaning up..."

    $sudo umount "$test_dir/mnt" || true
    rm -rf "$test_dir"

    echo "Finished cleaning up"
}

trap cleanup EXIT

mkdir -p "$test_dir"
dd if=/dev/zero of="$test_dir/minix.img" bs=1M count=10
mkfs.minix "$test_dir/minix.img"

echo "Created minix filesystem image"

mkdir -p "$test_dir/mnt"
$sudo mount -o loop "$test_dir/minix.img" "$test_dir/mnt"

echo "Mounted minix filesystem image"

sleep 1
