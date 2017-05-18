#!/bin/bash

# This script installs tauloa 
# instructions copied from http://evtgen.warwick.ac.uk/static/srcrep/setupEvtGen.sh

soft="TAUOLA-${TAUOLA_VERSION}"
install_prefix=$SIMPATH_INSTALL
checkfile=$install_prefix/lib/libTauolaCxxInterface.so
osArch=`uname`
INSTALL_BASE=$SIMPATH/generators

if (not_there $soft $checkfile); then
 if [ ! -d  $SIMPATH/generators/TAUOLA ]; then
  cd $SIMPATH/generators
  download_file $TAUOLA_LOCATION/TAUOLA.$TAUOLA_VERSION/TAUOLA.$TAUOLA_VERSION.tar.gz
  tar -xzf TAUOLA.$TAUOLA_VERSION.tar.gz
  # Patch TAUOLA on Darwin (Mac), ignore whitespace (-l)
  if [ "$osArch" == "Darwin" ]; then
   patch -l -p0 < tauola_Darwin.patch
   patch -l -p0 < tauola_Darwin_f77_photos.patch
   patch -l -p0 < tauola_Darwin_f77_tauola.patch
  fi

  echo Installing TAUOLA
  cd TAUOLA/
  ./configure --with-hepmc=$SIMPATH_INSTALL --prefix=$SIMPATH_INSTALL
  make
  make install
 fi

 if [ "$platform" = "macosx" ];
 then
    cd $install_prefix/lib
    create_links dylib so
 fi

 check_all_libraries $install_prefix/lib
 check_success $soft $checkfile
 check=$?

fi

cd $SIMPATH

return 1
