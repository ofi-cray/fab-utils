#!/bin/bash
#
# Copyright (c) 2016 Cray Inc.  All rights reserved.
#
# This software is available to you under a choice of one of two
# licenses.  You may choose to be licensed under the terms of the GNU
# General Public License (GPL) Version 2, available from the file
# COPYING in the main directory of this source tree, or the
# BSD license below:
#
#     Redistribution and use in source and binary forms, with or
#     without modification, are permitted provided that the following
#     conditions are met:
#
#      - Redistributions of source code must retain the above
#        copyright notice, this list of conditions and the following
#        disclaimer.
#
#      - Redistributions in binary form must reproduce the above
#        copyright notice, this list of conditions and the following
#        disclaimer in the documentation and/or other materials
#        provided with the distribution.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AWV
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
# BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
# ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
# CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
#

debug=0
load_ccm_module="module load ccm"
ccm_login="ccmlogin"
ccm_login_script="`mktemp ${HOME}/ccm_login_fabtests_script.XXXXXX`"
fabtests_directory="`pwd`"
fabtests_cmd=""
provider="gni"
test_suite=""
use_parameters=0
verbose=""

usage() {
    ec=$1
    echo "ccm_runfabtests.sh [-d <directory>] [-D] [-p <provider>] [-t <test_suite>] [-u] [-v] [-vv] [-vvv]"
    echo "   -d libfabric tests location"
    echo "   -D print debug output"
    echo "   -p libfabric provider to use"
    echo "   -t libfabric test suite to execute"
    echo "   -u use parameters on runfabtests"
    echo "   -v verbose mode for runfabtests"
    exit $ec
}

if [ $# -gt 0 ] ; then
  while getopts "d:Dhp:t:uv:" option; do
    case $option in
      d) fabtests_directory=$OPTARG;;
      D) debug=1;;
      h) usage 0 ;;
      p) provider="$OPTARG";;
      t) test_suite="-t $OPTARG";;
      u) use_parameters=1;;
      v) verbose="${verbose} -v";;
      *) usage 1;;
    esac
  done
fi

#
# Check for ccmlogin
#
ccmlogin=`command -v ccmlogin`
if [ $? != 0 ]; then
    ${load_ccm_module}
    ccmlogin=`command -v ccmlogin`
    if [ $? != 0 ]; then
        echo "Error: CCM Login command not found.  Can Not execute the FAB tests."
        exit 1
    fi
fi

rm -f ${ccm_login_script}
cat > ${ccm_login_script} <<"END_OF_CCMLOGIN_SCRIPT_1"
#!/bin/bash

END_OF_CCMLOGIN_SCRIPT_1

echo "debug=${debug}" >> ${ccm_login_script}
echo "fabtests_directory='${fabtests_directory}'" >> ${ccm_login_script}
echo "provider='${provider}'" >> ${ccm_login_script}
echo "test_suite='${test_suite}'" >> ${ccm_login_script}
echo "use_parameters='${use_parameters}'" >> ${ccm_login_script}
echo "verbose='${verbose}'" >> ${ccm_login_script}

cat >> ${ccm_login_script} <<"END_OF_CCMLOGIN_SCRIPT_2"
node_1=""
node_2=""

ccm_login_node_dir="${HOME}/.crayccm/"
ccm_nodelist_file="${ccm_login_node_dir}/`ls ${ccm_login_node_dir}`"
node_index=0

if [[ ${debug} -ne 0 ]]
then
    echo "*** pid: $$, ccm_nodelist_file: '${ccm_nodelist_file}'"
fi

while read -r node_entry
do
    if [[ ${debug} -ne 0 ]]
    then
        echo "*** pid: $$, next node_index: '${node_index}'";
        echo "*** pid: $$, next node_entry: '${node_entry}'";
    fi
    if [[ ${node_index} -eq 0 ]]
    then
        if [[ ${use_parameters} -eq 0 ]]
        then
            node_1="${node_entry}"
        else
            node_1="-s ${node_entry}"
        fi
        node_index=1
        if [[ ${debug} -ne 0 ]]
        then
            echo "*** pid: $$, set node_1: '${node_1}'";
        fi
    else
        if [[ "${node_1}" != "${node_entry}" ]]
        then
            if [[ ${use_parameters} -eq 0 ]]
            then
                node_2="${node_entry}"
            else
                node_2="-c ${node_entry}"
            fi
            if [[ ${debug} -ne 0 ]]
            then
                echo "*** pid: $$, set node_2: '${node_2}'";
            fi
            break
        fi
    fi
done <${ccm_nodelist_file}

if [[ "${node_2}" == "" ]]
then
        node_2="${node_1}"
fi

if [[ ${debug} -ne 0 ]]
then
    echo "*** pid: $$, final node_1: '${node_1}'"
    echo "*** pid: $$, final node_2: '${node_2}'"

fi

if [[ ${use_parameters} -eq 0 ]]
then
    fabtests_cmd="${fabtests_directory}/runfabtests.sh -p ${fabtests_directory} ${verbose} ${test_suite} ${provider} ${node_1} ${node_2}"
else
    fabtests_cmd="${fabtests_directory}/runfabtests.sh -p ${fabtests_directory} ${verbose} ${test_suite} ${node_1} ${node_2} ${provider}"
fi

if [[ ${debug} -ne 0 ]]
then
echo "*** cmd: '${fabtests_cmd}'"
fi

${fabtests_cmd}
ret=$?
if [[ ${debug} -ne 0 ]]
then
    if [ $ret == 0 ]
    then
        echo "*** runfabtests exited normally"
    else
        echo "*** Error: runfabtests exited abnormally: '$?'"
    fi
fi

exit $ret
END_OF_CCMLOGIN_SCRIPT_2

chmod 755 ${ccm_login_script}

if [[ ${debug} -ne 0 ]]
then
    echo "*** cmd: '${ccm_login} ${ccm_login_script}'"
fi

${ccm_login} ${ccm_login_script}

if [[ ${debug} -eq 0 ]]
then
    rm -f ${ccm_login_script}
fi
