#!/bin/bash

if [ ! -d  $SIMPATH/generators/pythia8 ];
then
  cd $SIMPATH/generators
  if [ ! -e $PYTHIA8VERSION.tgz ];
  then
    echo "*** Downloading pythia8 sources ***"
    download_file $PYTHIA8_LOCATION/$PYTHIA8VERSION.tgz
  fi
  untar pythia8 $PYTHIA8VERSION.tgz
  if [ -d $PYTHIA8VERSION ];
  then
    ln -s $PYTHIA8VERSION pythia8
  fi
fi

install_prefix=$SIMPATH_INSTALL
checkfile=$install_prefix/lib/libpythia8.so

if [ ! -d $install_prefix/lib ];
then
  mkdir -p $install_prefix/lib
fi

if (not_there pythia8 $checkfile)
then

  cd $SIMPATH/generators/pythia8

if [ "$platform" = "macosx" ]; then
   # needed to link with correct gfortran run-time
   mypatch ../pythia8_Darwin.patch | tee -a $logfile
fi

#  USRLDFLAGSSHARED="$CXXFLAGS" ./configure  --enable-shared  --with-hepmc3-lib=$HEPINSTALLDIR/lib --with-hepmc3-include=$HEPINSTALLDIR/include  --with-hepmc3-version=$HEPMCVERSION  --with-lhapdf5-lib=$HEPINSTALLDIR/lib --with-lhapdf5-include=$HEPINSTALLDIR/include --with-lhapdf5-version=$LHAPDF_VERSION
  USRLDFLAGSSHARED="$CXXFLAGS" ./configure  --enable-shared  --with-hepmc2=$HEPINSTALLDIR --with-lhapdf5-lib=$HEPINSTALLDIR/lib --with-lhapdf5-include=$HEPINSTALLDIR/include --with-lhapdf5-version=$LHAPDF_VERSION --with-evtgen=$SIMPATH/generators/EvtGen/$EVTGEN_VERSION --with-evtgen-lib=$install_prefix/lib --with-evtgen-include=$install_prefix/include/EvtGen --with-evtgen-version=$EVTGEN_VERSION

  if [ "$compiler" = "PGI" ];
  then
    mysed "FC = gfortran" "FC = pgfortran" config.mk
    mysed "CC = gcc" "CC = pgCC" config.mk
    mysed "FFLAGS = -O2" "FFLAGS=${FFLAGS}" config.mk
    mysed "CFLAGS = -O2" "CFLAGS=${CFLAGS}" config.mk
    mysed "CXXFLAGS = -O2 -ansi -pedantic -W -Wall -Wshadow" "CXXFLAGS=${CXXFLAGS}" config.mk
    mysed "CXXFLAGSNO = -O2 -ansi -pedantic -W -Wall" "CXXFLAGSNO=${CXXFLAGS}" config.mk
    mysed "FLIBS = -lgfortran -lgfortranbegin" "" config.mk
    mysed "LDFLAGSSHARED = -O2 -ansi -pedantic -W -Wall -Wshadow -pthread -fPIC -shared" "LDFLAGSSHARED=${CXXFLAGS} -fPIC -shared " config.mk
  fi

  if [ "$system" = "64bit" ];
  then
   $MAKE_command -j$number_of_processes CFLAGS="$CFLAGS -m64" CXXFLAGS="$CXXFLAGS -m64"
  else
   $MAKE_command -j$number_of_processes CFLAGS="$CFLAGS" CXXFLAGS="$CXXFLAGS"
  fi
  
  mkdir -p $install_prefix/include
  cp -r include/Pythia8 $install_prefix/include
  cp -r include/Pythia8Plugins $install_prefix/include/Pythia8

  mkdir -p $install_prefix/share/pythia8
  if [ -d share/xmldoc ];
  then
   cp -rf share/xmldoc $install_prefix/share/pythia8
  elif [ -d share/Pythia8/xmldoc ];
  then
   cp -rf share/Pythia8/xmldoc $install_prefix/share/pythia8
  elif [ -d xmldoc ];
  then
   cp -rf xmldoc $install_prefix/share/pythia8
  else
   echo "Pythia8 data not found"
  fi
  if [ ! -d $install_prefix/share/pythia8/xmldoc ]
  then
    echo "Unexpected error occurred when trying to create the data directory for Pythia8"
  fi 
  if [ "$platform" = "macosx" ];
  then
    cp lib/libpythia8.dylib $install_prefix/lib
    #cp lib/liblhapdfdummy.dylib $install_prefix/lib
    cp lib/libpythia8*.so $install_prefix/lib
    cd $install_prefix/lib
    for file in $(ls libpythia8*.dylib); do
      install_name_tool -id $install_prefix/lib/$file $file
    done
    for file in $(ls libpythia8*.so); do
      install_name_tool -id $install_prefix/lib/$file $file
    done
    create_links dylib so
  else
    cp lib/libpythia8.so $install_prefix/lib
    #cp lib/liblhapdfdummy.so $install_prefix/lib
    cp -f lib/libpythia8*.so $install_prefix/lib
  fi

  check_all_libraries $install_prefix/lib

  check_success pythia8 $checkfile
  check=$?
fi

if [ "$platform" = "macosx" ];
then
  export DYLD_LIBRARY_PATH=$DYLD_LIBRARY_PATH:$install_prefix/lib
else
  export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$install_prefix/lib
fi

cd $SIMPATH

return 1
