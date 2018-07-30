#!/bin/bash
INIT_FILE="/docker-first-run"

if [ ! -e $INIT_FILE ]; then
  echo "First run ..."
  # Add /root/bin to path
  if ! grep -Fq 'export PATH="/shared/scripts:$PATH"' ~/.bashrc ; then
    echo "Adding /shared/scripts to PATH"
    echo 'export PATH="/shared/scripts:$PATH"' >> ~/.bashrc
    source ~/.bashrc
  fi
  chmod -R +x /shared/scripts

  touch $INIT_FILE
fi
bash

