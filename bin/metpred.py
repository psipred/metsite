import sys
import os
from subprocess import Popen, PIPE
# metpred.py src/org/ucl/conf/:src CU 1 1IAR.pdb.DATA 1IAR_MetPred.pdb
#            A ./bin/ ./data/

classpath = sys.argv[1]
metal_ion = sys.argv[2]
fpr_flag = sys.argv[3]
seedsite_data = sys.argv[4]
output_file = sys.argv[5]
chain = sys.argv[6]
bin_path = sys.argv[7]
data_path = sys.argv[8]

exe = "java"
# # strsum_eigen 1jbeA.pdb 1jbeA.dssp $TDB_DIR/1jbeA.tdb $TDB_DIR/1jbeA.eig
print("java -classpath "+classpath+" returnNetCut "+metal_ion.upper()+" "+fpr_flag)
process = Popen([exe, "-classpath", classpath, "returnNetCut",
                 metal_ion.upper(), fpr_flag], stdout=PIPE,
                 stderr=PIPE)
fpr_value = ''
for line in process.stdout:
    fpr_value = line.split()[2]

print(fpr_value)

exe = bin_path+"MetPred"
print(exe+" "+seedsite_data+" "+metal_ion.lower()+" "+fpr_value+" " +
      output_file+" "+chain+" "+data_path)
process = Popen([exe, seedsite_data, metal_ion.lower(), fpr_value,
                 output_file, chain, data_path])
