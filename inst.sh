#!/bin/bash
wget https://raw.githubusercontent.com/nikalexey/archinstall/master/inst_log.sh
chmod +x inst_log.sh
./inst_log.sh 2>&1 | tee /tmp/install.log