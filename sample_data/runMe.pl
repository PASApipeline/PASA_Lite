#!/usr/bin/env perl

use strict;
use warnings;

use FindBin;
use lib ("$FindBin::Bin/../PerlLib");
use Pipeliner;


main: {

    my $pipeliner = new Pipeliner(-verbose => 2);

    # validate alignments:
    
    my $cmd = "../PASA.alignmentValidator --genome genome_sample.fasta --transcripts transcripts.fasta gmap.spliced_alignments.gff3";
    $pipeliner->add_commands(new Command($cmd, "pasa_lite.valid_alignments.gtf.ok") );


    # assemble the valid alignments
    
    $cmd = "../PASA.alignmentAssembler pasa_lite.valid_alignments.gtf";
    $pipeliner->add_commands(new Command($cmd, "pasa_lite.pasa_assembled_alignments.gtf.ok"));
    
    # output transcripts in fasta format
    
    $cmd = "../util/gfx_alignment_to_cdna_fasta.pl pasa_lite.pasa_assembled_alignments.gtf genome_sample.fasta > pasa_lite.pasa_assembled_alignments.fasta";
    $pipeliner->add_commands(new Command($cmd, "pasa_lite.pasa_assembled_alignments.fasta.ok"));


    $pipeliner->run();

    print STDERR "\nDone.\n\n";
    
    exit(0);
}
                             
                             
    
