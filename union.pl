#! env perl

use strict;
use warnings;
use Getopt::Long;

my $input1;
my $input2;
my $col1;
my $col2;
my $header;
my $output;
my $num_arg  = scalar @ARGV;

my $result = GetOptions(
	"input1|1=s"      => \$input1,
	"input2|2=s"      => \$input2,
	"col1|c=s" => \$col1,
	"col2|d=s" => \$col2,
	"header|H=s" => \$header,
	"output|o=s" => \$output,
);

my $usage = <<END;

This script takes two tab delimited files and merge them based on shared column(s).

Usage: $0 --input1=FILENAME  --input2=FILENAME --col1=INT(,INT,INT...) --col2=INT(,INT,INT...) --header=INT --output=FILENAME

  --input1|-1 (FILENAME): name of first input file. Must be a tab delimited file. MANDATORY.
  --input2|-2 (FILENAME): name of second input file. Must be a tab delimited file. MANDATORY.
  --output|-o (FILENAME): name of output file (default STDOUT).
  --col1|-c (List of INT): list of column numbers used to merge the file. (default: 1).
  --col2|-d (List of INT): list of column numbers used to merge the file. (default: 1).
  --header|H (INT): number of header lines. (default: none).

END

##########################################################################################
################################### Checking parameters

die $usage if (@ARGV);
die $usage if (! $result);
die $usage if ( $num_arg < 2 );

die "$input1: File not found" unless(-f $input1);
die "$input2: File not found" unless(-f $input2);

$col1=1 unless(defined $col1);
$col2=1 unless(defined $col2);
$header=0 unless(defined $header);

die "Bad column name entry: $col1" unless($col1 =~ m/\d(,\d)?+/);
die "Bad column name entry: $col2" unless($col2 =~ m/\d(,\d)?+/);

##########################################################################################
################################### MAIN
my %input1 = &readFile($input1, $col1, $header);
my %input2 = &readFile($input2, $col2, $header);

my $out;
if(defined $output){
	open($out, ">".$output) or die "Cannot open file $output: $!";
}else{
	open($out, '>&', STDOUT ) or die "Cannot open standard out: $!";
}

##### Printing Headers
for (my $i=1; $i <= $header; $i++){
	my $index = $input1{'header_'.$i}{'name'};
	$index =~ s/__/\t/g;
	print $out "$index";
	print $out join "\t", @{$input1{'header_'.$i}{'data'}};
	print $out "\t";
	print $out join "\t", @{$input2{'header_'.$i}{'data'}};
	print $out "\n";
	delete $input1{"header_".$i};
	delete $input2{"header_".$i};
}

##### getting length of each of the two tables
##### This is used to fill non matched rows
my ($key, $value)= each %input1;
my $tabLength1 = scalar @{$value};

($key, $value)= each %input2;
my $tabLength2 = scalar @{$value}-1;

##### Printing results
foreach my $key1 (keys %input1){
	my $keyBis1 = $key1;
	$keyBis1 =~ s/__/\t/g;

	print $out $keyBis1;

	#print $input1{$key1}."\n";
	print $out join "\t", @{$input1{$key1}};
	print $out "\t";
	if(defined $input2{$key1} ){
		print $out join "\t", @{$input2{$key1}};
		delete $input2{$key1};
	}else{
		my $tabs = ("\t") x $tabLength2;
		print $out $tabs;
	} 
	print $out "\n";
}

foreach my $key2 (keys %input2){
	my $keyBis2 = $key2;
	$keyBis2 =~ s/__/\t/g;

	print $out $keyBis2;

	if($input1{$key2}){
		print $out join "\t", @{$input1{$key2}};
		print $out "\t";


	}else{
		#my @nbCol = split ',', $col1; 
		#my $nbCol = scalar @nbCol;
		my $tabs = ("\t") x ($tabLength1);
		print $out $tabs;
		
	} 

	print $out join "\t", @{$input2{$key2}};
	print $out "\n";	
}

close $out;

##########################################################################################
################################### FUNCTION

##### Reading input file
sub readFile{
	my ($file, $col, $header)=@_;

	my %index;

	open(FIC, "<".$file) or die "Cannot open file $file: $!";
	while(<FIC>){
		chomp;
		my @tab = split "\t";
		my @cols = split ",", $col; 
		my $index = "";

		## Creating the common field for merge
		foreach my $c (@cols){
			$index.=$tab[$c-1]."__";
		}

		## Removing joint columns so that they don't appear twice in the final table	
		@tab = &dropRows($col,@tab);

		if($. <= $header){
			$index{"header_$."}{'name'}=$index;
			$index{"header_$."}{'data'}=\@tab;
		}else{
			$index{$index}=\@tab;
		}
		
	}
	close(FIC);
	return(%index);
}

sub dropRows{
	my ($cols, @tab) = @_;
	my @cols = split ",", $cols;

	my $nbDroppedRow = 0;
	foreach my $c (@cols){
		splice(@tab, $c-1-$nbDroppedRow, 1);
		$nbDroppedRow++;
	}
	return @tab;
}


























