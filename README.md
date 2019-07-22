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
