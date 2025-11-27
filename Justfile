# Build the aurora-oci container locally
build:
    buildah build -t aurora-common:latest -f ./Containerfile .
