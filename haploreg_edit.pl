#!/usr/bin/perl

if($#ARGV<0){
        print "*******************************************\nSyntax:haploreg_edit.pl edited_haploreg_results.txt";
           exit;
}

$file = $ARGV[0];

open (INPUT, $file);
@haploreg = <INPUT>;
close(INPUT);

$header = shift(@haploreg);

$header =~ s/\n//g;
$header = $header."\tphm_num\tphm_plcnt\tphm_ovry\tphm_crvx\tehm_num\tehm_plcnt\tehm_ovry\tehm_crvx\tdnase_num\tdnase_plcnt\tdnase_ovry\tdnase_crvx\tpb_num\tmc_num\n";
push(@new_array, $header);

foreach $line (@haploreg){
	
	$new_line = $line;
	$new_line =~ s/\n//g;
	
	@line = split('\t', $line);
	
	#Promoter_histone_marks at 11
	$phm = $line[11];
	if($phm ne ""){
		if($phm =~ /PLCNT/){
			$phm_plcnt = 1;
		}else{
			$phm_plcnt = 0;
		}
		
		if($phm =~ /OVRY/){
			$phm_ovry = 1;
		}else{
			$phm_ovry = 0;
		}
		
		if($phm =~ /CRVX/){
			$phm_crvx = 1;
		}else{
			$phm_crvx = 0;
		}
		
		
		@phm = split(',',$phm);
		$num_phm = scalar(@phm);
		
	}else{
		$num_phm = 0;
		$phm_plcnt = 0;
		$phm_ovry = 0;
		$phm_crvx = 0;
	}

	#Enhancer_histone_marks at 12
	$ehm = $line[12];
	if($ehm ne ""){
		if($ehm =~ /PLCNT/){
			$ehm_plcnt = 1;
		}else{
			$ehm_plcnt = 0;
		}
		
		if($ehm =~ /OVRY/){
			$ehm_ovry = 1;
		}else{
			$ehm_ovry = 0;
		}
		
		if($ehm =~ /CRVX/){
			$ehm_crvx = 1;
		}else{
			$ehm_crvx = 0;
		}
		
		
		@ehm = split(',',$ehm);
		$num_ehm = scalar(@ehm);
		
	}else{
		$num_ehm = 0;
		$ehm_plcnt = 0;
		$ehm_ovry = 0;
		$ehm_crvx = 0;
	}
	
	
	#DNAse at 13
	$dnase = $line[13];
	if($dnase ne ""){
		if($dnase =~ /PLCNT/){
			$dnase_plcnt = 1;
		}else{
			$dnase_plcnt = 0;
		}
		
		if($dnase =~ /OVRY/){
			$dnase_ovry = 1;
		}else{
			$dnase_ovry = 0;
		}
		
		if($dnase =~ /CRVX/){
			$dnase_crvx = 1;
		}else{
			$dnase_crvx = 0;
		}
		
		
		@dnase = split(',',$dnase);
		$num_dnase = scalar(@dnase);
		
	}else{
		$num_dnase = 0;
		$dnase_plcnt = 0;
		$dnase_ovry = 0;
		$dnase_crvx = 0;
	}
	
	#proteins bound at 14
	
	$pb = $line[14];
	if($pb ne ""){
		$pb = split(',',$pb);
		$num_pb = scalar($pb);
	}else{
		$num_pb = 0;
	}
	
	#Motifs_changed 15
	$mc = $line[15];
	if($mc ne ""){
		$mc = split(',',$mc);
		$num_mc = scalar($mc);
	}else{
		$num_mc = 0;
	}
	
	$new_line = $new_line."\t$num_phm\t$phm_plcnt\t$phm_ovry\t$phm_crvx";
	$new_line = $new_line."\t$num_ehm\t$ehm_plcnt\t$ehm_ovry\t$ehm_crvx";
	$new_line = $new_line."\t$num_dnase\t$dnase_plcnt\t$dnase_ovry\t$dnase_crvx";
	$new_line = $new_line."\t$num_pb\t$num_mc\n";
	push(@new_array,$new_line);
}


open FILE, ">" , "haploreg.out";
print FILE @new_array;
close FILE;

