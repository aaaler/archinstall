#!/bin/bash
#wget https://raw.githubusercontent.com/aaaler/archinstall/master/inst_log.sh
#wget https://raw.githubusercontent.com/aaaler/archinstall/master/chroot_inst.sh
chmod +x inst_log.sh
./inst_log.sh 2>&1 | tee /tmp/install.log
