#!/usr/bin/perl -w
#
# Routine ensures that the incoming pdb file has the chain ID specified
# and then writes out a new pdb file with the residue numbers 
#

use FileHandle;
use strict;
use English;
use Data::Dumper;

my $file = $ARGV[0];
my $chain = $ARGV[1];
$chain = uc $chain;
if(length $chain > 1 || length $chain==0)
{
	print "You must specify a single chain\n";
	exit(70);
}

#ok, we're going to read the file and check that the chains are all found
#and renumber the residues so each chaing is sequentially numbered (including
#and numbering disjunctions.

my $fhInput = new FileHandle($file, "r");

my $chains_found = 0;
my $res_zero_found = 0;
my $line_count =0;
my $blank_chain = 0;
my $hChainData = {};
while(my $line = $fhInput->getline)
{
	$line_count++;
	
	if($line =~ /^ATOM/)
	{
		
		my $chaintest = substr $line, 21, 1;
		if($chaintest =~ /\s/)
		{
			print "Chain ID not listed in pdb ATOM records. Correct the PDB file to include the chain ID";
			exit(80);
		}
		my $resType = substr $line, 17, 3;
		my $pdbchain = substr $line, 21, 1;
		my $resNum = substr $line, 22, 4;
		$resNum =~ s/\s+//;
		#print $pdbchain." ".$resNum." ".$resType."\n";
		$hChainData ->{$pdbchain}{$resNum}= $resType;
		if($pdbchain =~ /^$chain$/)
		{
			$chains_found = 1;
		}
	}
}
#print Dumper $hChainData;
#exit;

$fhInput->close;
#ok we've got here and we have a list of residues, what's the lowest residue for each chain?
foreach my $testchain (keys %$hChainData)
{
	$hChainData->{$testchain}{LOWEST} = 0;
	foreach my $resNum (keys %{$hChainData->{$testchain}})
	{
		if($resNum =~ /LOWEST/){next;}
		if($hChainData->{$testchain}{LOWEST} == 0)
		{
			$hChainData->{$testchain}{LOWEST} = $resNum;
		}
		my $lowvalue = $hChainData->{$testchain}{LOWEST};
		if($resNum < $lowvalue)
		{
			$hChainData->{$testchain}{LOWEST} = $resNum;
		}
	}
}
print $hChainData->{$chain}{LOWEST}."\n";

#now we can rewrite the pdb file
$fhInput = new FileHandle($file, "r");
my $tmp_pdb = $file;
$tmp_pdb =~ s/\.pdb$/.tmp/;
print $tmp_pdb."\n";
my $fhOut = new FileHandle($tmp_pdb,"w");
while(my $line = $fhInput->getline)
{
	$line_count++;
	if($line =~ /^(ATOM.{17})(\w\s*)(\d+)(\s+.+)$/)
	{
		my $leadchunk = $1;
		#print $leadchunk."\n";
		my $chainchunk = $2;
		my $resNum = $3;
		if($resNum == 0)
		{
			$res_zero_found = 1;
		}
		my $trailingchunk = $4;
		$resNum =~ s/\s+//;
		
		my $chaintmp = $chainchunk;
		$chaintmp =~ s/\s+//;
		
		my $subtractor = ($hChainData->{$chaintmp}{LOWEST})-1;
		$resNum = $resNum-$subtractor;
		my $formattedNum = sprintf("%4d", $resNum);
		$line = $leadchunk.$chaintmp.$formattedNum.$trailingchunk."\n";
	}
	print $fhOut $line;
	
}
$fhInput->close;
$fhOut->close;

if($res_zero_found == 1)
{
	`rm $tmp_pdb`;
	print "PDB file contained ATOM records for a residue numbered Zero. This is not valid";
	exit(80);

}

if($chains_found == 1)
{
	print "All Chains Found\n";
	`mv $tmp_pdb $file`;
	exit;
}
else
{
	`rm $tmp_pdb`;
	print "The following specified chain or chains were not found in the provided pdb file: ".$chain;
	exit(80);
}
