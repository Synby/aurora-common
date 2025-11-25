
FROM docker.io/library/alpine:latest AS builder


RUN apk add --no-cache curl jq zstd tar
ENV URL="https://api.github.com/repos/ublue-os/artwork/releases"


RUN sh <<'EOF'
set -xeuo pipefail

# Use jq to find the download URL for the latest aurora-wallpapers.tar.zstd asset
TARBALL=$(curl -s ${URL} | jq -r 'first(.[] | .assets[]? | select(.name == "aurora-wallpapers.tar.zstd") .browser_download_url)')

# Download the compressed file
curl -L "$TARBALL" -o /tmp/aurora-wallpapers.tar.zstd

# --- EXTRACT AND STRUCTURE ---
mkdir -p /output/
mkdir -p /tmp/aurora-wallpapers
# Extract the archive contents into the temporary folder
tar -xvf /tmp/aurora-wallpapers.tar.zstd -C /tmp/aurora-wallpapers

cd /tmp/aurora-wallpapers
rm -rf kde/*/gnome-background-properties/
mkdir -p /output/usr/share/wallpapers
mkdir -p /output/usr/share/backgrounds
mv kde/ /output/usr/share/backgrounds/aurora/

# --- CREATE SYMLINKS ---
# This step creates relative symlinks from the generic 'wallpapers' directory
# to the 'backgrounds/aurora' directories for compatibility.
cd /output/usr/share/backgrounds
for dir in aurora/*; do
  # Symlink: /output/usr/share/wallpapers/{dir_name} -> ../backgrounds/aurora/{dir_name}
  ln -s "../backgrounds/${dir}" ../wallpapers/
done
rm -rf /tmp/aurora-wallpapers.tar.zstd /tmp/aurora-wallpapers
EOF

FROM scratch AS ctx

COPY --from=builder /output/ /wallpapers

COPY /brew /brew
COPY /flatpaks /flatpaks
COPY /just /just
COPY /logos /logos
COPY /system_files /system_files

