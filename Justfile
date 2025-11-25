# Build the aurora-oci container locally
build:
    buildah build -t aurora-oci:latest -f ./Containerfile .
