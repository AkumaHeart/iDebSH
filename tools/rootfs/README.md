# Debian i386 RootFS Generator for iDebSH

This directory contains the tools needed to construct a minimal Debian 12 (Bookworm) `i386` root filesystem for iDebSH.

## Prerequisites
- Docker (with buildx support)

## Building `root.tar.gz`
Run:
```bash
./tools/rootfs/build.sh
```
This will build the Docker container using emulation (`--platform=linux/386`) and output `root.tar.gz` directly into the repository root.

When Xcode builds the iDebSH app, it will detect this local `root.tar.gz` and bundle it directly into the app bundle.

## Key Workarounds in the Image
1. **Lightweight `/sbin/init`**: Standard `systemd` fails because iOS and iSH do not support namespaces, cgroups, or systemd-journald. A minimal POSIX signal reaper script is installed as `/sbin/init`.
2. **APT Sandbox Configuration**: `/etc/apt/apt.conf.d/99ish` sets `APT::Sandbox::User "root";` to prevent privilege drop errors inside iOS's sandboxed `fakefs`.
3. **Empty Root Password & Shell**: Root password is empty and default shell is set to `/bin/bash`.
4. **Metadata Markers**: `/ish/version` and `/ish/debian-version` track repository sync and filesystem upgrades.
