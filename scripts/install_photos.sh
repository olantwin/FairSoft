#!/bin/bash

# This script installs photos 
# instructions copied from http://evtgen.warwick.ac.uk/static/srcrep/setupEvtGen.sh

soft="PHOTOS-${PHOTOS_VERSION}"
install_prefix=$SIMPATH_INSTALL
checkfile=$install_prefix/lib/libPhotospp.so
osArch=`uname`
INSTALL_BASE=$SIMPATH/generators

if (not_there $soft $checkfile); then
 if [ ! -d  $SIMPATH/generators/PHOTOS ]; then
  cd $SIMPATH/generators
  # curl -O http://photospp.web.cern.ch/photospp/resources/PHOTOS.3.61/PHOTOS.3.61.tar.gz
  download_file $PHOTOS_LOCATION/PHOTOS.$PHOTOS_VERSION/PHOTOS.$PHOTOS_VERSION.tar.gz
  tar -xzf PHOTOS.$PHOTOS_VERSION.tar.gz
  # Patch PHOTOS on Darwin (Mac)
  if [ "$osArch" == "Darwin" ]; then
   patch -p0 < photos_Darwin.patch
  fi

  echo Installing PHOTOS
  cd PHOTOS/
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
