#!/usr/bin/env python3

import sys
import leidenalg as la
import igraph as ig
import argparse


if __name__ == "__main__":

    parser = argparse.ArgumentParser(description="Leiden clustering of pairs",
                                     formatter_class=argparse.ArgumentDefaultsHelpFormatter)
    
    parser.add_argument("--pairs", type=str,
                        required=True, help="input file containing paired tokens representing edges between nodes")

    parser.add_argument("--pdf", type=str,
                        required=False, help="pdf filename for plotting the graph")

    parser.add_argument("--resolution", type=float, default=None,
                        help="if set, will run la.CPMVertexPartition with resolution parameter, otherwise uses la.ModularityVertexPartition")
    
    args = parser.parse_args()
    
    file_path = args.pairs
    plot_pdf = args.pdf
    resolution = args.resolution
    
    # Read data from file
    with open(file_path, 'r') as file:
        lines = file.readlines()

    data = [tuple(line.strip().split()) for line in lines]
        
    # Create a graph from the data
    edges = [(str(edge[0]), str(edge[1])) for edge in data]
    graph = ig.Graph.TupleList(edges, directed=False)
    
    # Perform Leiden clustering
    if resolution is not None:
        partition = la.find_partition(graph, la.CPMVertexPartition,
                                    resolution_parameter = resolution)
    else:
        partition = la.find_partition(graph, la.ModularityVertexPartition)
    
    for part in partition:
        print(" ".join([str(graph.vs[x]['name']) for x in part]))
    
    if plot_pdf:
        ig.plot(partition, target=plot_pdf)
        
    
    sys.exit(0)


    
