# WSL2 Minix FS

This project allows you to mount a Minix filesystem in WSL2 without manually rebuilding the WSL2 kernel. It automatically builds and loads the Minix kernel module.

## Requirements

These requirements are for Ubuntu, you may need to adjust them for other distributions.

Install the required packages with
```bash
sudo apt install build-essential flex bison dwarves libssl-dev libelf-dev cpio qemu-utils rsync bc util-linux-extra git
```

## Usage

To use this project:
Clone the repository:
```bash
git clone https://github.com/KubaZ2/wsl2-minix-fs.git
```
And run the setup script:
```bash
./wsl2-minix-fs/setup.sh
```
You may be prompted to enter your password for sudo access. The script will build the Minix kernel module and load it.

This script also accepts optional arguments:
- `-b`/`--build`: Build the Minix kernel module (this is false by default, unless the module is not already built). Specify this option if you want to rebuild the module (for example, if you updated the kernel)
- `--branch <branch>`: Specify a branch to build from (by default it is detected automatically based on your WSL2 kernel version)
- `--no-sudo`: Do not use sudo for commands
- `-h`/`--help`: Show help message

After a reboot, you will need to rerun the setup script to load the Minix kernel module again. You could make it run automatically on startup if you want to.

## Testing

After the setup script finishes, you can test the Minix filesystem by running the test script (it automatically cleans up after itself):
```bash
sudo ./wsl2-minix-fs/test.sh
```

## Mounting a Minix filesystem

You can mount the Minix filesystem using the following commands:
```bash
# Create a mount point
sudo mkdir my-minix-mount

# Mount the Minix filesystem
sudo mount -o loop minix.img my-minix-mount

# Unmount the Minix filesystem
sudo umount my-minix-mount
```

## License

This repository is released under the [MIT License](LICENSE.md).
