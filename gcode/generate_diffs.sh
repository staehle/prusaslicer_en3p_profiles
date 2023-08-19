#!/bin/bash
set -eu
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
DIFF_DIR=${SCRIPT_DIR}/differences
ORIG="original.gcode"
MODF="modified.gcode"

cd ${SCRIPT_DIR}

if [ ! -d ${DIFF_DIR} ]; then
    echo "ERROR: ${DIFF_DIR} should preexist"
    exit 1
fi

difftypes=(start end tool_change)

echo "*** Generating diffs for: [${difftypes[@]}] in ${DIFF_DIR}"

echo "Removing old diffs..."
set -x
rm -rf ${DIFF_DIR}/*.diff
set +x

set +e
for difftype in "${difftypes[@]}"; do
    echo "  * Generating ${difftype} diff"
    set -x
    diff -uN ${difftype}/${ORIG} ${difftype}/${MODF} > ${DIFF_DIR}/${difftype}.diff
    set +x
done

echo "Done :)"