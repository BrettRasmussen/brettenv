#!/usr/bin/env bash

shopt -s expand_aliases
source "${HOME}/.brettenv/aliases"

file=tmp/migs-by-branch.txt
echo "" > ${file}

branches=(production dkr-prod staging docker job_flow playground)
for branch in ${branches[@]}; do
  gco $branch
  echo $branch >> tmp/migs-by-branch.txt
  l db/migrate | tail -n 25 >> ${file}
done

gco production
# nv ${file}

echo
