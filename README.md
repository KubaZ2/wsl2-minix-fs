# WSL2 Minix FS

This project allows you to mount a Minix filesystem in WSL2 without manually rebuilding the WSL2 kernel. It automatically builds and loads the Minix kernel module.

## Usage

The setup script can be run either with [Nix](https://nixos.org/download/#nix-install-windows) or without it. Nix is a package manager that allows you to run the setup script without installing any dependencies on your system. If you don't have Nix installed, you can follow the instructions below to set up the project manually.

### With Nix

Just run the following command:
```bash
nix run github:KubaZ2/wsl2-minix-fs#setup
```

### Without Nix

- Install the required packages (this is for Ubuntu, you may need to adjust the command for other distributions):
  ```bash
  sudo apt install build-essential flex bison dwarves libssl-dev \
                   libelf-dev cpio qemu-utils rsync bc util-linux-extra git
  ```
- Clone the repository and enter it:
  ```bash
  git clone https://github.com/KubaZ2/wsl2-minix-fs.git
  cd wsl2-minix-fs
  ```
- And run the setup script:
  ```bash
  ./setup.sh
  ```

---

On the first run, the script will automatically build and load the Minix kernel module. On subsequent runs, it will skip the build and just load the existing module by default.

The setup script also accepts optional arguments (for Nix, they need to be prepended with `--`):
- `-b`/`--build`: Build the Minix kernel module (this is assumed to be specified when module is not already built). Specify this option if you want to rebuild the module (for example, if you updated the WSL2 kernel)
- `--branch <branch>`: Specify a branch to build from (by default it is detected automatically based on your WSL2 kernel version)
- `--no-load`: Do not load the Minix kernel module after building it
- `--no-sudo`: Do not use sudo for commands that require root privileges
- `--cache-dir <path>`: Specify a directory to cache the built module (by default it is cached in `$HOME/.cache/wsl2-minix-fs` for Nix-based setup, or `cache` directory alongside the setup script otherwise)
- `-h`/`--help`: Show help message

After a reboot, you will need to rerun the setup script to load the Minix kernel module again. You could make it run automatically on startup if you want to.

## Testing

After the setup script finishes, you can test the Minix filesystem mounts correctly by running the test script (it cleans up after itself):
### With Nix
```bash
nix run github:KubaZ2/wsl2-minix-fs#test
```

### Without Nix
```bash
./test.sh
```

The test script has an optional argument `--no-sudo` to avoid using sudo for commands that require root privileges.

## Mounting a Minix filesystem

Assuming you have a Minix filesystem image (e.g., `minix.img`), you can mount it using the following commands:
```bash
# Create a mount point
mkdir my-minix-mount

# Mount the Minix filesystem
sudo mount -o loop minix.img my-minix-mount

# Unmount the Minix filesystem (when done)
sudo umount my-minix-mount
```

## License

This repository is released under the [MIT License](LICENSE.md).
