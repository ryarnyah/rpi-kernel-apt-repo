#!/bin/bash
set -e

# Fetch branches from raspberrypi/linux
git remote add upstream https://github.com/raspberrypi/linux 2>/dev/null || true

# Get branches matching rpi-* pattern, sort by version, take last 2
BRANCHES=$(git ls-remote -q --branches upstream | awk '{print $2}' | grep -o 'rpi-[0-9]\+\.[0-9]\+\.y' | sort -V -t '.' -k 1,1 -k 2,2 -k 3,3 | tail -2)
# Convert to comma-separated list
echo "$BRANCHES" | tr '\n' ',' | sed 's/,$//'
