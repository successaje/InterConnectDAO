#!/bin/bah

set -e

echo PATH = $PATH

# clear
dfx stop
rm -rf .dfx




dfx start --background
dfx canister create --all
dfx build
dfx canister install --all