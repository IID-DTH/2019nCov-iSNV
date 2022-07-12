#!/usr/bin/perl
$nt_freq=shift;
$type=shift;

$dep_cut=100;
$site_cut=3000;
$dep_alt_cut=4;
$freq_alt_cut=0.05;
$l=0;
$pos_count=0;
$isnv_count=0;
@to_print=();

open (F1,"$nt_freq");
while(<F1>){
	chomp;
	if($l ==0){
		$l++;
	}else{
		@items=split;
		$chr=$items[0];
		$pos=$items[1];
		$ref=$items[2];
		$dep{"A"}=$items[6];
		$dep{"G"}=$items[7];
		$dep{"C"}=$items[8];
		$dep{"T"}=$items[9];
		$dep_total=$items[10];
		
		$freq{"A"}=$items[11];
		$freq{"G"}=$items[12];
		$freq{"C"}=$items[13];
		$freq{"T"}=$items[14];
		
		($dep_5{"A"},$dep_3{"A"})=split("/", $items[15]);
		($dep_5{"G"},$dep_3{"G"})=split("/", $items[16]);
		($dep_5{"C"},$dep_3{"C"})=split("/", $items[17]);
		($dep_5{"T"},$dep_3{"T"})=split("/", $items[18]);
		
		if($dep_total >= $dep_cut){
			$pos_count++;
			@nuc_sort=sort {$dep{$b} <=> $dep{$a} } keys %dep;
		if($type eq "ref_alt"){
			if ($ref ne $nuc_sort[0]){
				$alt=$nuc_sort[0];
			}else{
				$alt=$nuc_sort[1];
			}
	#		print "$pos\t$ref\t$alt\t$dep_total\t$dep{$alt}\t$freq{$alt}\n";
			if($dep{$alt} > $dep_alt_cut and $freq{$alt} > $freq_alt_cut){
			#	print "$ref\t$alt\n";
				push @to_print,"$chr\t$pos\t$dep_total\t$ref\t$alt\t$freq{$alt}\t$dep{$alt}\t$dep_5{$ref}\t$dep_3{$ref}\t$dep_5{$alt}\t$dep_3{$alt}\n";
			$isnv_count++;
			}
		}elsif($type eq "major_minor"){
			$major=$nuc_sort[0];$minor=$nuc_sort[1];
			if($dep{$minor} > $dep_alt_cut and $freq{$minor} > $freq_alt_cut){
				push @to_print,"$chr\t$pos\t$dep_total\t$ref\t$major\t$minor\t$freq{$major}\t$dep{$major}\t$freq{$minor}\t$dep{$minor}\t$dep_5{$major}\t$dep_3{$major}\t$dep_5{$minor}\t$dep_3{$minor}\n";
			$isnv_count++;
			}
		}
		}
	}

}
close F1;

if($type eq "ref_alt"){
	print "sample\tchr\tpos\tdep_total\tref\talt\tfreq_alt\tdep_alt\tdep_5_ref\tdep_3_ref\tdep_5_alt\tdep_3_alt\n";
}elsif($type eq "major_minor"){
	print "sample\tchr\tpos\tdep_total\tref\tmajor_allele\tminor_allele\tfreq_major\tdep_major\tfreq_minor\tdep_minor\tdep_5_ref\tdep_3_ref\tdep_5_alt\tdep_3_alt\n";
}

if($pos_count > $site_cut){
	for $to_print (@to_print){
		print "$nt_freq\t".$to_print;
	}
}

print STDERR "$nt_freq\t$pos_count\t$isnv_count\n";
