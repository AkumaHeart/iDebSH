# syntax=docker/dockerfile:1
FROM --platform=linux/386 docker.io/library/debian:bookworm-slim AS builder

ENV DEBIAN_FRONTEND=noninteractive

# Update repository metadata and install essential base packages
RUN apt-get update && apt-get install -y --no-install-recommends \
    bash \
    coreutils \
    apt \
    dpkg \
    ca-certificates \
    curl \
    wget \
    nano \
    locales \
    procps \
    tar \
    gzip \
    xz-utils \
    && rm -rf /var/lib/apt/lists/*

# 1. Disable APT user privilege drop (runs as root inside fakefs sandbox)
RUN echo 'APT::Sandbox::User "root";' > /etc/apt/apt.conf.d/99ish

# 2. Add /ish filesystem metadata markers
RUN mkdir -p /ish && echo "1" > /ish/version && echo "12000" > /ish/debian-version

# 3. Create lightweight init replacement for iSH (systemd is incompatible)
RUN cat <<'EOF' > /sbin/init
#!/bin/sh
trap : TERM INT
while true; do
    sleep 3600 &
    wait $!
done
EOF
RUN chmod 755 /sbin/init

# 4. Set root password empty and set default login shell to bash
RUN passwd -d root && chsh -s /bin/bash root

# 5. Friendly welcome message for iDebSH users
RUN cat <<'EOF' > /etc/motd
Welcome to Debian GNU/Linux 12 (Bookworm) on iDebSH!

Manage packages with:
  apt update && apt install <package>

EOF

# 6. Compress the root filesystem into a clean tarball
RUN tar --numeric-owner -czf /root.tar.gz -C / \
    --exclude=dev/* \
    --exclude=proc/* \
    --exclude=sys/* \
    --exclude=root.tar.gz \
    .

# Output stage
FROM scratch
COPY --from=builder /root.tar.gz /
