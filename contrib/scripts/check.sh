#!/bin/bash

# Needed to exit from script on error
set -e

# MSRV
msrv="1.56.0"

is_msrv=false
version=""

# Check if "msrv" is passed as an argument
if [[ "$#" -gt 0 && "$1" == "msrv" ]]; then
    is_msrv=true
    version="+$msrv"
fi

# Check if MSRV
if [ "$is_msrv" == true ]; then
    # Install MSRV
    rustup install $msrv
    rustup component add clippy --toolchain $msrv
    rustup target add wasm32-unknown-unknown --toolchain $msrv
fi

buildargs=(
    ""
    "--target wasm32-unknown-unknown"
    "--features tracing"
    "--features tracing --target wasm32-unknown-unknown"
)

for arg in "${buildargs[@]}"; do
    if [[ $version == "" ]]; then
        echo  "Checking '$arg' [default]"
    else
        echo  "Checking '$arg' [$version]"
    fi
    cargo $version check $arg
    if [[ $arg != *"--target wasm32-unknown-unknown"* ]]; then
        cargo $version test $arg
    fi
    cargo $version clippy $arg -- -D warnings
    echo
done