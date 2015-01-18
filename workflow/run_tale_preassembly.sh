#!/bin/bash

# Requires
# PBX_SCRIPTS_PATH
# PBX_SMRTANALYSIS_PATH
# PBX_RAW_READS_PATH
# PBX_WHITELISTING_RESULTS_PATH
# PBX_PROTOCOL_TEMPLATES_PATH
# PBX_PREASSEMBLY_MIN_SEED_READ_LENGTH
# PBX_PREASSEMBLY_MIN_SUBREAD_LENGTH
# PBX_PREASSEMBLY_MIN_TRIMMED_PREASSEMBLED_READ_LENGTH
# PBX_PREASSEMBLY_MIN_TRIMMED_PREASSEMBLED_READ_QV

SMRT_PATH_PREPEND="${PBX_SCRIPTS_PATH}/smrtanalysis"
source ${PBX_SMRTANALYSIS_PATH}/current/etc/setup.sh

RESULTS_PATH=${PBX_PREASSEMBLY_RESULTS_PATH}
mkdir -p ${RESULTS_PATH}

find ${PBX_RAW_READS_PATH} -name "*.bax.h5" | sort > ${RESULTS_PATH}/pbx_preassembly_input.fofn

WHITELIST_REPLACEMENT=$(echo "${PBX_WHITELISTING_RESULTS_PATH}" | sed -e 's/[\/&]/\\&/g')

cp ${PBX_PROTOCOL_TEMPLATES_PATH}/RS_PreAssembler_TALs.1.xml ${RESULTS_PATH}/pbx_preassembly_protocol.xml
sed -i "s/__PBX_WHITELISTING_RESULTS__/${WHITELIST_REPLACEMENT}/g" ${RESULTS_PATH}/pbx_preassembly_protocol.xml
sed -i "s/__PBX_PREASSEMBLY_MIN_SEED_READ_LENGTH__/${PBX_PREASSEMBLY_MIN_SEED_READ_LENGTH}/g" ${RESULTS_PATH}/pbx_preassembly_protocol.xml
sed -i "s/__PBX_PREASSEMBLY_MIN_SUBREAD_LENGTH__/${PBX_PREASSEMBLY_MIN_SUBREAD_LENGTH}/g" ${RESULTS_PATH}/pbx_preassembly_protocol.xml

fofnToSmrtpipeInput.py ${RESULTS_PATH}/pbx_preassembly_input.fofn --jobname="TALE_PreAssembly_Job" > ${RESULTS_PATH}/pbx_preassembly_input.xml
smrtpipe.py --params=${RESULTS_PATH}/pbx_preassembly_protocol.xml --output=${RESULTS_PATH} xml:${RESULTS_PATH}/pbx_preassembly_input.xml
python2 ${PBX_SCRIPTS_PATH}/smrtanalysis/trimFastqByQVWindow.py --qvCut=${PBX_PREASSEMBLY_MIN_TRIMMED_PREASSEMBLED_READ_QV} --minSeqLen=${PBX_PREASSEMBLY_MIN_TRIMMED_PREASSEMBLED_READ_LENGTH} ${RESULTS_PATH}/data/corrected.fastq > ${RESULTS_PATH}/data/corrected_${PBX_PREASSEMBLY_MIN_TRIMMED_PREASSEMBLED_READ_QV}_${PBX_PREASSEMBLY_MIN_TRIMMED_PREASSEMBLED_READ_LENGTH}.fastq
