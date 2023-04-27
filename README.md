# doxyPEP_genomics
Data and code associated with "A genomic perspective on the near-term impact of doxycycline post-exposure prophylaxis on Neisseria gonorrhoeae antimicrobial resistance"

## data

* doxyPEP_QCpassing.tsv:
All accessions and metadata for isolates with assemblies passing quality control thresholds.

* gisp2018_QCpassing_resistance_alleles.tsv:
Metadata for isolates sequenced as part of Reimche et al. 2021 study from CDC's GISP surveillance including presence/absence of resistance alleles.

### gubbins
Directory contains tree output from Gubbins (see snakemake_pipelines for specific command). Additional gubbins output available upon request as the files are too large for storage on GitHub.

* isolates_with_tetMICS.node_labelled.final_tree.tre: Recombination corrected phylogeny of Neisseria gonorrhoeae high-quality genomes with tetracycline MICs.

### itol
TSVs used to annotate tree with ITOL, including resistance alleles, tetracycline MICs, and geography. Tree can be visualized at https://itol.embl.de/tree/134174250158349781673367540

## figures

* doxyPEP_coresistance.pdf: PDF of Figure 1

* tet_resistance_regions.pdf: PDF of Supplementary Figure 1

## scripts

* demography_geography.R: Script to identify prevalence of tetracycline resistance across geographic regions and demographic groups in the United States. Produces Supplementary Figure 1.

* identity_coresistance.R: Script to identify prevalence of co-resistance between tetracycline and other antimicrobials. Produces Figure 1.

* tetracycline_mics.R: Script to identify isolates with unexplained susceptibility and resistance.

## snakemake_pipelines

### assembly/snakemake_pipeline
Pipeline for genome assembly, mapping to reference genome, and identification of resistance allele presence/absence

### gubbins
Pipeline for running gubbins
