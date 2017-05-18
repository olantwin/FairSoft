#!/bin/bash

#author: Ahmed El Alaoui, USM

# Check if the source tar file is already available 
# If not download it a from the log4cpp web server and unpack it

soft="log4cpp"
if [ ! -d  $SIMPATH/tools/$soft ]; then 
  cd $SIMPATH/tools
  if [ ! -e $SIMPATH/tools/$LOG4CPP_TAR ]; then
    echo "*** Downloading $soft sources ***"
    cd $SIMPATH/tools; download_file $LOG4CPP_LOCATION/$LOG4CPP_TAR; cd -
  fi
  untar $soft $SIMPATH/tools/$LOG4CPP_TAR
fi

install_prefix=$SIMPATH_INSTALL
checkfile=$install_prefix/lib/liblog4cpp.so

if (not_there $soft $checkfile); then

  mkdir $SIMPATH/tools/build_$soft
  cd $SIMPATH/tools/build_$soft

  debug_=""
  if [ "$debug" = "yes" ]; then
    debug_="--enable-debug"
  fi

  $SIMPATH/tools/$soft/configure --prefix=$install_prefix $debug_ \
              --enable-shared --enable-static --srcdir=$SIMPATH/tools/$soft
  $MAKE_command
  $MAKE_command install

  if [ "$platform" = "macosx" ];
  then
      cd $install_prefix/lib
      create_links dylib so
  fi

  check_all_libraries $install_prefix/lib
  check_success $soft $checkfile
  check=$?
fi

cd  $SIMPATH

return 1
