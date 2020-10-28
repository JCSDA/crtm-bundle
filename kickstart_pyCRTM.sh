#simple script to kickstart pycrtm
cd crtm
echo "[kickstart] getting remote binary data."
sh Get_CRTM_Binary_Files.sh
cd ..
mkdir crtm_v2.4.0
cd crtm_v2.4.0
echo "[kickstart] making crtm in crtm-bundle/crtm_v2.4.0:"
ecbuild ../
echo "[kickstart] compiling crtm:"
make -j8
echo "[kickstart] linking to modules:"
ln -s `find ./ -name "crtm_module.mod" | sed 's/crtm_module.mod//'` ./include
cd ..
echo "[kickstart] installing pycrtm"
cd pycrtm
./setup_pycrtm.py  --install $PWD/../ --repos $PWD/../crtm/ --jproc 1 --coef ./ --ncpath /usr/local/ --h5path /usr/local/ --arch gfortran --inplace
echo "[kickstart] running a testcase."
./testCases/test_cris.py
echo "[kickstart] Read the README.md file for more information (note *_threads.py files currently not functional)."
