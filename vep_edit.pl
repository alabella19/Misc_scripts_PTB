#!/usr/bin/perl
use Data::Dumper;

if($#ARGV<0){
        print "*******************************************\nSyntax:VEP_edit.pl vep_output.txt";
           exit;
}

$file = $ARGV[0];

open (INPUT, $file);
@vep = <INPUT>;
close(INPUT);

shift(@vep);

foreach $line (@vep){
	#print $line;
	#$line = s/\n//g;
	@line = split('\t',$line);
	#print Dumper \@line;
	
	$this_rs = $line[0];
	$this_cons = $line[3];
	$this_gene = $line[5];
	#print "this rs $this_rs has $this_cons at $this_gene\n";
	#exit;
	
	#sometimes the cons has more than 1
		
	if($this_cons =~ /,/){
		#print "$this_cons has more than 1\n";
		@these_cons = split(',',$this_cons);
		foreach $this_cons (@these_cons){
			$this_gene_cons = "$this_gene.$this_cons";
			$all_gene_cons{$this_rs}{$this_gene_cons}=1;
			$all_cons{$this_rs}{$this_cons}=1;
		}
	}else{
	
		$this_gene_cons = "$this_gene.$this_cons";
		$all_gene_cons{$this_rs}{$this_gene_cons}=1;
		$all_cons{$this_rs}{$this_cons}=1;
	}
}

push(@out_array, "rs	intron_variant	upstream_gene_variant	5_prime_UTR_variant	regulatory_region_variant	downstream_gene_variant	intergenic_variant	synonymous_variant	missense_variant	non_coding_transcript_exon_variant	3_prime_UTR_variant	TF_binding_site_variant	splice_region_variant	non_coding_transcript_variant	NMD_transcript_variant\n");

@all_rs = keys (%all_cons);

foreach $rs (@all_rs){
	
	$this_line = "$rs\t";
	if(exists($all_cons{$rs}{"intron_variant"})){
		$this_line=$this_line."1	";
	}else{
		$this_line=$this_line."0	";
	}
	if(exists($all_cons{$rs}{"upstream_gene_variant"})){
		$this_line=$this_line."1	";
	}else{
		$this_line=$this_line."0	";
	}
	if(exists($all_cons{$rs}{"5_prime_UTR_variant"})){
		$this_line=$this_line."1	";
	}else{
		$this_line=$this_line."0	";
	}
	if(exists($all_cons{$rs}{"regulatory_region_variant"})){
		$this_line=$this_line."1	";
	}else{
		$this_line=$this_line."0	";
	}
	if(exists($all_cons{$rs}{"downstream_gene_variant"})){
		$this_line=$this_line."1	";
	}else{
		$this_line=$this_line."0	";
	}
	if(exists($all_cons{$rs}{"intergenic_variant"})){
		$this_line=$this_line."1	";
	}else{
		$this_line=$this_line."0	";
	}
	if(exists($all_cons{$rs}{"synonymous_variant"})){
		$this_line=$this_line."1	";
	}else{
		$this_line=$this_line."0	";
	}
	if(exists($all_cons{$rs}{"missense_variant"})){
		$this_line=$this_line."1	";
	}else{
		$this_line=$this_line."0	";
	}
	if(exists($all_cons{$rs}{"non_coding_transcript_exon_variant"})){
		$this_line=$this_line."1	";
	}else{
		$this_line=$this_line."0	";
	}
	if(exists($all_cons{$rs}{"3_prime_UTR_variant"})){
		$this_line=$this_line."1	";
	}else{
		$this_line=$this_line."0	";
	}
	if(exists($all_cons{$rs}{"TF_binding_site_variant"})){
		$this_line=$this_line."1	";
	}else{
		$this_line=$this_line."0	";
	}
	if(exists($all_cons{$rs}{"splice_region_variant"})){
		$this_line=$this_line."1	";
	}else{
		$this_line=$this_line."0	";
	}
	if(exists($all_cons{$rs}{"non_coding_transcript_variant"})){
		$this_line=$this_line."1	";
	}else{
		$this_line=$this_line."0	";
	}
	if(exists($all_cons{$rs}{"NMD_transcript_variant"})){
		$this_line=$this_line."1	";
	}else{
		$this_line=$this_line."0	";
	}


	$this_line = $this_line."\n";
	
	push(@out_array, $this_line);
}


#print Dumper \@out_array;


open FILE, ">" , "vep_consequences.out";
print FILE @out_array;
close FILE;


#make a file of the gene by consequence data

#print Dumper \%all_gene_cons;

print Dumper \@all_rs;

foreach $rs (@all_rs){
	
	@gene_cons = keys %{$all_gene_cons{$rs}};
	$gene_cons = join(";", @gene_cons);
	$gene_cons = "$rs\t".$gene_cons."\n";
	push(@out_gene_cons, $gene_cons);
		
}


open FILE, ">", "vep_gene_consequence.out";
print FILE @out_gene_cons;
close FILE;
