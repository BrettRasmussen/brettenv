#!/usr/bin/env bash

# https://htmlcolorcodes.com/color-names/

hex_re="^([A-Fa-f0-9]{6}|[A-Fa-f0-9]{3})$"
color=$1
[[ $color =~ $hex_re ]] && color="#${color}"
cmd="git log -5 --pretty=format:'%C(${color})%as %C(auto)%h%d %s'"
eval ${cmd}
echo
