#!/bin/bash

# Check if the source tar file is already available
# If not download it a from the geant4 web server and
# unpack it

if [ ! -d  $SIMPATH/transport/geant4 ];
then
  cd $SIMPATH/transport
  git clone $GEANT4_LOCATION $GEANT4VERSION
  if [ -d $GEANT4VERSION ];
  then
    ln -s $GEANT4VERSION geant4
  fi
  cd $SIMPATH/transport/geant4
  version=${GEANT4VERSIONp/Geant4-/v}
  git checkout tags/$version -b $GEANT4VERSION
fi

# Full output during compilation and linking to check for the
# compile and link commands
#export CPPVERBOSE=1

install_prefix=$SIMPATH_INSTALL
clhep_exe=$SIMPATH_INSTALL/bin/clhep-config

checkfile=$install_prefix/lib/libG4physicslists.so

if (not_there Geant4-lib $checkfile);
then

  cd $SIMPATH/transport/geant4/

  if [ -f ../geant4_G4DecayTable.patch ]; then
    mypatch ../geant4_G4DecayTable.patch | tee -a $logfile
  fi

  if [ -f ../${GEANT4VERSION}_c++11.patch ]; then
    mypatch ../${GEANT4VERSION}_c++11.patch | tee -a $logfile
  fi

  if [ "$platform" = "linux" -a "$compiler" = "Clang" ]; then
    mypatch ../geant4.10.00_clang_linux.patch
  fi

  if [ "$platform" = "macosx" ]; then
    mypatch ../geant4.10.00_clang_osx.patch
    if [ -f ../${GEANT4VERSION}_cmake.patch ]; then
      mypatch ../${GEANT4VERSION}_cmake.patch
    fi
    if [ "$compiler" = "Clang" ]; then
      clang_vers=`clang -v 2>&1 >/dev/null | sed -n 's/Apple LLVM version//p' | cut -d . -f 1`
      if [ $clang_vers -ge 7 ]; then
        mypatch ../geant4.10.00_clang7_osx.patch
      fi
    fi
  fi

  if (not_there Geant4-build  build);
  then
    mkdir build
  fi
  cd build

  if [ "$geant4_download_install_data_automatic" = "yes" ];
  then
    install_data="-DGEANT4_INSTALL_DATA=ON"
  else
    install_data=""
  fi

  if [ "$build_cpp11" = "yes" ];
  then
    geant4_cpp="-DGEANT4_BUILD_CXXSTD=c++11"
  else
    geant4_cpp=""
  fi

  if [ "$build_python" = "yes" ];
  then
    geant4_opengl="-DGEANT4_USE_OPENGL_X11=ON -DGEANT4_USE_GDML=ON -DXERCESC_ROOT_DIR=$install_prefix"
  else
    geant4_opengl=""
  fi

  cmake -DCMAKE_INSTALL_PREFIX=$install_prefix \
        -DCMAKE_INSTALL_LIBDIR=$install_prefix/lib \
        -DCMAKE_CXX_COMPILER=$CXX \
        -DCMAKE_C_COMPILER=$CC \
        -DGEANT4_USE_G3TOG4=ON \
        -DGEANT4_BUILD_STORE_TRAJECTORY=OFF \
        -DGEANT4_BUILD_VERBOSE_CODE=ON \
        $geant4_opengl \
        $install_data  $geant4_cpp ../

  $MAKE_command -j$number_of_processes  install

  # copy the env.sh script to the bin directorry
  mkdir -p $install_prefix/bin
 # cp $G4WORKDIR/env.sh $install_prefix/bin

  if [ "$platform" = "macosx" ];
  then
    cd $install_prefix/lib
    create_links dylib so
  fi

  if [ "$geant4_download_install_data_automatic" = "yes" ];
  then
    # create unique links which is independent of the Geant4 version
    if [ -L $install_prefix/share/Geant4 ]; then
      rm  $install_prefix/share/Geant4 
    fi
    ln -s $install_prefix/share/$GEANT4VERSIONp $install_prefix/share/Geant4
    # create unique links for the data directories which are
    # independent of the actual data versions
    if [ -L $install_prefix/share/Geant4/data/G4ABLA ]; then
       rm $install_prefix/share/Geant4/data/G4ABLA
    fi
    ln -s $(find $install_prefix/share/Geant4/data -name 'G4ABLA*') $install_prefix/share/Geant4/data/G4ABLA 
    if [ -L $install_prefix/share/Geant4/data/G4EMLOW ]; then
       rm $install_prefix/share/Geant4/data/G4EMLOW
    fi
    ln -s $(find $install_prefix/share/Geant4/data -name 'G4EMLOW*') $install_prefix/share/Geant4/data/G4EMLOW 
    if [ -L $install_prefix/share/Geant4/data/G4ENSDFSTATE ]; then
      rm $install_prefix/share/Geant4/data/G4ENSDFSTATE
    fi
    ln -s $(find $install_prefix/share/Geant4/data -name 'G4ENSDFSTATE*') $install_prefix/share/Geant4/data/G4ENSDFSTATE    
    if [ -L $install_prefix/share/Geant4/data/G4NDL ]; then
     rm $install_prefix/share/Geant4/data/G4NDL
    fi
    ln -s $(find $install_prefix/share/Geant4/data -name 'G4NDL*') $install_prefix/share/Geant4/data/G4NDL    
    if [ -L $install_prefix/share/Geant4/data/G4NEUTRONXS ]; then
     rm $install_prefix/share/Geant4/data/G4NEUTRONXS
    fi
    ln -s $(find $install_prefix/share/Geant4/data -name 'G4NEUTRONXS*') $install_prefix/share/Geant4/data/G4NEUTRONXS   
    if [ -L $install_prefix/share/Geant4/data/G4PII ]; then
      rm $install_prefix/share/Geant4/data/G4PII
    fi
    ln -s $(find $install_prefix/share/Geant4/data -name 'G4PII*') $install_prefix/share/Geant4/data/G4PII  
    if [ -L $install_prefix/share/Geant4/data/G4SAIDDATA ]; then
     rm $install_prefix/share/Geant4/data/G4SAIDDATA
    fi
    ln -s $(find $install_prefix/share/Geant4/data -name 'G4SAIDDATA*') $install_prefix/share/Geant4/data/G4SAIDDATA    
    if [ -L $install_prefix/share/Geant4/data/PhotonEvaporation ]; then
     rm $install_prefix/share/Geant4/data/PhotonEvaporation
    fi
    ln -s $(find $install_prefix/share/Geant4/data -name 'PhotonEvaporation*') $install_prefix/share/Geant4/data/PhotonEvaporation   
    if [ -L $install_prefix/share/Geant4/data/RadioactiveDecay ]; then
      rm $install_prefix/share/Geant4/data/RadioactiveDecay
    fi
    ln -s $(find $install_prefix/share/Geant4/data -name 'RadioactiveDecay*') $install_prefix/share/Geant4/data/RadioactiveDecay   
    if [ -L $install_prefix/share/Geant4/data/RealSurface ]; then
     rm $install_prefix/share/Geant4/data/RealSurface
    fi
    ln -s $(find $install_prefix/share/Geant4/data -name 'RealSurface*') $install_prefix/share/Geant4/data/RealSurface
  fi

  . $install_prefix/share/$GEANT4VERSIONp/geant4make/geant4make.sh

  check_success geant4 $checkfile
  check=$?

else

  . $install_prefix/share/$GEANT4VERSIONp/geant4make/geant4make.sh

fi

cd  $SIMPATH
return 1
