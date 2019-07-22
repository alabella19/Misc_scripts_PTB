#!/usr/bin/perl
#use lib '/home/labellal/perl5/lib/perl5';
#use Data::Dumper;
#$Data::Dumper::Sortkeys = 1;

###This script takes the results from the --impute vcf and creates the haploytpe files needed for ress (in R)
if($#ARGV<0){
	print "*******************************************\nSyntax: vcf.gz \n\n\n";
	exit;
}



$vcf_file = $ARGV[0];
print "running impute_to_hap.pl\n";

#IMPUT VCF FILE
$prefix = $vcf_file;
$prefix=~ s/.vcf.gz//;

#impute for each population
#pops are
#AFR
#CEU
#EAS
#EUR
#YRI

`vcftools --gzvcf $vcf_file --derived --keep AFR.pop --IMPUTE --out AFR.$prefix`;
#`vcftools --gzvcf $vcf_file --derived --keep CEU.pop --IMPUTE --out CEU.$prefix`;
`vcftools --gzvcf $vcf_file --derived --keep EAS.pop --IMPUTE --out EAS.$prefix`;
#`vcftools --gzvcf $vcf_file --derived --keep EUR.pop --IMPUTE --out EUR.$prefix`;
`vcftools --gzvcf $vcf_file --derived --keep YRI.pop --IMPUTE --out YRI.$prefix`;

#GET CHROMOSOME NUM
@chrom_num=split('\.',$prefix);
$chrom_num=$chrom_num[1];
$chrom_num=~s/chr//;

#print "chromosome is $chrom_num\n";

#Get just RS and AA value from the original vcf file
#can't use VCF tools cause we lose the 

`vcftools --gzvcf $vcf_file --get-INFO AA --out AA.$prefix`;

open(INPUT, "AA.$prefix.INFO");
@AA_input = <INPUT>;
close(INPUT);

#remove header
shift(@AA_input);

print "starting SNP processing\n";
%AA_hash;
foreach $line (@AA_input){
	if($line =~ /unknown/ || $line =~ /\?/ || $line=~/cryptic_indel/){
		#SKIP
		$line=~s/\n//g;
		@line=split('\t',$line);
		$this_pos=$line[1];
		$this_AA=$line[4];
		$this_ref=$line[2];
		$this_alt=$line[3];
		$AA_hash{$this_pos}=0;	
	}else{
		$line=~s/\n//g;
		@line=split('\t',$line);
		$this_pos=$line[1];
		$this_AA=$line[4];
		$this_ref=$line[2];
		$this_alt=$line[3];
		
		
		
		if($this_AA ne "?"){
			#print("AA:$this_AA|ref:$this_ref|alt:$this_alt\n");
			@this_AA=split('\|',$this_AA);
			$AA_type=$this_AA[3];
			$AA_ref=$this_AA[1];
			$AA_alt=$this_AA[2];
			$this_AA=$this_AA[0];
			#print("AA:$this_AA|AA_ref:$AA_ref|AA_alt:$AA_alt\n");
			if($this_AA eq "." || $this_AA eq "-"){
				#this has no ref allele	- no alignment
				if(exists($AA_hash{$this_pos})){
					$AA_hash{$this_pos}=0;		
				}
			}else{
				if($AA_ref eq ""){
					#this is not an insertion or deletion and we can just take the AA
					$this_AA = uc $this_AA;
					if(exists($AA_hash{$this_pos})){
						$AA_hash{$this_pos}=0;		
					}else{
						$AA_hash{$this_pos}=$this_AA;
					}
				}else{
					#print("insertion or deletion for $this_pos\nstarting AA=$this_AA\nstarting ref=$this_ref\n");
					#print("starting alt=$this_alt\nAA_ref=$AA_ref\nAA_alt=$AA_alt\n");
					if(length($AA_ref)>length($AA_alt)){
						#ALT is shorter
						#remove alt from all
						$new_AA=$this_AA;
						#print("altered_AA1:$new_AA\n");
						$new_AA=~s/$AA_alt//iee;
						#will either get "" or will get a single base					
					}else{
						#ref is shorter
						#remove alt from all
						$new_AA=$this_AA;
						#print("altered_AA2:$new_AA\n");
						$new_AA=~s/$AA_ref//iee;
						#will either get "" or will get a single base			
					}
					#print("altered_AA:$new_AA\n");
					if($new_AA eq ""){
						#gap is ancestral!
						if(length($this_ref) > length($this_alt)){
							$this_AA = $this_alt;
							if(exists($AA_hash{$this_pos})){
									$AA_hash{$this_pos}=0;		
							}else{
								$AA_hash{$this_pos}=$this_AA;
							}
							#print("new_AA=$this_AA\n");
						}else{
							$this_AA = $this_ref;
							if(exists($AA_hash{$this_pos})){
									$AA_hash{$this_pos}=0;		
							}else{
								$AA_hash{$this_pos}=$this_AA;
							}
							#print("new_AA=$this_AA\n");
						}
					}else{
						#gap is NOT ancestral
						if(length($this_ref) < length($this_alt)){
							$this_AA = $this_alt;
							if(exists($AA_hash{$this_pos})){
									$AA_hash{$this_pos}=0;		
							}else{
								$AA_hash{$this_pos}=$this_AA;
							}
							#print("new_AA=$this_AA\n");
						}else{
							$this_AA = $this_ref;
							if(exists($AA_hash{$this_pos})){
									$AA_hash{$this_pos}=0;		
							}else{
								$AA_hash{$this_pos}=$this_AA;
							}
							#print("new_AA=$this_AA\n");
						}
						
					}
					
				}
			}
		}else{
			#this has a question mark so no AA
		}
	}
}
print "Done processing SNPs\n";
#print Dumper \%AA_hash;
#exit;
#@all_pops=("AFR","CEU","EAS","EUR","YRI");

@all_pops=("AFR");

foreach $pop (@all_pops){
	
	@out_array=();
	@inp_file=();
	
	print("processing pop $pop\n");	
	open (INPUT, "$pop.$prefix.impute.legend") || die "cannot open file $pop.$prefix.impute.legend\n";
	@all_legend = <INPUT>;
	close(INPUT);
	#remove header from legend file
	shift(@all_legend);
	@inp_file=();
	$n=0;
	foreach $line (@all_legend){
		$line =~ s/\n//g;
		@line = split('\s', $line);
		$this_rs=$line[0];
		$this_pos = $line[1];
		$this_a1=$line[2]; #equals 0 in the haps file
		$this_a2=$line[3]; #equals 1 in the haps file
		
		#need to figure out which allele is ancestral
		if(exists $AA_hash{$this_pos}){
			if($AA_hash{$this_pos} eq 0){
				#print "Duplicate RS $this_rs at $this_pos\n";
			}else{
				$this_anc=$AA_hash{$this_pos};
				if($this_anc eq $this_a1){
					$this_der=$this_a2;
					$new_line = "$this_rs\t$chrom_num\t$this_pos\t$this_anc\t$this_der\n";
					push(@inp_file,$new_line);
					$zero_hash{$n}=$this_a1;
					$one_hash{$n}=$this_a2;
				}elsif($this_anc eq $this_a2){
					$this_der=$this_a1;	
					$new_line = "$this_rs\t$chrom_num\t$this_pos\t$this_anc\t$this_der\n";
					push(@inp_file,$new_line);
					$zero_hash{$n}=$this_a1;
					$one_hash{$n}=$this_a2;
				}else{
					#print "Mismatched anc for $this_rs at $this_pos\t";
					#print "stored anc $this_anc doesn't match $this_a1 or $this_a2\n";
				}
				

			}
			
		}else{
			#skip this ... no ancestral allele!	
			#print "no ancestral allele for $this_rs at $this_pos\n";
		}
		
		#print "$n\n";
		$n=$n+1;
	}
	
	#print Dumper \%one_hash;
	#Open and process the hap file
	open (INPUT, "$pop.$prefix.impute.hap") || die "cannot open file $pop.$prefix.legend\n";
	@all_hap = <INPUT>;
	close(INPUT);
	
	@out_array=();
	$n=0;
	foreach $line (@all_hap){
		if(exists $zero_hash{$n}){
			#this line has an ancestral allele
			#need to change the 0|1 to $this_a0 or $this_a1;
			$this_a0=$zero_hash{$n};
			$this_a1=$one_hash{$n};
			
			#print "line before $line";
			$line=~s/0/$this_a0/eeg;
			$line=~s/1/$this_a1/eeg;
			#print "line after $line";
			push(@out_array, $line);
		}
		#print "$this_a0\t$n\n";
		
		#print "replace:$n\n";
		$n=$n+1;
		
	}
	open FILE, ">" , "$pop.$prefix.thap";
	print FILE @out_array;
	close FILE;
	
	open FILE, ">" , "$pop.$prefix.inp";
	print FILE @inp_file;
	close FILE;
	
	
}

#




#open FILE, ">>" , "$all_file";
#print FILE @all_out;
#close FILE;
#








