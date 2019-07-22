#!/usr/bin/perl 
use Data::Dumper;
$Data::Dumper::Sortkeys = 1;

if($#ARGV<1){
        print "*******************************************\nSyntax:GTEx_edit.pl input_annotation_file id_names";
           exit;
}

$file = $ARGV[0];
$id_file=$ARGV[1];

open (INPUT, $file);
@annot = <INPUT>;
close(INPUT);

#process the input annotations

foreach $line (@annot){
	$line =~ s/\n//g;
	@line=split('\t', $line);
	$this_ga=$line[2];
	$this_rs=$line[6];
	
	push(@all_rs, $this_rs);
	
	$convert{$this_ga}=$this_rs;
	
}
#print Dumper \%convert;

#process the ID names file
open(INPUT, $id_file);
@id_inp=<INPUT>;
close(INPUT);


foreach $line(@id_inp){
	$line =~ s/\n//g;
	@line = split('\t', $line);
	$this_ens = $line[0];
	$this_name = $line[1];
	$ens_name{$this_ens}=$this_name;
}

#print Dumper \%ens_name;

#Open all the gz.out files and process them as well
opendir my $dir, "/dors/capra_lab/projects/gwas_allele_age_evolution/data/GTEx/GTEx_Analysis_v7_eQTL/done" or die "Cannot open directory: $!";
my @files = readdir $dir;
closedir $dir;

#print Dumper \@files;

shift(@files);
shift(@files);
#get rid of . and ..;

#For each SNP we want to know 
	#How many tissues 
	#List of Tissues
	#How many genes
	#list of genes
	#list of tissue/gene matches

foreach $gt_file (@files){
	#print $gt_file;
	#open the file
	open(INPUT, "done/$gt_file") or die "Cannot open $gt_file";
	@gt_res=<INPUT>;
	close(INPUT);
	
	@tissue = split('\.', $gt_file);
	$this_tissue=$tissue[0];
		
	foreach $line (@gt_res){
		@line = split('\t', $line);
		
		$this_id= $line[0];
		$this_ens=$line[1];
		
		#remove the version from the ens
		@this_ens = split('\.', $this_ens);
		$this_ens = $this_ens[0];
		
		$this_rs = $convert{$this_id};
		$this_gene = $ens_name{$this_ens};
		
		if(exists $rs_tissue{$this_rs}{$this_tissue}){
			#do nothing
		}else{
			$rs_tissue{$this_rs}{$this_tissue}=1;	
		}
		
		if(exists $rs_gene{$this_rs}{$this_gene}){
			#do nothing
			#could tally the total?
		}else{
			$rs_gene{$this_rs}{$this_gene}=1;
		}
		
		$this_full = "$this_rs\t$this_tissue\t$this_gene\n";
		$full_res_hash{$this_rs}{$this_full}=1;
		push(@full_results, $this_full);
	}
	#print Dumper \%rs_gene;
	#print Dumper \%rs_tissue;
	#exit;
}

#count the number of tissues and genes per rs
#get the list of tissues and genes per rs
#get the number of unique eQTLs
#check to see if utural eQTL?

push(@final_results, "rsID\teQTL_tissue_num\teQTL_tissue_list\teQTL_gene_num\teQTL_gene_list\teQTL_Uterus\ttotal_eQTL\n");

foreach $rs (@all_rs){
	#num tissues
	$this_num_tiss=scalar(keys %{$rs_tissue{$rs}});
	
	@this_list_tiss=keys (%{$rs_tissue{$rs}});
	$this_list_tiss = join(",",@this_list_tiss); 
	#print "$this_list_tiss\n";
	
	$this_num_genes=scalar(keys %{$rs_gene{$rs}});
	@this_list_genes=keys(%{$rs_gene{$rs}});
	$this_list_genes=join(',',@this_list_genes);
	#print "$this_list_genes\n";
	
	if(exists $rs_tissue{$rs}{"Uterus"}){
		#print "$rs UTERUS\n";	
		$is_uterus = 1;
	}else{
		$is_uterus = 0;
	}
	
	#total number of eQTLs (gene X tissue)
	
	$this_num_eQTL = scalar(keys %{$full_res_hash{$rs}});
	#print "$rs\t$this_num_eQTL\n";
	
	push(@final_results, "$rs\t$this_num_tiss\t$this_list_tiss\t$this_num_genes\t$this_list_genes\t$is_uterus\t$this_num_eQTL\n");
	
}

#print Dumper \@final_results;


#print Dumper \%rs_gene;
#print Dumper \%rs_tissue;


open FILE, ">", "GTEx_results.txt";
print FILE @final_results;
close FILE;

open FILE, ">" , "full_GTEx_results.txt";
print FILE @full_results;
close FILE;

