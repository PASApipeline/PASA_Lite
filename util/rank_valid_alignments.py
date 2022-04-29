#!/usr/bin/env python3

import sys, os, re
import pandas as pd
import argparse

def main():

    parser = argparse.ArgumentParser(description="rank valid alignments", formatter_class=argparse.ArgumentDefaultsHelpFormatter)

    parser.add_argument("--alignment_stats", type=str, required=True, help="alignment stats file")
    parser.add_argument("--out_prefix", type=str, required=True, help="output prefix file")

    args = parser.parse_args()

    alignment_stats_filename = args.alignment_stats
    out_prefix = args.out_prefix

    df = pd.read_csv(alignment_stats_filename, sep="\t")

    df = df[df['valid_status'] == "VALID"]

    df = df.sort_values(['cdna_acc', 'score'], ascending=[True, False])

    df['rank'] = df.groupby('cdna_acc')['score'].rank('first', False)

    df.to_csv(out_prefix + ".valid.ranked.tsv", sep="\t", index=False)

    df = df[ df['rank'] == 1]
    df.to_csv(out_prefix + ".valid.ranked.top_only.tsv", sep="\t", index=False)
    
    sys.exit(0)




if __name__=='__main__':
    main()
