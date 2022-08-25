#!/bin/bash

for repo in $REPO_LIST; do
    ls -altrh /cvmfs/$repo/.cvmfsdirtab || ls -altrh /cvmfs/$repo/new_repository ||  ls -altrh /cvmfs/$repo/README.md || exit 1;
done

ls -altrh /shared-home/ || exit 1;
