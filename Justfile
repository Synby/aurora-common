# Build the aurora-common container locally
build:
    buildah build -t aurora-common:latest -f ./Containerfile .
