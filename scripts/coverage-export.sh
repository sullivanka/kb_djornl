#!/bin/bash

echo << HEREDOC
This script copies the coverage report into the /data directory which is
mounted as a volume so that it will be accessible after the tests run.
HEREDOC

# remove exported coverage data if it exists
test -d /data/test_coverage && rm -rf /data/test_coverage
cp -r /kb/module/work/test_coverage /data/test_coverage
