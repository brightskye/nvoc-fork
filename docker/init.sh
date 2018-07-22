#!/bin/bash
INIT_FILE="/docker-first-run"

if [ ! -e $INIT_FILE ]; then
  echo "First run ..."
  # Add /root/bin to path
  if ! grep -Fq 'export PATH="/root/bin:$PATH"' ~/.bashrc ; then
    echo "Adding /root/bin to PATH"
    echo 'export PATH="/root/bin:$PATH"' >> ~/.bashrc
    source ~/.bashrc
  fi
  chmod +x ~/bin/configure

  touch $INIT_FILE
fi
bash

