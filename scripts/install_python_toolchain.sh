#bin/bash
# has to be run from root of the repo
set -x
set -e

virtualenv --python=/usr/local/bin/python3 ${PWD}/deps/env
source ${PWD}/deps/env/bin/activate

python_scripts=deps/env/bin

function make_windows_exec_link {
  targetname=$1/`basename $2 .exe`
  echo "#!/bin/sh" > $targetname
  echo "$2 \$@" >> $targetname
}

function linux_patch_sigfpe_handler {
if [[ $OSTYPE == linux* ]]; then
        targfile=deps/local/include/pyfpe.h
        echo "#undef WANT_SIGFPE_HANDLER" | cat - $targfile > tmp
        mv -f tmp $targfile
fi
}


function download_file {
  # detect wget
  echo "Downloading $2 from $1 ..."
  if [ -z `which wget` ] ; then
    if [ -z `which curl` ] ; then
      echo "Unable to find either curl or wget! Cannot proceed with
            automatic install."
      exit 1
    fi
    curl $1 -o $2
  else
    wget $1 -O $2
  fi
} # end of download file

haspython=0
if [ -e deps/env/bin/python ]; then
        haspython=1
fi

if [[ $haspython == 0 ]]; then
        if [[ $OSTYPE == darwin* ]]; then
                if [[ ${PYTHON_VERSION} == "python3.4m" ]]; then
                        echo "Not supported yet"
                        exit 1
                elif [[ ${PYTHON_VERSION} == "python3.5m" ]]; then
                        echo "Not supported yet"
                        exit 1
                else
                        virtualenv deps/env
                        source deps/env/bin/activate
                        echo "skip conda"
                fi
        else
                if [[ ${PYTHON_VERSION} == "python3.4m" ]]; then
                        echo "Not supported yet"
                        exit 1
                elif [[ ${PYTHON_VERSION} == "python3.5m" ]]; then
                        echo "Not supported yet"
                        exit 1
                else
                        virtualenv deps/env
                        source deps/env/bin/activate
                        echo "skip conda"
                fi
        fi
fi
if [[ $OSTYPE == darwin* ]]; then
        echo "Install pip requirement!"
        $python_scripts/pip install -r scripts/pip_mac_requirements.txt
        $python_scripts/pip freeze
else
        # Need pip>=8.1 to support linux manywheel so that scikit-learn will install without error
        $python_scripts/pip install --upgrade "pip>=8.1"
        $python_scripts/pip install -r scripts/pip_linux_initial_requirements.txt
        $python_scripts/pip install -r scripts/pip_linux_requirements.txt
fi

mkdir -p deps/local/lib
mkdir -p deps/local/include

pushd deps/local/include
for f in `ls ../../env/include/python2.7/*`; do  
  ln -Ffs $f
done
popd

mkdir -p deps/local/bin
pushd deps/local/bin
for f in `ls ../../env/bin`; do
  ln -Ffs $f
done
popd

linux_patch_sigfpe_handler

