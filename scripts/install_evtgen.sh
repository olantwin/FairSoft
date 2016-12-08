#!/bin/bash

# This script installs EvtGen with all external dependencies. The variable VERSION specifies
# the tag of EvtGen you want to use. The list of available tags can be found using either the 
# command "svn ls -v http://svn.cern.ch/guest/evtgen/tags" or by going to the url
# http://svn.cern.ch/guest/evtgen/tags in a web browser. Note that some earlier EvtGen versions
# will not be compatible with all external dependency versions given below, owing to C++
# interface differences; see the specific tagged version of the EvtGen/README file for guidance
osArch=`uname`
INSTALL_BASE=$SIMPATH/generators

# Version or tag number. No extraneous spaces on this line!
if [ ! -d  $SIMPATH/generators/EvtGen ];then
 cd $SIMPATH/generators
 mkdir -p EvtGen
 cd EvtGen

 echo Will setup EvtGen $EVTGEN_VERSION

 echo Downloading EvtGen from SVN
 svn export http://svn.cern.ch/guest/evtgen/tags/$EVTGEN_VERSION

 echo Building EvtGen $EVTGEN_VERSION
 cd $EVTGEN_VERSION
# -llhapdfdummy does not exist anymore for newer versions of Pythia8!
 mysed "-llhapdfdummy" " " configure
 tmp=$(locate gfortran)
 echo $tmp
 if [[ "$tmp" == *"gfortran"* ]];
 then 
   mysed "-lfrtbegin -lg2c" " " configure
 fi 
 ./configure --hepmcdir=$SIMPATH_INSTALL --photosdir=$SIMPATH_INSTALL --pythiadir=$SIMPATH_INSTALL --tauoladir=$SIMPATH_INSTALL
 make

 cp lib/libEvtGenExternal.so $SIMPATH_INSTALL/lib
 cp lib/libEvtGen.so $SIMPATH_INSTALL/lib

 if [ ! -d  $SIMPATH_INSTALL/share/EvtGen ];then
  mkdir -p $SIMPATH_INSTALL/share/EvtGen
 fi
 if [ ! -d  $SIMPATH_INSTALL/include/EvtGen ];then
  mkdir -p $SIMPATH_INSTALL/include/EvtGen
 fi
 cp *.XML $SIMPATH_INSTALL/share/EvtGen
 cp *.DEC $SIMPATH_INSTALL/share/EvtGen
 cp evt.pdl $SIMPATH_INSTALL/share/EvtGen
 cp -r EvtGen $SIMPATH_INSTALL/include/EvtGen/
 cp -r EvtGenBase $SIMPATH_INSTALL/include/EvtGen/
 cp -r EvtGenExternal $SIMPATH_INSTALL/include/EvtGen/
 cp -r EvtGenModels $SIMPATH_INSTALL/include/EvtGen/

 echo Setup done.
fi

cd $SIMPATH

return 1
