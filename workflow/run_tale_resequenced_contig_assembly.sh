#!/bin/bash

# Requires
# PBX_MUMMER_PATH
# PBX_SCRIPTS_PATH
# PBX_WORKFLOW_PATH
# PBX_PROTOCOL_TEMPLATES_PATH
# PBX_RESULTS_PATH_RESEQUENCING
# PBX_RESULTS_PATH_RESEQUENCED_CONTIG_ASSEMBLY

RESULTS_PATH=${PBX_RESULTS_PATH_RESEQUENCED_CONTIG_ASSEMBLY}
mkdir -p ${RESULTS_PATH}

minimo_resequenced_tals() {
    
    fprefix=`echo $1 | cut -c 21-`
    
    mkdir ${RESULTS_PATH}/${fprefix}
    cd ${RESULTS_PATH}/${fprefix}
    
    mkdir banks blast_contigs blast_singletons contigs singletons
    
    python2 ${PBX_SCRIPTS_PATH}/rename_fastx_seqs.py ${PBX_RESULTS_PATH_RESEQUENCING}/resequencing_output_${fprefix}/data/consensus.fastq combo
    python2 ${PBX_SCRIPTS_PATH}/convert_fastq_to_fasta.py combo.fastq combo.fasta y
    
    parallel --env PBX_PROTOCOL_TEMPLATES_PATH --env PBX_MUMMER_PATH < ${PBX_WORKFLOW_PATH}/run_minimo_nucmer_resequenced.sh
    
}

cd ${PBX_RESULTS_PATH_RESEQUENCING}

for f in resequencing_output_*; do
    
    echo $f
    minimo_resequenced_tals $f
    
done > ${RESULTS_PATH}/minimo_log.txt 2>&1