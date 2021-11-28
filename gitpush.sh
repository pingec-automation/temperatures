#!/bin/bash

# store credentials on disk https://stackoverflow.com/a/56058897
# git config (--global?) credential.helper store

# stash local changes, update repo to latest version
git stash
git pull
git stash apply

# push local changes
git add .
git commit -m "log update"
git push origin main