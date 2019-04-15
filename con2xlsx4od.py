import numpy as np
import csv
import pandas as pd
import sys

#set display column width
pd.set_option('display.max_colwidth',1000)
pd.set_option('display.max_rows',1000000)
if sys.argv[1] == 'case.con':
    filename = sys.argv[1]
else:
    filename = sys.argv[1]
    print(filename)

#data = pd.read_table(filename,sep='\r\t',header=None,skip_blank_lines=False)
data = pd.read_table(filename,sep='\r\t',header=None,skip_blank_lines=False,engine='python')
#print(data)

ContingencyLabel = pd.DataFrame(columns = ["LABEL"])
BranchOutofServiceEvent = pd.DataFrame(columns = ["I", "J", "CKT","LABEL"])
GeneratorofServiceEvent = pd.DataFrame(columns = ["I", "ID","LABEL"])
for i in range(0,len(data)):
    strl = data.iloc[i].to_frame().T
    strl2 = strl.to_string()
    strlist = strl2.split()
    #get rid of head name & row name of table
    strlist = strlist[2:]
    #print(strlist)
    if strlist[0] == 'CONTINGENCY':
        ContingencyLabel = ContingencyLabel.append(pd.Series(strlist[1] ,index=["LABEL"]), ignore_index=True)
        strlistlabel = strlist[1]
        continue
    if strlist[0] == 'OPEN':
        branchid = list()
        branchid.append(strlist[4])
        branchid.append(strlist[7])
        branchid.append(strlist[9])
        branchid.append(strlistlabel)
        BranchOutofServiceEvent = BranchOutofServiceEvent.append(pd.Series((v for v in branchid) ,index=["I", "J", "CKT","LABEL"]), ignore_index=True)
        continue
    if strlist[0] == 'REMOVE':
        Generatorid = list()
        Generatorid.append(strlist[5])
        Generatorid.append(strlist[2])
        Generatorid.append(strlistlabel)
        GeneratorofServiceEvent = GeneratorofServiceEvent.append(pd.Series((v for v in Generatorid) ,index=["I", "ID","LABEL"]), ignore_index=True)
        continue
    if strlist[0] == 'END':
        strlistlabel = 0
        continue
#BranchOutofServiceEvent.loc[:,"I"] = 'BUS' + BranchOutofServiceEvent.loc[:,"I"]
#BranchOutofServiceEvent.loc[:,"J"] = 'BUS' + BranchOutofServiceEvent.loc[:,"J"]
BranchOutofServiceEvent["I"] = BranchOutofServiceEvent["I"].astype('int')
BranchOutofServiceEvent["J"] = BranchOutofServiceEvent["J"].astype('int')
BranchOutofServiceEvent.loc[:,"CKT"] = 'CKT' + BranchOutofServiceEvent.loc[:,"CKT"]
GeneratorofServiceEvent.loc[:,"ID"] = 'GEN' + GeneratorofServiceEvent.loc[:,"ID"]
#GeneratorofServiceEvent.loc[:,"I"] = 'BUS' + GeneratorofServiceEvent.loc[:,"I"]
GeneratorofServiceEvent["I"] = GeneratorofServiceEvent["I"].astype('int')

file_path = r'./con2xls.xlsx'
writer = pd.ExcelWriter(file_path)
df1 = pd.DataFrame(ContingencyLabel)
df1.to_excel(writer,'ContingencyLabel')
df2 = pd.DataFrame(BranchOutofServiceEvent)
df2.to_excel(writer,'BranchOutofServiceEvent')
df3 = pd.DataFrame(GeneratorofServiceEvent)
df3.to_excel(writer,'GeneratorOutofServiceEvent')
writer.save()
writer.close()
