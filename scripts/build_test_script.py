#!/usr/bin/env python
"""
Build the bash test running script
"""
import os

def main():
    """ Take the environment variables from arguments and print the script """
    lib_dir =  os.environ.get("LIB_DIR", "lib")
    test_dir = os.environ.get("TEST_DIR", "test")
    work_dir = os.environ.get("WORK_DIR", "/kb/module/work/tmp")
    service_caps = os.environ.get("SERVICE_CAPS", "kb_djornl")
    print(f"""
#!/bin/bash
script_dir=$(dirname "$(readlink -f "$0")")
export KB_DEPLOYMENT_CONFIG=$script_dir/../deploy.cfg
export KB_AUTH_TOKEN=`cat /kb/module/work/token`
echo "Removing temp files..."
rm -rf {work_dir}/*
echo "...done removing temp files."
export PYTHONPATH=$$script_dir/../{lib_dir}:$PATH:$PYTHONPATH
cd $script_dir/../{test_dir}
python -m nose --with-coverage --cover-package={service_caps} --cover-html --cover-html-dir=/kb/module/work/test_coverage --nocapture  --nologcapture .
$script_dir/coverage-export.sh
"""[1:-1])

if __name__ == "__main__":
    main()
