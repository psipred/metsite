# Prerequisites

1. NCBI's BLAST+ suite
2. uniref90 seq database prepared for BLAST+
3. dssp. This is included in bin/ but you may need to download and compile the source

# Example use

1)
Run checkchains, to check that the chain in your pdb file is present

`cp example/1IAR.pdb ./`

`> ./bin/checkchains_metsite.pl ./example/1IAR.pdb A`

2)
Extract fasta seq

`> ./bin/fasta_pdbv3.pl ./example/1IAR.pdb ./1IAR.fasta A`

3)
run psiblast

`> ncbi-blast-2.2.31+/bin/psiblast -query 1IAR.fasta -inclusion_ethresh 0.001 -num_iterations 3 -num_alignments 0 -out_pssm 1IAR.chk -db uniref90.fasta > 1IAR.bls`

4)
run chkparse

`> ./bin/chkparse 1IAR.chk > 1IAR.mtx`

5)
run mtx_pro

`> ./bin/mtx_pro 1IAR.mtx 1IAR.pro`

6)
Run dssp

`> ./bin/dssp 1IAR.pdb 1IAR.dssp > 1IAR.dsspout`

7)
Run seed site find. You need to provide an ion from this list,
CU|CA|FE|ZN|MG|MN

`> ./bin/seedSiteFind 1IAR.pdb CU 10 1IAR.pro 1IAR.dssp A`


8)
run returnNetCut, keeping the atom choice the same, the second arg is a flag which returns the value for the following FRP
0 = 1%
1 = 5%
2 = 10%
3 = 20%

`java -cp 'src/org/ucl/conf/:src' returnNetCut CU 1`

9)
Take the float returned and use it as part of the input for met_pred
runt Met Pred, (i,e: 0.182). Lower case metals this time! And provide a path for the data files

`> ./bin/MetPred 1IAR.pdb.DATA cu 0.182 1IAR_MetPred.pdb A ./data/`

10)
As an alternatIve to steps 8 and 9 you can run the python script metpred.py which
wraps these two steps together. Basically you pass it the options the previous 2 commands need. Note that the classpath must have full canonical paths, and you must provide a location for the metpred binaries

`python ./bin/metpred.py /Users/dbuchan/Code/metsite/src/org/ucl/conf/:/Users/dbuchan/Code/metsite/src/ CU 1 1IAR.pdb.DATA 1IAR_MetPred.pdb A ./bin/ ./data/`
