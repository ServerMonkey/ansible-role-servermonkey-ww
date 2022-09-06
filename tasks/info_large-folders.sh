#!/bin/sh
#info: Find large folders on the local filesystem, WARNING: can take long!

du -x --max-depth 5 -h /* 2>&1 | grep '[0-9\.]\+G' | sort -hr | head
