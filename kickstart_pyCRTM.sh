#!/bin/bash
#simple script to kickstart pycrtm
#update python library
echo "installing required packages."

#If on discover source gnu modules.
if [[ $HOSTNAME == *"discover"* ]]; then
  echo "[kickstart]loading discover modules"
  source $MODULESHOME/init/bash
  module purge
  source pycrtm/discover_modules_gnu.sh
  ONDISCOVER=1
else
  ONDISCOVER=0
fi

#check for python version
if command -v python &> /dev/null
then
  pyversion="$(python -V 2>&1)"
else
  pyversion=""
fi

#check for python3 version
if command -v python3 &> /dev/null
then
  pyversion3="$(python3 -V 2>&1)"
else
  pyversion3=""
fi

# Check for valid python, set pip command
if [[ $pyversion == *"Python 3."* ]]; then
  PIPCMD="python -m pip install "
  PYCMD="python"
elif [[ $pyversion3 == *"Python 3."* ]]; then
  PIPCMD="python3 -m pip install "
  PYCMD=python3
else
  echo "No valid python3 install detected. Please install it, or source system module as needed."
  exit 1
fi 

if ! command -v ecbuild &> /dev/null
then
  echo "Ecbuild not detected. Please install it, or source system module as needed."
  exit 1
fi
# if on a mac, install globally in homebrew.
if ! command -v brew &> /dev/null
then
  PIPTARGET="--target ${LOCALPYTHON}"
  mkdir $PWD/python_modules
  LOCALPYTHON=$PWD/python_modules
  SED=sed
else
  PIPTARGET=""
  LOCALPYTHON=""
  SED=gsed
fi



#modify setup to put coefficients here.
${SED} -i "/crtm_install =/c\crtm_install = ${PWD}/crtm_v2.4.0" pycrtm/setup.cfg
${SED} -i "/path =/c\path = ${PWD}/pycrtm_coefficients/" pycrtm/setup.cfg
${SED} -i "/download =/c\download = True" pycrtm/setup.cfg
${SED} -i "/coef_with_install =/c\coef_with_install = False" pycrtm/setup.cfg

# install dependencies 
${PIPCMD} wheel scikit-build wheel scikit-build h5py matplotlib ${PIPTARGET} ${LOCALPYTHON}
echo "[kickstart] Appending ${LOCALPYTHON} to PYTHONPATH"
#check to see if PYTHONPATH already exists. create/append as needed
if [[ -z "${PYTHONPATH}" ]]; then
  export PYTHONPATH="${PWD}/python_modules"
else
  export PYTHONPATH="${PYTHONPATH}:${PWD}/python_modules"
fi

echo "[kickstart] done installing dependencies."
mkdir crtm_v2.4.0
cd crtm_v2.4.0
echo "[kickstart] making crtm in crtm-bundle/crtm_v2.4.0:"
ecbuild  --static ../
echo "[kickstart] compiling crtm:"
make -j8
cd ..

echo "[kickstart] installing pycrtm"
cd pycrtm
${PYCMD} setup.py bdist_wheel
${PIPCMD} dist/pyCRTM_JCSDA*.whl ${PIPTARGET} ${LOCALPYTHON}
echo "[kickstart] Running test case"
testCases/test_cris_threads.py

# Things the user must do to make it go.
if ! command -v brew &> /dev/null
then
  echo "Make sure to append ${PWD}/python_modules to your PYTHONPATH"
  echo "In bash this is: export PYTHONPATH=\"\${PYTHONPATH}:${PWD}/python_modules\""
  echo "In csh/tcsh this is: setenv PYTHONPATH \${PYTHONPATH}:${PWD}/python_modules\""

fi

if [[ ${ONDISCOVER} == 1 ]]; then
  echo "Also make sure to source pycrtm/discover_modules_gnu.sh for bash or pycrtm/discover_modules_gnu.csh for tcsh/csh."
fi
