package Fasta_retriever_faidx;

use strict;
use warnings;
use Carp;


our $DEBUG = 0;

sub new {
    my ($packagename) = shift;
    my $filename = shift;
    
    unless ($filename) {
        confess "Error, need filename as param";
    }

    my $self = { filename => $filename };
                
    bless ($self, $packagename);

    $self->_init();


    return($self);
}


sub _init {
    my $self = shift;
    
    my $filename = $self->{filename};
    
    # use a samtools faidx index if available
    my $index_file = "$filename.fai";
    if (! -s $index_file) {
        my $cmd = "samtools faidx $filename";
        my $ret = system($cmd);
        if ($ret) {
            confess("Error, cmd: $cmd died with ret $ret"); 
        }
    }
    
    return;
}




sub get_seq {
    my $self = shift;
    my $acc = shift;

    unless (defined $acc) {
        confess "Error, need acc as param";
    }

    my $filename = $self->{filename}; 

    my $cmd = "samtools faidx $filename \"$acc\"";
    my $fasta_entry = `$cmd`;
    if ($?) {
        confess "Error, cmd: $cmd died with ret: $?";
    }
    my @pts = split(/\n/, $fasta_entry);
    shift @pts; # remove header
    my $seq = join("", @pts);
    $seq =~ s/\s+//;

    return($seq);
    
}

    

1; #EOM
    
