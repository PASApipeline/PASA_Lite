package main;
our $CLUSTERPATH;


package SingleLinkageClusterer;

## package not to be instantiated.  Just provides a namespace.

## Input: Array containing array-refs of pairs:
##               @_ = ( [1,2], [2,3], [6,7], [7,8], ...)
## Output: Array of all clusters as array-refs.
##              return ([1,2,3] , [6,7,8], ...)

use strict;
use Carp;

our $JACCARD_COEFF;
our $MIN_LINKS_EACH;
our $DEBUG;
our $USE_LEIDEN;

sub build_clusters {
    my @pairs = @_;
    
    my $uniq_stamp = "$$." . time() . "." . rand();
    my $pairfile = "/tmp/$uniq_stamp.pairs";
    
    #must do mapping because cluster program doesn't like word chars, just ints.
    my %map_id_to_feat; 
    my %map_feat_to_id;
    my $id = 1;
    
    open (PAIRLIST, ">$pairfile") or die "Can't write $pairfile to /tmp";
    foreach my $pair (@pairs) {
        my ($a, $b) = @$pair;
        unless ($map_feat_to_id{$a}) {
            $map_feat_to_id{$a} = $id;
            $map_id_to_feat{$id} = $a;
            $id++;
        }
        unless ($map_feat_to_id{$b}) {
            $map_feat_to_id{$b} = $id;
            $map_id_to_feat{$id} = $b;
            $id++;
        }
        
        print PAIRLIST "$map_feat_to_id{$a} $map_feat_to_id{$b}\n";
    }
    close PAIRLIST;
    
    my $clusterfile = "/tmp/$uniq_stamp.clusters";
    
    my $cmd;

    if ($USE_LEIDEN) {
        
        $cmd = "Leiden_cluster_pairs.py --pairs $pairfile > $clusterfile ";
        
    }
    else {

        
        my $cluster_prog = "slclust"; 
        if ($CLUSTERPATH) {
            $cluster_prog = $CLUSTERPATH;
        }
        
        if ($JACCARD_COEFF) {
            $cluster_prog .= " -j $JACCARD_COEFF";
            
            if ($MIN_LINKS_EACH) {
                $cluster_prog .= " --min_links_for_J $MIN_LINKS_EACH ";
            }
        }
        
        system "touch $clusterfile";
        unless (-w $clusterfile) { die "Can't write $clusterfile";}
        
        $cmd = "ulimit -s unlimited && $cluster_prog < $pairfile > $clusterfile";

    }
    
    if ($DEBUG) {
        print STDERR "CMD: $cmd\n";
    }    
    
    my $ret = system ($cmd);
    if ($ret) {
        confess "ERROR: Couldn't run cluster properly via $cmd\n";
    }
    
    my @clusters;
    open (CLUSTERS, $clusterfile);
    
    while (my $line = <CLUSTERS>) {
        my @elements;
        while ($line =~ /(\d+)\s?/g) {
            push (@elements, $map_id_to_feat{$1});
        }
        if (@elements) {
            push (@clusters, [@elements]);
        }
    }
    
    close CLUSTERS;
    
    ## clean up
    unless($DEBUG) { 
        unlink ($pairfile, $clusterfile);
    }
    
    return (@clusters);
}


############
## Testing
###########

sub __run_test {
    
    my @pairs = ( [1,2], [2,3], [4,5] );

    my @clusters = &SingleLinkageClusterer::build_clusters(@pairs);

    use Data::Dumper;
    
    print "Input: " . Dumper(\@pairs);
    print "Output: " . Dumper(\@clusters);

    exit(0);
}



1;
