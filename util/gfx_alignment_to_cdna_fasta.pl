#!/usr/bin/env perl

use strict;
use warnings;
use Carp;

use FindBin;
use lib ("$FindBin::Bin/../PerlLib");
use GFF3_alignment_utils;
use GTF_alignment_utils;
use Fasta_retriever;

my $usage = "usage: $0 trans_align.[gtf|gff3] genome.fasta\n\n";

my $trans_align_file = $ARGV[0] or die $usage;
my $genome_fasta = $ARGV[1] or die $usage;

unless ($trans_align_file =~ /\.(gff3|gtf)$/i) {
    die "Error, need .gtf or .gff3 alignment file";
}

main: {

    my %cdna_alignments;
    
    print STDERR "-parsing $trans_align_file\n";
    
    my %scaff_to_cdna_ids;
    if ($trans_align_file =~ /\.gff3$/i) {
        %scaff_to_cdna_ids = &GFF3_alignment_utils::index_alignment_objs($trans_align_file, \%cdna_alignments);
    }
    else {
        # GTF file
        %scaff_to_cdna_ids = &GTF_alignment_utils::index_alignment_objs($trans_align_file, \%cdna_alignments);
    }
    
    print STDERR "-reading genome sequence\n";
    my $fasta_retriever = new Fasta_retriever($genome_fasta);

    print STDERR "-outputting cdna sequences\n";
    foreach my $scaff (keys %scaff_to_cdna_ids) {

        my $chr_seq = $fasta_retriever->get_seq($scaff);
        
        foreach my $cdna_id (@{$scaff_to_cdna_ids{$scaff}}) {

            my $cdna_obj = $cdna_alignments{$cdna_id};

            my $spliced_seq = $cdna_obj->extractSplicedSequence(\$chr_seq);

            my $gene_id = $cdna_obj->{gene_id} || "";
            
            my $record = ">$cdna_id";
            if ($gene_id) {
                $record .= " $gene_id";
            }
            $record .= "\n$spliced_seq\n";
            
            print $record;
        }
    }
    

    exit(0);
}


