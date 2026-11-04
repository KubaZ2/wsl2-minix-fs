# WSL2 Minix FS

This project allows you to mount a Minix filesystem in WSL2 without manually rebuilding the WSL2 kernel. It automatically builds and loads the Minix kernel module.

## Requirements

These requirements are for Ubuntu, you may need to adjust them for other distributions.

Install the required packages with
```bash
sudo apt install build-essential flex bison dwarves libssl-dev \
                 libelf-dev cpio qemu-utils rsync bc util-linux-extra git
```

## Usage

To use this project:

- Clone the repository:
  ```bash
  git clone https://github.com/KubaZ2/wsl2-minix-fs.git
  ```
- And run the setup script:
  ```bash
  ./wsl2-minix-fs/setup.sh
  ```

On the first run, the script will automatically build and load the Minix kernel module. On subsequent runs, it will skip the build and just load the existing module by default.

The setup script also accepts optional arguments:
- `-b`/`--build`: Build the Minix kernel module (this is assumed to be specified when module is not already built). Specify this option if you want to rebuild the module (for example, if you updated the WSL2 kernel)
- `--branch <branch>`: Specify a branch to build from (by default it is detected automatically based on your WSL2 kernel version)
- `--no-load`: Do not load the Minix kernel module after building it
- `--no-sudo`: Do not use sudo for commands
- `-h`/`--help`: Show help message

After a reboot, you will need to rerun the setup script to load the Minix kernel module again. You could make it run automatically on startup if you want to.

## Testing

After the setup script finishes, you can test the Minix filesystem mounts correctly by running the test script (it cleans up after itself):
```bash
sudo ./wsl2-minix-fs/test.sh
```

## Mounting a Minix filesystem

Assuming you have a Minix filesystem image (e.g., `minix.img`), you can mount it using the following commands:
```bash
# Create a mount point
sudo mkdir my-minix-mount

# Mount the Minix filesystem
sudo mount -o loop minix.img my-minix-mount

# Unmount the Minix filesystem (when done)
sudo umount my-minix-mount
```

## License

This repository is released under the [MIT License](LICENSE.md).
