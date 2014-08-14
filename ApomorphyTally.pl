#!/usr/bin/perl

################################################################################
#  ApomorphyTally.pl
#  v. 1.0.1
#
#  Written by Matt Gitzendanner
#  University of Florida
#  Department of Botany and Florida Museum of Natural History
#  magitz@ufl.edu
#
#  This program takes the output from PAUP that descripes the apomorphies along
#  branches of a tree. The user provides this file, along with a file describing
#  the CHARSETs for different genes. The program parses the CHARSET information
#  and uses that to go through the apomorphy file tallying the numbers of 
#  apomorphies for each gene at each node.
#
#  History: 
# 		v. 1.0: 23 Sept. 2007
#		v. 1.0.1: 24 Sept. 2007
#			- Added initialization of @genetally
#			- Convert linebreaks to Unix for all input files
#
#  Use:
#    ApomorphyTally.pl takes 3 inputs in the following format and order:
#		1) The name of your log file. For best results this shouldn't have much
#			more than the output from the describe trees command. Other stuff 
#			could easily throw this program off and cause odd results.
#
#		2) The name of a file containing the CHARSETs for your genes. These
#			should be formatted something like:
#				CHARSET	atpB = 1 - 1497;
#			NOTE: This will only work on continuous blocks of characters and
#			starting and ending bases must be specified. This is written 
#			thinking about datasets of multiple genes. As it is written, it  
#			can't do things like tally 1st, 2nd and 3rd positions or things like 
#			that.
#           This file shouldn't have anything other than the CHARSET lines.
#
#		3) The name of an output file. This should not exist already as it will
#			be overwritten when the program runs.
#
# 	examples: $ ./ApomorphyTally.pl infile charfile outfile
#
################################################################################

use strict;
use warnings;

our $apofile = $ARGV[0];
our $chars = $ARGV[1];
our $outfile = $ARGV[2];

# Convert linebreaks to Unix style breaks
	my $conv;
	open FILE, $apofile or die "Can't open file: $apofile : $!";
	   my @conv=<FILE>;
	close FILE; 
	foreach $conv(@conv) {
		$conv=~ s/(\r\n|\n|\r)/\n/g;
	}
	open FILE, "> $apofile" or die "Can't open file: $apofile : $!";
		print FILE @conv;
	close FILE;
	
	open FILE, $chars or die "Can't open file: $chars : $!";
	   @conv=<FILE>;
	close FILE;
	
	foreach $conv(@conv) {
		$conv=~ s/(\r\n|\n|\r)/\n/g;
	}
	open FILE, "> $chars" or die "Can't open file: $chars : $!";
		print FILE @conv;
	close FILE;


our @genename;
our @genestart;
our @geneend;
our @nodes;
our @genetally;
our $genecount = 0;

# Deal with the output file
if (-e $outfile) {
	print "Output file, $outfile , already exists. OK to overwrite? (y/n): ";
	my $choice = <STDIN>;
	chomp $choice;
	
	if ($choice eq "y") {
		open OUTPUT, "> $outfile" or die "Can't open file for output: $outfile : $!";
			print OUTPUT "Starting to process your data files.\n\n";
		close OUTPUT;
	} else {
		print "Please use an output file that doesn't already exist.\n\n";
		END;
	}
}

# Open the charset file that contains the bp ranges for each gene.
# Parse each line of the file to get gene names, start and end
# base pair values for each gene.
open CHARS, $chars or die "Can't open file: $chars : $!";
	while (<CHARS>) {
		my @fields = split /=/, $_;
		my @name = split /\s/, $fields[0];
		$genename[$genecount] = $name[1];
		$genename[$genecount] =~ s/\s//g;
		my @bprange = split /-/, $fields[1]; 
		$genestart[$genecount] = $bprange[0];
		$genestart[$genecount] =~ s/\s//g;
		$geneend[$genecount] = $bprange[1];
		$geneend[$genecount] =~ s/\s//g;
		$geneend[$genecount] =~ s/\;//g;
		$genecount++;
	}
close CHARS;

open OUTPUT, ">> $outfile" or die "Can't open file for output: $outfile : $!";
	print OUTPUT "Here is the list of genes and there start and stop positions.\n";
	print OUTPUT "Please make sure I interpreted your input correctly.\n\n";
	my $i = 0;
	while ($i < $genecount) {
		print OUTPUT "Gene $genename[$i], starts at bp $genestart[$i], ends at bp $geneend[$i] \n";
		$genetally[$i] = 0;
		$i++;
	}
	print OUTPUT "\n\n";
	print OUTPUT "Gene tallies for each node:\n\n";

close OUTPUT;

open APOMORPHIES, $apofile or die "Can't open file: $apofile : $!";
	my $tallyApos = 0;
	while (<APOMORPHIES>) {
	
		my $node = 'node_';
		
		
		my @fields = split /\s+/, $_;
	
		if (($tallyApos == 1) and 				#If tallyApos was already on and line has node, turn it off and print output
			(substr( $fields[1], 0, 5) eq $node ) ) {
			$tallyApos = 0;
			open OUTPUT, ">> $outfile" or die "Can't open file for output: $outfile : $!";
			my $i = 0;
			while ($i < $genecount) {
				print OUTPUT "$genename[$i]\t $genetally[$i] \n";
				$genetally[$i] = 0;
				$i++;
			}
			print OUTPUT "\n";
			close OUTPUT;
		
		}
			
		if ( 									#If node --> node turn on tallApos and tally this line
			(substr( $fields[1], 0, 5) eq $node )
			and 
		  	(substr( $fields[3], 0, 5) eq $node ) 
		   ) {
			$tallyApos = 1;
			my $i = 0;
			while ( $i < $genecount ) {
				if ( ( $fields[4] >= $genestart[$i])
				  and ( $fields[4] <= $geneend[$i]) ) {
				  $genetally[$i]++;
				 
				  }
				$i++;
			}
			open OUTPUT, ">> $outfile" or die "Can't open file for output: $outfile : $!";
			print OUTPUT "$fields[1] --> $fields[3] \n";
		}
		
		if (($tallyApos == 1) and				#if tallyApos is on tally 
			(substr( $fields[1], 0, 5) ne $node ) ) {
			my $i = 0;
			while ($i < $genecount) {
				if ( ( $fields[1] >= $genestart[$i])
				  and ( $fields[1] <= $geneend[$i]) ) {
				  $genetally[$i]++;
				  }
				$i++
			}
		
		}
		
		
			
	}

close APOMORPHIES;




