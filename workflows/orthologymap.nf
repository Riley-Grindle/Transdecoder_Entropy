
/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    PRINT PARAMS SUMMARY
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/


/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    CONFIG FILES
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/



/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    IMPORT LOCAL MODULES/SUBWORKFLOWS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

//
// SUBWORKFLOW: Consisting of a mix of local and nf-core/modules
//

include { ORTHOFINDER } from '../modules/local/orthofinder.nf'
include { EGGNOGMAPPER } from '../modules/local/eggnogmapper.nf'
include { TREEGRAFTER } from "../modules/local/treegrafter.nf"
include { ORTHOLOGER } from "../modules/local/orthologer.nf"
include { PRE_PROC } from "../modules/local/pre_proc_refs.nf"
include { PREP_INPUT } from "../modules/local/prep_input.nf"
include { POST_PROC } from "../modules/local/post_proc.nf"
include { STAGE_OUTS } from "../modules/local/stage_outs.nf"
include { PANTHER_API } from "../modules/local/panther_api.nf"
include { COLLECT_CHUNKS } from "../modules/local/collect_chunks.nf"
include { CUSTOM_DUMPSOFTWAREVERSIONS } from "../modules/nf-core/custom/dumpsoftwareversions/main"
include { GUNZIP as GUNZIP_REF } from "../modules/local/gunzip.nf"
include { GUNZIP as GUNZIP_IN } from "../modules/local/gunzip.nf"
include { GFFREAD } from "../modules/local/gffread/main"
include { BLASTP } from "../modules/local/blastp.nf"
include { DAGCHAINER } from "../modules/local/dagchainer.nf"

include { TRANSDECODER } from "../subworkflows/transdecoder.nf"
include { TRANSDECODER as REF_TRANSDECODER } from "../subworkflows/transdecoder.nf"


/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    RUN MAIN WORKFLOW
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

// Info required for completion email and summary
def multiqc_report = []

workflow ORTHOLOGYMAP {

    ch_versions  = Channel.empty()

    ch_input_fa  = Channel.of(params.input)
                        .map { [[id: params.project_id], it] }
    ch_input_gtf = Channel.of(params.gtf)
                        .map { [[id: params.project_id], it] }
    ch_input     = ch_input_gtf.join(ch_input_fa)

    GUNZIP_IN( ch_input ) 

    ch_fasta = Channel.empty()

    ch_query_tx  = GUNZIP_IN.out.fasta
    ch_query_gtf = GUNZIP_IN.out.gtf
    ch_query_tx.join(ch_query_gtf)
                .set { ch_query_tx_gtf }


    TRANSDECODER(
        ch_query_tx_gtf,
        params.pfam,
        params.project_id
    )
    .peptide_fasta.set { ch_fasta }
}

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    COMPLETION EMAIL AND SUMMARY
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/



/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    THE END
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/
