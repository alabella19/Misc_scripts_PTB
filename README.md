# Misc_scripts_PTB
Miscellaneous Scripts used in the publication XXX et al XX

---

# GTeX data processing 

GTeX annotations were stored in a single file: GTex_annotations_only.txt

These annotations were then extracted from each tissue file:

`for gz in *txt.gz; do echo $gz; cat GTEx_annotations_only.txt | while read line; do zcat $gz | grep "$line" >> "$gz.out"; done; done`

A perl script was used to extract the relevant data from the GTeX files.

This file would need to be edited with the location of the output from the previous step

`GTEx_edit.pl input_annotation_file id_names`

---

# Extract Haploreg data

Script to extract the important information from filtered haploreg data

`haploreg_edit.pl edited_haploreg_results.txt`

---

# Haplotype Blocks for Haplotype networks 

Use VCFtools and PLINK to get the haplotype blocks from the 1KG data

`vcftools --gzvcf ALL.chr20.phase3_shapeit2_mvncall_integrated_v5a.20130502.genotypes.vcf.gz --plink --out chr20.plink`
`plink --file chr20.plink --blocks no-pheno-req --out chr20.blocks`

Then VCFtools was used to obtain the variants in specific blocks using the IMPUTE option

---

#Calcuating iHS, xp-EHH using rehh

Requires vcftools, R and the rehh R package
https://cran.r-project.org/web/packages/rehh/index.html

Step 1: Convert 1KG VCF to data applicable for rehh

note: This step takes A LONG TIME. 

`impute_to_hap.pl input_1KG.vcf.gz`

Step 2: run rehh on the thap and inp data from Step 1

`Rscript rehh_run.R file.thap file.inp`

Step 3: calculate ihs for each population

`Rscript res_to_ihs.R file.res`

Step 4: calculate xp-EHH between populations of interest

`Rscript res_to_xpehh.R pop1.res pop2.res`

---

# Extract and Edit VEP data

`vep_edit.pl filtered_VEP_Data.txt`



