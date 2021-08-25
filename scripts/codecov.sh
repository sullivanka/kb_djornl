#!/bin/bash

set -e
set -x

curl https://keybase.io/codecovsecurity/pgp_keys.asc | gpg --import # One-time step

curl -Os https://uploader.codecov.io/latest/linux/codecov

curl -Os https://uploader.codecov.io/latest/linux/codecov.SHA256SUM

curl -Os https://uploader.codecov.io/latest/linux/codecov.SHA256SUM.sig

gpg --verify codecov.SHA256SUM.sig codecov.SHA256SUM

shasum -a 256 -c codecov.SHA256SUM

chmod +x codecov

cd /kb/module
curl -s https://codecov.io/env | bash
CI=true
./test/codecov -t ${CODECOV_TOKEN}
