#!/bin/bash
#"***************************************************************************************************"
#  common initialization
#"***************************************************************************************************"

# select master or some GitHub hash version, and whether or not to force a clean
THIS_CHECKOUT=master
THIS_CLEAN=true

# perform some version control checks on this file
./gitcheck.sh $0

# initialize some environment variables and perform some sanity checks
. ./init.sh

# we don't want tee to capture exit codes
set -o pipefail

# ensure we alwaye start from the $WORKSPACE directory
cd "$WORKSPACE"
#"***************************************************************************************************"
# check for valid riscv32 compiler
#"***************************************************************************************************"
/opt/riscv32i/bin/riscv32-unknown-elf-gcc --version > /dev/null
$SAVED_CURRENT_PATH/check_for_error.sh $? "$THIS_LOG"


# TODO if already installed, prompt user


echo "***************************************************************************************************"
echo "  picorv32. Saving log to $THIS_LOG"
echo "***************************************************************************************************"
if [ ! -d "$WORKSPACE"/picorv32 ]; then
  git clone --recursive https://github.com/cliffordwolf/picorv32.git 2>&1 | tee -a "$THIS_LOG"
  $SAVED_CURRENT_PATH/check_for_error.sh $? "$THIS_LOG"
  cd picorv32
else
  cd picorv32
  git fetch                                                          2>&1 | tee -a "$THIS_LOG"
  git pull                                                           2>&1 | tee -a "$THIS_LOG"
  $SAVED_CURRENT_PATH/check_for_error.sh $? "$THIS_LOG"
fi

# we are still in ~/workspace/picorv32
# download tools. We can run this multiple times. the tools won't be blindly re-downloaded
make download-tools
$SAVED_CURRENT_PATH/check_for_error.sh $? "$THIS_LOG"

# install *all four* riscv flavor toolchains:
# make -j$(nproc) build-tools

cd $SAVED_CURRENT_PATH

echo "Completed $0 "                                                  | tee -a "$THIS_LOG"
