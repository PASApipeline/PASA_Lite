#!/usr/bin/env perl

use strict;
use warnings;

my $usage = "\n\n\tusage: $0 gmap.gene.gff3\n\n";

my $gmap_gene_gff3 = $ARGV[0] or die $usage;


main: {


    open (my $fh, $gmap_gene_gff3) or die "Error, cannot open file $gmap_gene_gff3";
    while (<$fh>) {
        if (/^\#/) { next; }
        chomp;
        my @x = split(/\t/);

        if ($x[2] eq "exon") {
            $x[2] = "cDNA_match";
            $x[8] =~ s/\.exon\d+;/;/;
            print join("\t", @x) . "\n";
        }
    }
    close $fh;

    exit(0);
}



