#!/bin/bash

set -x
set -e

curl -O https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh
sha256sum --check miniconda.sha256
bash Miniconda3-latest-Linux-x86_64.sh << HEREDOC

yes
/root/miniconda3
no

HEREDOC
source /root/miniconda3/bin/activate
