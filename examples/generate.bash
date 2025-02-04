#!/bin/bash

# This script is used to generate the images for the examples README
# It requires the following tools:
# - cargo: https://doc.rust-lang.org/cargo/getting-started/installation.html
# - gh: https://github.com/cli/cli
# - git: https://git-scm.com/
# - vhs: https://github.com/charmbracelet/vhs

# Exit on error. Append "|| true" if you expect an error.
set -o errexit
# Exit on error inside any functions or subshells.
set -o errtrace
# Do not allow use of undefined vars. Use ${VAR:-} to use an undefined VAR
set -o nounset
# Catch the error in case mysqldump fails (but gzip succeeds) in `mysqldump |gzip`
set -o pipefail
# Turn on traces, useful while debugging but commented out by default
# set -o xtrace

# ensure that running each example doesn't have to wait for the build
cargo build --examples --features=crossterm,all-widgets

for tape in examples/*.tape
do
    gif=${tape/examples\/}
    gif=${gif/.tape/.gif}
    ~/go/bin/vhs $tape --quiet
    # this can be pasted into the examples README.md
    echo "[${gif}]: https://github.com/ratatui-org/ratatui/blob/images/examples/${gif}?raw=true"
done
git switch images
git pull --rebase upstream images
cp target/*.gif examples/
git add examples/*.gif
git commit -m 'docs(examples): update images'
gh pr create
git sw -
