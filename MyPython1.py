import numpy as np
import csv
import pandas as pd
import sys
import os

'''
for arg in sys.argv:
    print (arg)
'''

#set display column width
pd.set_option('display.max_colwidth',1000)
pd.set_option('display.max_rows',1000000)
if sys.argv[1:]:
    if sys.argv[1] == 'case.con':
        filename = 'case.con'
    else:
        filename = sys.argv[1]
        #print(filename)
else:
    filename = 'case.con'


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
#GeneratorofServiceEvent.loc[:,"ID"] = 'GEN' + GeneratorofServiceEvent.loc[:,"ID"]
GeneratorofServiceEvent["ID"] = GeneratorofServiceEvent["ID"].astype('int')
#GeneratorofServiceEvent.loc[:,"I"] = 'BUS' + GeneratorofServiceEvent.loc[:,"I"]
GeneratorofServiceEvent["I"] = GeneratorofServiceEvent["I"].astype('int')

#file_path = r'./con2xls.xlsx'
#writer = pd.ExcelWriter(file_path)
df1 = pd.DataFrame(ContingencyLabel)
#df1.to_excel(writer,'ContingencyLabel')
df1.to_csv('ContingencyLabel.csv')
df2 = pd.DataFrame(BranchOutofServiceEvent)
#df2.to_excel(writer,'BranchOutofServiceEvent')
df2.to_csv('BranchOutofServiceEvent.csv')
df3 = pd.DataFrame(GeneratorofServiceEvent)
#df3.to_excel(writer,'GeneratorOutofServiceEvent')
df3.to_csv('GeneratorOutofServiceEvent.csv')
#writer.save()
#writer.close()


#set display column width
pd.set_option('display.max_colwidth',1000)
pd.set_option('display.max_rows',1000000)

#set display column width
pd.set_option('display.max_colwidth',1000)
pd.set_option('display.max_rows',1000000)
if sys.argv[1:]:
    if sys.argv[2] == 'case.inl':
        filename = 'case.inl'
    else:
        filename = sys.argv[2]
        #print(filename)
else:
    filename = 'case.inl'

#data = pd.read_table(filename,sep='\r\t',header=None,skip_blank_lines=False)
data = pd.read_table(filename,sep='\r\t',header=None,skip_blank_lines=False,engine='python')
#print(data)


#Convert Unit Inertia and Governor Response Data
Unit_Inertia_and_Governor_Response_Data = pd.DataFrame(columns = ["I", "ID", "H", "PMAX", "PMIN", "R", "D"])
for i in range(0,len(data)):
    strl = data.iloc[i].to_frame().T
    strl2 = strl.to_string()
    strlist = strl2.split(',')
    #get rid of head name of table
    str1 = strlist[0].split('\n')
    #get rid of row name of table
    str2 = str1[1].split('  ')
    strlist[0] = str2[1]
    #strip spaces and ''
    listtemp = []
    for j in strlist:
        listtemp.append(j.strip())
    strlist = listtemp
    listtemp = []
    for j in strlist:
        listtemp.append(j.strip("\'"))
    strlist = listtemp
    listtemp = []
    for j in strlist:
        listtemp.append(j.strip())
    strlist = listtemp
    #Fill null with NA
    listtemp = []
    for j in strlist:
        if j == '':
            j = 'NA'
        listtemp.append(j.strip())
    strlist = listtemp
    #print(strlist)
    if strlist[0].startswith("0"):
        #print('End of data')
        linnow = i
        #print(i)
        break
    Unit_Inertia_and_Governor_Response_Data = Unit_Inertia_and_Governor_Response_Data.append(pd.Series((v for v in strlist) ,index=["I", "ID", "H", "PMAX", "PMIN", "R", "D"]), ignore_index=True)
#Unit_Inertia_and_Governor_Response_Data.loc[:,"I"] = 'BUS' + Unit_Inertia_and_Governor_Response_Data.loc[:,"I"]
Unit_Inertia_and_Governor_Response_Data["I"] = Unit_Inertia_and_Governor_Response_Data["I"].astype('int')
#Unit_Inertia_and_Governor_Response_Data.loc[:,"ID"] = 'GEN' + Unit_Inertia_and_Governor_Response_Data.loc[:,"ID"]
Unit_Inertia_and_Governor_Response_Data["ID"] = Unit_Inertia_and_Governor_Response_Data["ID"].astype('int')
Unit_Inertia_and_Governor_Response_Data["H"] = Unit_Inertia_and_Governor_Response_Data["H"].astype('float64')
Unit_Inertia_and_Governor_Response_Data["PMAX"] = Unit_Inertia_and_Governor_Response_Data["PMAX"].astype('float64')
Unit_Inertia_and_Governor_Response_Data["PMIN"] = Unit_Inertia_and_Governor_Response_Data["PMIN"].astype('float64')
Unit_Inertia_and_Governor_Response_Data["R"] = Unit_Inertia_and_Governor_Response_Data["R"].astype('float64')
Unit_Inertia_and_Governor_Response_Data["D"] = Unit_Inertia_and_Governor_Response_Data["D"].astype('float64')

#file_path = r'./inl2xls.xlsx'
#writer = pd.ExcelWriter(file_path)
df = pd.DataFrame(Unit_Inertia_and_Governor_Response_Data)
#df.to_excel(writer,'UIAGRData')
df.to_csv('UIAGRData.csv')

#writer.save()
#writer.close()


if sys.argv[1:]:
    if sys.argv[3] == 'case.raw':
        filename = 'case.raw'
    else:
        filename = sys.argv[3]
        #print(filename)
else:
    filename = 'case.raw'

#data = pd.read_table(filename,sep='\r\t',header=None,skip_blank_lines=False)
data = pd.read_table(filename,sep='\r\t',header=None,skip_blank_lines=False,engine='python')
#print(data)
# return row number of data = len(data)
#dnum = data.shape[0]

#Convert Case Identification Data
Case_Identification_Data = pd.DataFrame(columns = ["IC", "SBASE", "REV", "XFRRAT", "NXFRAT", "BASFRQ"])
for i in range(1):
    #to normal dataframe
    strl = data.iloc[i].to_frame().T
    strl2 = strl.to_string()
    strlist = strl2.split(',')
    #get rid of head name of table
    str1 = strlist[0].split('\n')
    #get rid of row name of table
    str2 = str1[1].split('  ')
    strlist[0] = str2[1]
    #keep first 6 element only
    str1 = strlist[5].split('/')
    strlist[5] = str1[0]
    strlist = strlist[0:6]
    #strip spaces
    listtemp = []
    for j in strlist:
        listtemp.append(j.replace(" ",""))
    strlist = listtemp
Case_Identification_Data = Case_Identification_Data.append(pd.Series((v for v in strlist) ,index=["IC", "SBASE", "REV", "XFRRAT", "NXFRAT", "BASFRQ"]), ignore_index=True)
Case_Identification_Data["IC"] = Case_Identification_Data["IC"].astype('int')
Case_Identification_Data["SBASE"] = Case_Identification_Data["SBASE"].astype('float64')
Case_Identification_Data["REV"] = Case_Identification_Data["REV"].astype('float64')
Case_Identification_Data["XFRRAT"] = Case_Identification_Data["XFRRAT"].astype('float64')
Case_Identification_Data["NXFRAT"] = Case_Identification_Data["NXFRAT"].astype('float64')
Case_Identification_Data["BASFRQ"] = Case_Identification_Data["BASFRQ"].astype('float64')
#print(Case_Identification_Data)

#Caseline2, Caseline3
for i in range(1,3):
    strl = data.iloc[i].to_frame().T
    strl2 = strl.to_string()
    strlist = strl2.split(',')
    #get rid of head name of table
    str1 = strlist[0].split('\n')
    #get rid of row name of table
    str2 = str1[1].split('  ')
    strlist[0] = str2[1]


countzero = 0
linnow = 2
#Bus Data
Bus_Data = pd.DataFrame(columns = ["I", "NAME", "BASKV", "IDE", "AREA", "ZONE", "OWNER", "VM", "VA", "NVHI", "NVLO", "EVHI", "EVLO"])
for i in range(3,len(data)):
    strl = data.iloc[i].to_frame().T
    strl2 = strl.to_string()
    strlist = strl2.split(',')
    #get rid of head name of table
    str1 = strlist[0].split('\n')
    #get rid of row name of table
    str2 = str1[1].split('  ')
    strlist[0] = str2[1]
    #strip spaces and ''
    listtemp = []
    for j in strlist:
        listtemp.append(j.strip())
    strlist = listtemp
    listtemp = []
    for j in strlist:
        listtemp.append(j.strip("\'"))
    strlist = listtemp
    listtemp = []
    for j in strlist:
        listtemp.append(j.strip())
    strlist = listtemp
    #Fill null with NA
    listtemp = []
    for j in strlist:
        if j == '':
            j = 'NA'
        listtemp.append(j.strip())
    strlist = listtemp

    if strlist[0].startswith('0'):
        countzero = countzero +1
        #print('End of bus data')
        linnow = i
        #print(i)
        break
    Bus_Data = Bus_Data.append(pd.Series((v for v in strlist) ,index=["I", "NAME", "BASKV", "IDE", "AREA", "ZONE", "OWNER", "VM", "VA", "NVHI", "NVLO", "EVHI", "EVLO"]), ignore_index=True)
#Bus_Data.loc[:,"I"] = 'BUS' + Bus_Data.loc[:,"I"]
Bus_Data["I"] = Bus_Data["I"].astype('int')

Areas = pd.DataFrame(Bus_Data, columns=["I","AREA"])
Areas.loc[:,"AREA"] = 'A' + Areas.loc[:,"AREA"]

Bus_Data["BASKV"] = Bus_Data["BASKV"].astype('float64')
Bus_Data["IDE"] = Bus_Data["IDE"].astype('float64')
Bus_Data["AREA"] = Bus_Data["AREA"].astype('float64')
Bus_Data["ZONE"] = Bus_Data["ZONE"].astype('float64')
Bus_Data["OWNER"] = Bus_Data["OWNER"].astype('float64')
Bus_Data["VM"] = Bus_Data["VM"].astype('float64')
Bus_Data["VA"] = Bus_Data["VA"].astype('float64')
Bus_Data["NVHI"] = Bus_Data["NVHI"].astype('float64')
Bus_Data["NVLO"] = Bus_Data["NVLO"].astype('float64')
Bus_Data["EVHI"] = Bus_Data["EVHI"].astype('float64')
Bus_Data["EVLO"] = Bus_Data["EVLO"].astype('float64')
Bus_Data = Bus_Data.drop(columns=['NAME'])

Area_Data = Areas["AREA"].unique()
Area_Data = pd.DataFrame(Area_Data, columns = ["AREA"])

'''
if countzero == 1:
    print('Begin Load Data')
else:
    print('Error!')
'''

#Load Data
Load_Data = pd.DataFrame(columns = ["I", "ID", "STATUS", "AREA", "ZONE", "PL", "QL", "IP", "IQ", "YP", "YQ", "OWNER", "SCALE", "INTRPT"])
for i in range(linnow+1,len(data)):
    strl = data.iloc[i].to_frame().T
    strl2 = strl.to_string()
    strlist = strl2.split(',')
    #get rid of head name of table
    str1 = strlist[0].split('\n')
    #get rid of row name of table
    str2 = str1[1].split('  ')
    strlist[0] = str2[1]
    #strip spaces and ''
    listtemp = []
    for j in strlist:
        listtemp.append(j.strip())
    strlist = listtemp
    listtemp = []
    for j in strlist:
        listtemp.append(j.strip("\'"))
    strlist = listtemp
    listtemp = []
    for j in strlist:
        listtemp.append(j.strip())
    strlist = listtemp
    #Fill null with NA
    listtemp = []
    for j in strlist:
        if j == '':
            j = 'NA'
        listtemp.append(j.strip())
    strlist = listtemp

    if strlist[0].startswith("0"):
        countzero = countzero +1
        #print('End of load data')
        linnow = i
        #print(i)
        break
    Load_Data = Load_Data.append(pd.Series((v for v in strlist) ,index=["I", "ID", "STATUS", "AREA", "ZONE", "PL", "QL", "IP", "IQ", "YP", "YQ", "OWNER", "SCALE", "INTRPT"]), ignore_index=True)
#Load_Data.loc[:,"I"] = 'BUS' + Load_Data.loc[:,"I"]
Load_Data["I"] = Load_Data["I"].astype('int')
Load_Data.loc[:,"ID"] = 'LOAD' + Load_Data.loc[:,"ID"]
Load_Data["STATUS"] = Load_Data["STATUS"].astype('float64')
Load_Data["AREA"] = Load_Data["AREA"].astype('float64')
Load_Data["ZONE"] = Load_Data["ZONE"].astype('float64')
Load_Data["PL"] = Load_Data["PL"].astype('float64')
Load_Data["QL"] = Load_Data["QL"].astype('float64')
Load_Data["IP"] = Load_Data["IP"].astype('float64')
Load_Data["IQ"] = Load_Data["IQ"].astype('float64')
Load_Data["YP"] = Load_Data["YP"].astype('float64')
Load_Data["YQ"] = Load_Data["YQ"].astype('float64')
Load_Data["OWNER"] = Load_Data["OWNER"].astype('float64')
Load_Data["SCALE"] = Load_Data["SCALE"].astype('float64')
Load_Data["INTRPT"] = Load_Data["INTRPT"].astype('float64')
'''
if countzero == 2:
    print('Begin Fixed Bus Shunt Data')
else:
    print('Error!')
'''

#Fixed Bus Shunt Data
Fixed_Bus_Shunt_Data = pd.DataFrame(columns = ["I", "ID", "STATUS", "GL", "BL"])
for i in range(linnow+1,len(data)):
    strl = data.iloc[i].to_frame().T
    strl2 = strl.to_string()
    strlist = strl2.split(',')
    #get rid of head name of table
    str1 = strlist[0].split('\n')
    #get rid of row name of table
    str2 = str1[1].split('  ')
    strlist[0] = str2[1]
    #strip spaces and ''
    listtemp = []
    for j in strlist:
        listtemp.append(j.strip())
    strlist = listtemp
    listtemp = []
    for j in strlist:
        listtemp.append(j.strip("\'"))
    strlist = listtemp
    listtemp = []
    for j in strlist:
        listtemp.append(j.strip())
    strlist = listtemp
    #Fill null with NA
    listtemp = []
    for j in strlist:
        if j == '':
            j = 'NA'
        listtemp.append(j.strip())
    strlist = listtemp

    if strlist[0].startswith("0"):
        countzero = countzero +1
        #print('End of fixed shunt data')
        linnow = i
        #print(i)
        break
    Fixed_Bus_Shunt_Data = Fixed_Bus_Shunt_Data.append(pd.Series((v for v in strlist) ,index=["I", "ID", "STATUS", "GL", "BL"]), ignore_index=True)
#Fixed_Bus_Shunt_Data.loc[:,"I"] = 'BUS' + Fixed_Bus_Shunt_Data.loc[:,"I"]
Fixed_Bus_Shunt_Data["I"] = Fixed_Bus_Shunt_Data["I"].astype('int')
Fixed_Bus_Shunt_Data.loc[:,"ID"] = 'FSHUNT' + Fixed_Bus_Shunt_Data.loc[:,"ID"]
Fixed_Bus_Shunt_Data["STATUS"] = Fixed_Bus_Shunt_Data["STATUS"].astype('float64')
Fixed_Bus_Shunt_Data["GL"] = Fixed_Bus_Shunt_Data["GL"].astype('float64')
Fixed_Bus_Shunt_Data["BL"] = Fixed_Bus_Shunt_Data["BL"].astype('float64')

'''
if countzero == 3:
    print('Begin Generator Data')
else:
    print('Error!')
'''
#Generator Data
Generator_Data = pd.DataFrame(columns = ["I", "ID", "PG", "QG", "QT", "QB", "VS", "IREG", "MBASE", "ZR", "ZX", "RT", "XT", "GTAP", "STAT", "RMPCT", "PT", "PB", "O1", "F1", "O2", "F2", "O3", "F3", "O4", "F4", "WMOD", "WPF"])
for i in range(linnow+1,len(data)):
    strl = data.iloc[i].to_frame().T
    strl2 = strl.to_string()
    strlist = strl2.split(',')
    #get rid of head name of table
    str1 = strlist[0].split('\n')
    #get rid of row name of table
    str2 = str1[1].split('  ')
    strlist[0] = str2[1]
    #strip spaces and ''
    listtemp = []
    for j in strlist:
        listtemp.append(j.strip())
    strlist = listtemp
    listtemp = []
    for j in strlist:
        listtemp.append(j.strip("\'"))
    strlist = listtemp
    listtemp = []
    for j in strlist:
        listtemp.append(j.strip())
    strlist = listtemp
    #Fill null with NA
    listtemp = []
    for j in strlist:
        if j == '':
            j = 'NA'
        listtemp.append(j.strip())
    strlist = listtemp

    if strlist[0].startswith("0"):
        countzero = countzero +1
        #print('End of generator data')
        linnow = i
        #print(i)
        break
    Generator_Data = Generator_Data.append(pd.Series((v for v in strlist) ,index=["I", "ID", "PG", "QG", "QT", "QB", "VS", "IREG", "MBASE", "ZR", "ZX", "RT", "XT", "GTAP", "STAT", "RMPCT", "PT", "PB", "O1", "F1", "O2", "F2", "O3", "F3", "O4", "F4", "WMOD", "WPF"]), ignore_index=True)
#Generator_Data.loc[:,"I"] = 'BUS' + Generator_Data.loc[:,"I"]
Generator_Data["I"] = Generator_Data["I"].astype('int')
#Generator_Data.loc[:,"ID"] = 'GEN' + Generator_Data.loc[:,"ID"]
Generator_Data["ID"] = Generator_Data["ID"].astype('int')
Generator_Data["PG"] = Generator_Data["PG"].astype('float64')
Generator_Data["QG"] = Generator_Data["QG"].astype('float64')
Generator_Data["QT"] = Generator_Data["QT"].astype('float64')
Generator_Data["QB"] = Generator_Data["QB"].astype('float64')
Generator_Data["VS"] = Generator_Data["VS"].astype('float64')
Generator_Data["IREG"] = Generator_Data["IREG"].astype('float64')
Generator_Data["MBASE"] = Generator_Data["MBASE"].astype('float64')
Generator_Data["ZR"] = Generator_Data["ZR"].astype('float64')
Generator_Data["ZX"] = Generator_Data["ZX"].astype('float64')
Generator_Data["RT"] = Generator_Data["RT"].astype('float64')
Generator_Data["XT"] = Generator_Data["XT"].astype('float64')
Generator_Data["GTAP"] = Generator_Data["GTAP"].astype('float64')
Generator_Data["STAT"] = Generator_Data["STAT"].astype('float64')
Generator_Data["RMPCT"] = Generator_Data["RMPCT"].astype('float64')
Generator_Data["PT"] = Generator_Data["PT"].astype('float64')
Generator_Data["PB"] = Generator_Data["PB"].astype('float64')
Generator_Data["O1"] = Generator_Data["O1"].astype('float64')
Generator_Data["F1"] = Generator_Data["F1"].astype('float64')
Generator_Data["O2"] = Generator_Data["O2"].astype('float64')
Generator_Data["F2"] = Generator_Data["F2"].astype('float64')
Generator_Data["O3"] = Generator_Data["O3"].astype('float64')
Generator_Data["F3"] = Generator_Data["F3"].astype('float64')
Generator_Data["O4"] = Generator_Data["O4"].astype('float64')
Generator_Data["F4"] = Generator_Data["F4"].astype('float64')
Generator_Data["WMOD"] = Generator_Data["WMOD"].astype('float64')
Generator_Data["WPF"] = Generator_Data["WPF"].astype('float64')
'''
if countzero == 4:
    print('Begin Non-Transformer Branch Data')
else:
    print('Error!')
'''

#Non-Transformer Branch Data
NonTransformer_Branch_Data = pd.DataFrame(columns = ["I", "J", "CKT", "R", "X", "B", "RATEA", "RATEB", "RATEC", "GI", "BI", "GJ", "BJ", "ST", "MET", "LEN", "O1", "F1", "O2", "F2", "O3", "F3", "O4", "F4"])
for i in range(linnow+1,len(data)):
    strl = data.iloc[i].to_frame().T
    strl2 = strl.to_string()
    strlist = strl2.split(',')
    #get rid of head name of table
    str1 = strlist[0].split('\n')
    #get rid of row name of table
    str2 = str1[1].split('  ')
    strlist[0] = str2[1]
    #strip spaces and ''
    listtemp = []
    for j in strlist:
        listtemp.append(j.strip())
    strlist = listtemp
    listtemp = []
    for j in strlist:
        listtemp.append(j.strip("\'"))
    strlist = listtemp
    listtemp = []
    for j in strlist:
        listtemp.append(j.strip())
    strlist = listtemp
    #Fill null with NA
    listtemp = []
    for j in strlist:
        if j == '':
            j = 'NA'
        listtemp.append(j.strip())
    strlist = listtemp

    if strlist[0].startswith("0"):
        countzero = countzero +1
        #print('End of Non-Transformer Branch Data data')
        linnow = i
        #print(i)
        break
    NonTransformer_Branch_Data = NonTransformer_Branch_Data.append(pd.Series((v for v in strlist) ,index=["I", "J", "CKT", "R", "X", "B", "RATEA", "RATEB", "RATEC", "GI", "BI", "GJ", "BJ", "ST", "MET", "LEN", "O1", "F1", "O2", "F2", "O3", "F3", "O4", "F4"]), ignore_index=True)
#NonTransformer_Branch_Data.loc[:,"I"] = 'BUS' + NonTransformer_Branch_Data.loc[:,"I"]
#NonTransformer_Branch_Data.loc[:,"J"] = 'BUS' + NonTransformer_Branch_Data.loc[:,"J"]
NonTransformer_Branch_Data["I"] = NonTransformer_Branch_Data["I"].astype('int')
NonTransformer_Branch_Data["J"] = NonTransformer_Branch_Data["J"].astype('int')
NonTransformer_Branch_Data.loc[:,"CKT"] = 'CKT' + NonTransformer_Branch_Data.loc[:,"CKT"]
NonTransformer_Branch_Data["R"] = NonTransformer_Branch_Data["R"].astype('float64')
NonTransformer_Branch_Data["X"] = NonTransformer_Branch_Data["X"].astype('float64')
NonTransformer_Branch_Data["B"] = NonTransformer_Branch_Data["B"].astype('float64')
NonTransformer_Branch_Data["RATEA"] = NonTransformer_Branch_Data["RATEA"].astype('float64')
NonTransformer_Branch_Data["RATEB"] = NonTransformer_Branch_Data["RATEB"].astype('float64')
NonTransformer_Branch_Data["RATEC"] = NonTransformer_Branch_Data["RATEC"].astype('float64')
NonTransformer_Branch_Data["GI"] = NonTransformer_Branch_Data["GI"].astype('float64')
NonTransformer_Branch_Data["BI"] = NonTransformer_Branch_Data["BI"].astype('float64')
NonTransformer_Branch_Data["GJ"] = NonTransformer_Branch_Data["GJ"].astype('float64')
NonTransformer_Branch_Data["BJ"] = NonTransformer_Branch_Data["BJ"].astype('float64')
NonTransformer_Branch_Data["ST"] = NonTransformer_Branch_Data["ST"].astype('float64')
NonTransformer_Branch_Data["MET"] = NonTransformer_Branch_Data["MET"].astype('float64')
NonTransformer_Branch_Data["LEN"] = NonTransformer_Branch_Data["LEN"].astype('float64')
NonTransformer_Branch_Data["O1"] = NonTransformer_Branch_Data["O1"].astype('float64')
NonTransformer_Branch_Data["F1"] = NonTransformer_Branch_Data["F1"].astype('float64')
NonTransformer_Branch_Data["O2"] = NonTransformer_Branch_Data["O2"].astype('float64')
NonTransformer_Branch_Data["F2"] = NonTransformer_Branch_Data["F2"].astype('float64')
NonTransformer_Branch_Data["O3"] = NonTransformer_Branch_Data["O3"].astype('float64')
NonTransformer_Branch_Data["F3"] = NonTransformer_Branch_Data["F3"].astype('float64')
NonTransformer_Branch_Data["O4"] = NonTransformer_Branch_Data["O4"].astype('float64')
NonTransformer_Branch_Data["F4"] = NonTransformer_Branch_Data["F4"].astype('float64')
'''
if countzero == 5:
    print('Begin Transformer Data')
else:
    print('Error!')
'''


#Transformer Data
Transformer_Data = pd.DataFrame(columns = ["I", "J", "K", "CKT", "CW", "CZ", "CM", "MAG1", "MAG2", "NMETR", "NAME", "STAT", "O1", "F1", "O2", "F2", "O3", "F3", "O4","F4", "VECGRP", "R12", "X12", "SBASE12", "WINDV1", "NOMV1", "ANG1", "RATA1", "RATB1", "RATC1", "COD1", "CONT1", "RMA1", "RMI1", "VMA1", "VMI1", "NTP1", "TAB1", "CR1", "CX1", "CNXA1", "WINDV2","NOMV2"])
flag = 0
for i in range(linnow+1,len(data),4):
    if flag == 0:
        strlistfull = list()
    for k in range(0,4):
        strl = data.iloc[i+k].to_frame().T
        strl2 = strl.to_string()
        strlist = strl2.split(',')
        #get rid of head name of table
        str1 = strlist[0].split('\n')
        #get rid of row name of table
        str2 = str1[1].split('  ')
        strlist[0] = str2[1]
        #strip spaces and ''
        listtemp = []
        for j in strlist:
            listtemp.append(j.strip())
        strlist = listtemp
        listtemp = []
        for j in strlist:
            listtemp.append(j.strip("\'"))
        strlist = listtemp
        listtemp = []
        for j in strlist:
            listtemp.append(j.strip())
        strlist = listtemp
        #Fill null with NA
        listtemp = []
        for j in strlist:
            if j == '':
                j = 'NA'
            listtemp.append(j.strip())
        strlist = listtemp
        #print(strlist[0])
        #print(k)
        if  k == 0 and strlist[0].startswith('0'):
            #print('End of transformer data')
            countzero = countzero +1
            linnow = i+k
            flag = 1
            #print(i)
            break
        else:
            strlistfull = strlistfull + strlist
            #print(strlist)
            #print(strlistfull)
    if flag == 0:
        Transformer_Data = Transformer_Data.append(pd.Series((v for v in strlistfull) ,index=["I", "J", "K", "CKT", "CW", "CZ", "CM", "MAG1", "MAG2", "NMETR", "NAME", "STAT", "O1", "F1", "O2", "F2", "O3", "F3", "O4","F4", "VECGRP", "R12", "X12", "SBASE12", "WINDV1", "NOMV1", "ANG1", "RATA1", "RATB1", "RATC1", "COD1", "CONT1", "RMA1", "RMI1", "VMA1", "VMI1", "NTP1", "TAB1", "CR1", "CX1", "CNXA1", "WINDV2","NOMV2"]), ignore_index=True)
    else:
        break
#Transformer_Data.loc[:,"I"] = 'BUS' + Transformer_Data.loc[:,"I"]
#Transformer_Data.loc[:,"J"] = 'BUS' + Transformer_Data.loc[:,"J"]
Transformer_Data["I"] = Transformer_Data["I"].astype('int')
Transformer_Data["J"] = Transformer_Data["J"].astype('int')
Transformer_Data.loc[:,"CKT"] = 'CKT' + Transformer_Data.loc[:,"CKT"]
Transformer_Data["CW"] = Transformer_Data["CW"].astype('float64')
Transformer_Data["CZ"] = Transformer_Data["CZ"].astype('float64')
Transformer_Data["CM"] = Transformer_Data["CM"].astype('float64')
Transformer_Data["MAG1"] = Transformer_Data["MAG1"].astype('float64')
Transformer_Data["MAG2"] = Transformer_Data["MAG2"].astype('float64')
Transformer_Data["NMETR"] = Transformer_Data["NMETR"].astype('float64')
Transformer_Data["STAT"] = Transformer_Data["STAT"].astype('float64')
Transformer_Data["O1"] = Transformer_Data["O1"].astype('float64')
Transformer_Data["F1"] = Transformer_Data["F1"].astype('float64')
Transformer_Data["O2"] = Transformer_Data["O2"].astype('float64')
Transformer_Data["F2"] = Transformer_Data["F2"].astype('float64')
Transformer_Data["O3"] = Transformer_Data["O3"].astype('float64')
Transformer_Data["F3"] = Transformer_Data["F3"].astype('float64')
Transformer_Data["O4"] = Transformer_Data["O4"].astype('float64')
Transformer_Data["F4"] = Transformer_Data["F4"].astype('float64')
Transformer_Data["R12"] = Transformer_Data["R12"].astype('float64')
Transformer_Data["X12"] = Transformer_Data["X12"].astype('float64')
Transformer_Data["SBASE12"] = Transformer_Data["SBASE12"].astype('float64')
Transformer_Data["WINDV1"] = Transformer_Data["WINDV1"].astype('float64')
Transformer_Data["NOMV1"] = Transformer_Data["NOMV1"].astype('float64')
Transformer_Data["ANG1"] = Transformer_Data["ANG1"].astype('float64')
Transformer_Data["RATA1"] = Transformer_Data["RATA1"].astype('float64')
Transformer_Data["RATB1"] = Transformer_Data["RATB1"].astype('float64')
Transformer_Data["RATC1"] = Transformer_Data["RATC1"].astype('float64')
Transformer_Data["COD1"] = Transformer_Data["COD1"].astype('float64')
Transformer_Data["CONT1"] = Transformer_Data["CONT1"].astype('float64')
Transformer_Data["RMA1"] = Transformer_Data["RMA1"].astype('float64')
Transformer_Data["RMI1"] = Transformer_Data["RMI1"].astype('float64')
Transformer_Data["VMA1"] = Transformer_Data["VMA1"].astype('float64')
Transformer_Data["VMI1"] = Transformer_Data["VMI1"].astype('float64')
Transformer_Data["NTP1"] = Transformer_Data["NTP1"].astype('float64')
Transformer_Data["TAB1"] = Transformer_Data["TAB1"].astype('float64')
Transformer_Data["CR1"] = Transformer_Data["CR1"].astype('float64')
Transformer_Data["CX1"] = Transformer_Data["CX1"].astype('float64')
Transformer_Data["CNXA1"] = Transformer_Data["CNXA1"].astype('float64')
Transformer_Data["WINDV2"] = Transformer_Data["WINDV2"].astype('float64')
Transformer_Data["NOMV2"] = Transformer_Data["NOMV2"].astype('float64')
Transformer_Data = Transformer_Data.drop(columns=['K', 'NAME', 'VECGRP'])
'''
if countzero == 6:
    print('Begin Switched Shunt Data')
else:
    print('Error!')
'''
for i in range(linnow+1,len(data)):
    strl = data.iloc[i].to_frame().T
    strl2 = strl.to_string()
    strlist = strl2.split(',')
    #get rid of head name of table
    str1 = strlist[0].split('\n')
    #get rid of row name of table
    str2 = str1[1].split('  ')
    strlist[0] = str2[1]
    #strip spaces and ''
    listtemp = []
    for j in strlist:
        listtemp.append(j.strip())
    strlist = listtemp
    listtemp = []
    for j in strlist:
        listtemp.append(j.strip("\'"))
    strlist = listtemp
    listtemp = []
    for j in strlist:
        listtemp.append(j.strip())
    strlist = listtemp
    #Fill null with NA
    listtemp = []
    for j in strlist:
        if j == '':
            j = 'NA'
        listtemp.append(j.strip())
    strlist = listtemp
    if strlist[0].startswith("0"):
        countzero = countzero +1
        if countzero == 16:
            linnow = i
            #print(linnow)
            break
        continue

#Switched Shunt Data
Switched_Shunt_Data = pd.DataFrame(columns = ["I", "MODSW", "ADJM", "STAT", "VSWHI", "VSWLO", "SWREM", "RMPCT", "RMIDNT", "BINIT", "N1", "B1", "N2", "B2", "N3", "B3", "N4", "B4", "N5", "B5", "N6", "B6", "N7", "B7", "N8", "B8"])
for i in range(linnow+1,len(data)):
    strl = data.iloc[i].to_frame().T
    strl2 = strl.to_string()
    strlist = strl2.split(',')
    #get rid of head name of table
    str1 = strlist[0].split('\n')
    #get rid of row name of table
    str2 = str1[1].split('  ')
    strlist[0] = str2[1]
    #strip spaces and ''
    listtemp = []
    for j in strlist:
        listtemp.append(j.strip())
    strlist = listtemp
    listtemp = []
    for j in strlist:
        listtemp.append(j.strip("\'"))
    strlist = listtemp
    listtemp = []
    for j in strlist:
        listtemp.append(j.strip())
    strlist = listtemp
    #Fill null with NA
    listtemp = []
    for j in strlist:
        if j == '':
            j = 'NA'
        listtemp.append(j.strip())
    strlist = listtemp

    if strlist[0].startswith("0"):
        countzero = countzero +1
        #print('End of Switched Shunt data')
        linnow = i
        #print(i)
        break
    Switched_Shunt_Data = Switched_Shunt_Data.append(pd.Series((v for v in strlist) ,index=["I", "MODSW", "ADJM", "STAT", "VSWHI", "VSWLO", "SWREM", "RMPCT", "RMIDNT", "BINIT", "N1", "B1", "N2", "B2", "N3", "B3", "N4", "B4", "N5", "B5", "N6", "B6", "N7", "B7", "N8", "B8"]), ignore_index=True)
#Switched_Shunt_Data.loc[:,"I"] = 'BUS' + Switched_Shunt_Data.loc[:,"I"]
Switched_Shunt_Data["I"] = Switched_Shunt_Data["I"].astype('int')
Switched_Shunt_Data["MODSW"] = Switched_Shunt_Data["MODSW"].astype('float64')
Switched_Shunt_Data["ADJM"] = Switched_Shunt_Data["ADJM"].astype('float64')
Switched_Shunt_Data["STAT"] = Switched_Shunt_Data["STAT"].astype('float64')
Switched_Shunt_Data["VSWHI"] = Switched_Shunt_Data["VSWHI"].astype('float64')
Switched_Shunt_Data["VSWLO"] = Switched_Shunt_Data["VSWLO"].astype('float64')
Switched_Shunt_Data["SWREM"] = Switched_Shunt_Data["SWREM"].astype('float64')
Switched_Shunt_Data["RMPCT"] = Switched_Shunt_Data["RMPCT"].astype('float64')
Switched_Shunt_Data["BINIT"] = Switched_Shunt_Data["BINIT"].astype('float64')
Switched_Shunt_Data["N1"] = Switched_Shunt_Data["N1"].astype('float64')
Switched_Shunt_Data["B1"] = Switched_Shunt_Data["B1"].astype('float64')
Switched_Shunt_Data["N2"] = Switched_Shunt_Data["N2"].astype('float64')
Switched_Shunt_Data["B2"] = Switched_Shunt_Data["B2"].astype('float64')
Switched_Shunt_Data["N3"] = Switched_Shunt_Data["N3"].astype('float64')
Switched_Shunt_Data["B3"] = Switched_Shunt_Data["B3"].astype('float64')
Switched_Shunt_Data["N4"] = Switched_Shunt_Data["N4"].astype('float64')
Switched_Shunt_Data["B4"] = Switched_Shunt_Data["B4"].astype('float64')
Switched_Shunt_Data["N5"] = Switched_Shunt_Data["N5"].astype('float64')
Switched_Shunt_Data["B5"] = Switched_Shunt_Data["B5"].astype('float64')
Switched_Shunt_Data["N6"] = Switched_Shunt_Data["N6"].astype('float64')
Switched_Shunt_Data["B6"] = Switched_Shunt_Data["B6"].astype('float64')
Switched_Shunt_Data["N7"] = Switched_Shunt_Data["N7"].astype('float64')
Switched_Shunt_Data["B7"] = Switched_Shunt_Data["B7"].astype('float64')
Switched_Shunt_Data["N8"] = Switched_Shunt_Data["N8"].astype('float64')
Switched_Shunt_Data["B8"] = Switched_Shunt_Data["B8"].astype('float64')
Switched_Shunt_Data = Switched_Shunt_Data.drop(columns=['RMIDNT'])

#GNE Device Data

#Induction Machine Data



'''
for row in data.itertuples():
    print(row)
print('hI')
print(strlist[0])
print('h2')
print(str2[1])
print('gg')
print(data.iloc[5])
'''





#file_path = r'./raw2xls.xlsx'
#writer = pd.ExcelWriter(file_path)
df1 = pd.DataFrame(Case_Identification_Data)
df1.to_csv('CID.csv')
#df1.to_excel(writer,'CID')
df2 = pd.DataFrame(Bus_Data)
df2.to_csv('BusData.csv')
#df2.to_excel(writer,'BusData')
df3 = pd.DataFrame(Load_Data)
df3.to_csv('LoadData.csv')
#df3.to_excel(writer,'LoadData')
df4 = pd.DataFrame(Fixed_Bus_Shunt_Data)
df4.to_csv('FixedBusShuntData.csv')
#df4.to_excel(writer,'FixedBusShuntData')
df5 = pd.DataFrame(Generator_Data)
df5.to_csv('GeneratorData.csv')
#df5.to_excel(writer,'GeneratorData')
df6 = pd.DataFrame(NonTransformer_Branch_Data)
df6.to_csv('NonTransformerBranchData.csv')
#df6.to_excel(writer,'NonTransformerBranchData')
df7 = pd.DataFrame(Transformer_Data)
df7.to_csv('TransformerData.csv')
#df7.to_excel(writer,'TransformerData')
df18 = pd.DataFrame(Switched_Shunt_Data)
df18.to_csv('SwitchedShuntData.csv')
#df18.to_excel(writer,'SwitchedShuntData')
df19 = pd.DataFrame(Areas)
df19.to_csv('Areas.csv')
#df19.to_excel(writer,'Areas')
df20 = pd.DataFrame(Area_Data)
df20.to_csv('AreaData.csv')
#df20.to_excel(writer,'AreaData')
#writer.save()
#writer.close()
#set display column width
pd.set_option('display.max_colwidth',2000)
pd.set_option('display.max_rows',1000000)
if sys.argv[1:]:
    if sys.argv[1] == 'case.rop':
        filename = 'case.rop'
    else:
        filename = sys.argv[4]
        #print(filename)
else:
    filename = 'case.rop'

#data = pd.read_table(filename,sep='\r\t',header=None,skip_blank_lines=False)
data = pd.read_table(filename,sep='\r\t',header=None,skip_blank_lines=False,engine='python')
#print(data)




countzero = 0
linnow = 0
for i in range(0,len(data)):
    strl = data.iloc[i].to_frame().T
    strl2 = strl.to_string()
    strlist = strl2.split(',')
    #get rid of head name of table
    str1 = strlist[0].split('\n')
    #get rid of row name of table
    str2 = str1[1].split('  ')
    strlist[0] = str2[1]
    #strip spaces and ''
    listtemp = []
    for j in strlist:
        listtemp.append(j.strip())
    strlist = listtemp
    listtemp = []
    for j in strlist:
        listtemp.append(j.strip("\'"))
    strlist = listtemp
    listtemp = []
    for j in strlist:
        listtemp.append(j.strip())
    strlist = listtemp
    #Fill null with NA
    listtemp = []
    for j in strlist:
        if j == '':
            j = 'NA'
        listtemp.append(j.strip())
    strlist = listtemp
    if strlist[0].startswith('0'):
        countzero = countzero +1
        #print(strlist[0])
        if countzero == 5:
            linnow = i
            break
        continue

#print(countzero)
#Generator Dispatch Units data
Generator_Dispatch_Units_Data = pd.DataFrame(columns = ["BUS", "GENID", "DISP", "DSPTBL"])
for i in range(linnow+1,len(data)):
    strl = data.iloc[i].to_frame().T
    strl2 = strl.to_string()
    strlist = strl2.split(',')
    #get rid of head name of table
    str1 = strlist[0].split('\n')
    #get rid of row name of table
    str2 = str1[1].split('  ')
    strlist[0] = str2[1]
    #strip spaces and ''
    listtemp = []
    for j in strlist:
        listtemp.append(j.strip())
    strlist = listtemp
    listtemp = []
    for j in strlist:
        listtemp.append(j.strip("\'"))
    strlist = listtemp
    listtemp = []
    for j in strlist:
        listtemp.append(j.strip())
    strlist = listtemp
    #Fill null with NA
    listtemp = []
    for j in strlist:
        if j == '':
            j = 'NA'
        listtemp.append(j.strip())
    strlist = listtemp

    if strlist[0].startswith("0"):
        countzero = countzero +1
        #print('End of Generator Dispatch data')
        linnow = i
        #print(i)
        break
    #print(strlist)
    #print(countzero)
    Generator_Dispatch_Units_Data = Generator_Dispatch_Units_Data.append(pd.Series((v for v in strlist) ,index=["BUS", "GENID", "DISP", "DSPTBL"]), ignore_index=True)
#Generator_Dispatch_Units_Data.loc[:,"BUS"] = 'BUS' + Generator_Dispatch_Units_Data.loc[:,"BUS"]
Generator_Dispatch_Units_Data["BUS"] = Generator_Dispatch_Units_Data["BUS"].astype('int')
#Generator_Dispatch_Units_Data.loc[:,"GENID"] = 'GEN' + Generator_Dispatch_Units_Data.loc[:,"GENID"]
Generator_Dispatch_Units_Data["GENID"] = Generator_Dispatch_Units_Data["GENID"].astype('int')
Generator_Dispatch_Units_Data.loc[:,"DSPTBL"] = 'TBL' + Generator_Dispatch_Units_Data.loc[:,"DSPTBL"]
Generator_Dispatch_Units_Data["DISP"] = Generator_Dispatch_Units_Data["DISP"].astype('float64')
#Generator_Dispatch_Units_Data = Generator_Dispatch_Units_Data.drop(columns=['DISP'])
#Move "DSPTBL" to Third column
DSPTBL = Generator_Dispatch_Units_Data.pop('DSPTBL')
Generator_Dispatch_Units_Data.insert(2,'DSPTBL',DSPTBL)
'''
if countzero == 6:
    print('Begin Active Power Dispatch Tables')
else:
    print('Error!')
'''
#Active Power Dispatch Tables data
Active_Power_Dispatch_Tables_Data = pd.DataFrame(columns = ["TBL", "PMAX", "PMIN", "FUELCOST", "CTYP", "STATUS", "CTBL"])
for i in range(linnow+1,len(data)):
    strl = data.iloc[i].to_frame().T
    strl2 = strl.to_string()
    strlist = strl2.split(',')
    #get rid of head name of table
    str1 = strlist[0].split('\n')
    #get rid of row name of table
    str2 = str1[1].split('  ')
    strlist[0] = str2[1]
    #strip spaces and ''
    listtemp = []
    for j in strlist:
        listtemp.append(j.strip())
    strlist = listtemp
    listtemp = []
    for j in strlist:
        listtemp.append(j.strip("\'"))
    strlist = listtemp
    listtemp = []
    for j in strlist:
        listtemp.append(j.strip())
    strlist = listtemp
    #Fill null with NA
    listtemp = []
    for j in strlist:
        if j == '':
            j = 'NA'
        listtemp.append(j.strip())
    strlist = listtemp

    if strlist[0].startswith("0"):
        countzero = countzero +1
        #print('End of Active Power Dispatch Tables')
        linnow = i
        #print(i)
        break
    Active_Power_Dispatch_Tables_Data = Active_Power_Dispatch_Tables_Data.append(pd.Series((v for v in strlist) ,index=["TBL", "PMAX", "PMIN", "FUELCOST", "CTYP", "STATUS", "CTBL"]), ignore_index=True)
Active_Power_Dispatch_Tables_Data.loc[:,"TBL"] = 'TBL' + Active_Power_Dispatch_Tables_Data.loc[:,"TBL"]
Active_Power_Dispatch_Tables_Data.loc[:,"CTBL"] = 'TBL' + Active_Power_Dispatch_Tables_Data.loc[:,"CTBL"]
Active_Power_Dispatch_Tables_Data["PMAX"] = Active_Power_Dispatch_Tables_Data["PMAX"].astype('float64')
Active_Power_Dispatch_Tables_Data["PMIN"] = Active_Power_Dispatch_Tables_Data["PMIN"].astype('float64')
Active_Power_Dispatch_Tables_Data["FUELCOST"] = Active_Power_Dispatch_Tables_Data["FUELCOST"].astype('float64')
Active_Power_Dispatch_Tables_Data["CTYP"] = Active_Power_Dispatch_Tables_Data["CTYP"].astype('float64')
Active_Power_Dispatch_Tables_Data["STATUS"] = Active_Power_Dispatch_Tables_Data["STATUS"].astype('float64')
#Move "CTBL" to Second column
CTBL = Active_Power_Dispatch_Tables_Data.pop('CTBL')
Active_Power_Dispatch_Tables_Data.insert(1,'CTBL',CTBL)

for i in range(linnow+1,len(data)):
    strl = data.iloc[i].to_frame().T
    strl2 = strl.to_string()
    strlist = strl2.split(',')
    #get rid of head name of table
    str1 = strlist[0].split('\n')
    #get rid of row name of table
    str2 = str1[1].split('  ')
    strlist[0] = str2[1]
    #strip spaces and ''
    listtemp = []
    for j in strlist:
        listtemp.append(j.strip())
    strlist = listtemp
    listtemp = []
    for j in strlist:
        listtemp.append(j.strip("\'"))
    strlist = listtemp
    listtemp = []
    for j in strlist:
        listtemp.append(j.strip())
    strlist = listtemp
    #Fill null with NA
    listtemp = []
    for j in strlist:
        if j == '':
            j = 'NA'
        listtemp.append(j.strip())
    strlist = listtemp
    if strlist[0].startswith("0"):
        countzero = countzero +1
        if countzero == 10:
            linnow = i
            #print(linnow)
            break
        continue


'''
if countzero == 10:
    print('Begin Piece-wise Linear Cost Tables')
    print(linnow)
else:
    print('Error!')
'''
#Piecewise Linear Cost Curve Tables data
Piecewise_Linear_Cost_Curve_Tables_Data = pd.DataFrame(columns = ["LTBL", "LABEL", "NoPAIRS", "XI", "YI"])
LTBLNPAIRS = pd.DataFrame(columns = ["LTBL", "NPAIRS"])
flags = 0
while (flags == 0):
    linnow = linnow + 1
    strl = data.iloc[linnow].to_frame().T
    strl2 = strl.to_string()
    strlist = strl2.split(',')
    #get rid of head name of table
    str1 = strlist[0].split('\n')
    #get rid of row name of table
    str2 = str1[1].split('  ')
    strlist[0] = str2[1]
    #strip spaces and ''
    listtemp = []
    for j in strlist:
        listtemp.append(j.strip())
    strlist = listtemp
    listtemp = []
    for j in strlist:
        listtemp.append(j.strip("\'"))
    strlist = listtemp
    listtemp = []
    for j in strlist:
        listtemp.append(j.strip())
    strlist = listtemp
    #Fill null with NA
    listtemp = []
    for j in strlist:
        if j == '':
            j = 'NA'
        listtemp.append(j.strip())
    strlist = listtemp
    #print('HI')
    #print(strlist[0])
    if strlist[0].startswith("0"):
        #print('End of Piecewise Linear Cost Tables data')
        flags = 1
        #print(i)
        break
    else:
        if flags == 1:
            break
        strlist1 = strlist
        NPAIRS = strlist1[2]
        NPAIRS = int(NPAIRS)
        #print(NPAIRS)
        linnow = linnow +1
        flag = 0
        for k in range(0,NPAIRS):
            strl = data.iloc[k+linnow].to_frame().T
            strl2 = strl.to_string()
            strlist2 = strl2.split(',')
            #get rid of head name of table
            str1 = strlist2[0].split('\n')
            #get rid of row name of table
            str2 = str1[1].split('  ')
            strlist2[0] = str2[1]
            #strip spaces and ''
            listtemp = []
            for j in strlist2:
                listtemp.append(j.strip())
            strlist2 = listtemp
            listtemp = []
            for j in strlist2:
                listtemp.append(j.strip("\'"))
            strlist2 = listtemp
            listtemp = []
            for j in strlist2:
                listtemp.append(j.strip())
            strlist2 = listtemp
            #Fill null with NA
            listtemp = []
            for j in strlist2:
                if j == '':
                    j = 'NA'
                listtemp.append(j.strip())
            strlist2 = listtemp
            #print(strlist2[0])
            strlist = strlist1 + strlist2
            if k ==0:
                strlistNPAIRS = list()
                strlistNPAIRS.append(strlist[0])
                strlistNPAIRS.append(strlist[2])
                #print(strlistNPAIRS)
                LTBLNPAIRS = LTBLNPAIRS.append(pd.Series((v for v in strlistNPAIRS) ,index=["LTBL", "NPAIRS"]), ignore_index=True)
            strlist[2] = str(k+1)
            Piecewise_Linear_Cost_Curve_Tables_Data = Piecewise_Linear_Cost_Curve_Tables_Data.append(pd.Series((v for v in strlist) ,index=["LTBL", "LABEL", "NoPAIRS", "XI", "YI"]), ignore_index=True)
        linnow = linnow + k
    if flags == 1:
        break
Piecewise_Linear_Cost_Curve_Tables_Data.loc[:,"LTBL"] = 'TBL' + Piecewise_Linear_Cost_Curve_Tables_Data.loc[:,"LTBL"]
Piecewise_Linear_Cost_Curve_Tables_Data["NoPAIRS"] = Piecewise_Linear_Cost_Curve_Tables_Data["NoPAIRS"].astype('float64')
LTBLNPAIRS.loc[:,"LTBL"] = 'TBL' + LTBLNPAIRS.loc[:,"LTBL"]
LTBLNPAIRS["NPAIRS"] = LTBLNPAIRS["NPAIRS"].astype('float64')
Piecewise_Linear_Cost_Curve_Tables_Data["XI"] = Piecewise_Linear_Cost_Curve_Tables_Data["XI"].astype('float64')
Piecewise_Linear_Cost_Curve_Tables_Data["YI"] = Piecewise_Linear_Cost_Curve_Tables_Data["YI"].astype('float64')
Piecewise_Linear_Cost_Curve_Tables_Data = Piecewise_Linear_Cost_Curve_Tables_Data.drop(columns=['LABEL'])



#Create Gen-h sheet
dftemp=Generator_Dispatch_Units_Data
dftemp.columns = ["BUS", "GENID", "LTBL", "DISP"]

#GenCostDatacombinedbyTbl = pd.concat([Generator_Dispatch_Units_Data, Piecewise_Linear_Cost_Curve_Tables_Data], axis=1, join_axes=[Generator_Dispatch_Units_Data.index])
GenCostDatacombinedbyTbl = dftemp.merge(Piecewise_Linear_Cost_Curve_Tables_Data, on='LTBL', how='left')
GenCostDatacombinedbyTbl = GenCostDatacombinedbyTbl.drop(columns=['DISP','LTBL'])
#print(GenCostDatacombinedbyTbl)


#Piecewise Quadratic Cost Curve Tables data

#Polynomial & Exponential Cost Curve Tables data

#Period Reserves data

#Branch Flows data

#Interface Flows data

#Linear Constraint Dependencies data

#file_path = r'./rop2xls.xlsx'
#writer = pd.ExcelWriter(file_path)
df6 = pd.DataFrame(Generator_Dispatch_Units_Data)
df6.to_csv('GeneratorDispatchUnitsData.csv')
#df6.to_excel(writer,'GeneratorDispatchUnitsData')
df7 = pd.DataFrame(Active_Power_Dispatch_Tables_Data)
df7.to_csv('ActivePowerDispatchTables.csv')
#df7.to_excel(writer,'ActivePowerDispatchTables')
df11 = pd.DataFrame(Piecewise_Linear_Cost_Curve_Tables_Data)
df11.to_csv('PiecewiseLinearCostCurve.csv')
#df11.to_excel(writer,'PiecewiseLinearCostCurve')
df12 = pd.DataFrame(LTBLNPAIRS)
df12.to_csv('LTBLNPAIRS.csv')
#df12.to_excel(writer,'LTBLNPAIRS')
df13 = pd.DataFrame(GenCostDatacombinedbyTbl)
df13.to_csv('GenCostDatacombinedbyTbl.csv')
#df13.to_excel(writer,'GenCostDatacombinedbyTbl')
#writer.save()
#writer.close()



os.system('csv2gdx CID.csv id=CID values=2..lastCol useHeader=y')
os.system('csv2gdx BusData.csv id=BusData index=2 values=3..lastCol useHeader=y')
os.system('csv2gdx LoadData.csv id=LoadData index=2..3 values=4..lastCol useHeader=y')
os.system('csv2gdx FixedBusShuntData.csv id=FixedBusShuntData index=2..3 values=4..lastCol useHeader=y')
os.system('csv2gdx GeneratorData.csv id=GeneratorData index=2..3 values=4..lastCol useHeader=y')

os.system('csv2gdx GeneratorData.csv id=Gen index=2..3 useHeader=y output=gen.gdx')

os.system('csv2gdx NonTransformerBranchData.csv id=NonTransformerBranchData index=2..4 values=5..lastCol useHeader=y')

os.system('csv2gdx NonTransformerBranchData.csv id=line index=2..4 useHeader=y output=line.gdx')

os.system('csv2gdx TransformerData.csv id=TransformerData index=2..4 values=5..lastCol useHeader=y')

os.system('csv2gdx TransformerData.csv id=xfmr index=2..4 useHeader=y output=xfmr.gdx')

os.system('csv2gdx SwitchedShuntData.csv id=SwitchedShuntData index=2 values=3..lastCol useHeader=y')
os.system('csv2gdx AreaData.csv id=area index=2 useHeader=y')
os.system('csv2gdx Areas.csv id=areas index=2..3 useHeader=y')
os.system('csv2gdx GeneratorDispatchUnitsData.csv id=GeneratorDispatchUnitsData index=2..4 useHeader=y')
os.system('csv2gdx ActivePowerDispatchTables.csv id=ActivePowerDispatchTablesData index=2..3 values=4..lastCol useHeader=y')
os.system('csv2gdx PiecewiseLinearCostCurve.csv id=PiecewiseLinearCostCurveData index=2..3 values=4..lastCol useHeader=y')
os.system('csv2gdx LTBLNPAIRS.csv id=LTBLNPAIRSData index=2 values=3..lastCol useHeader=y')
os.system('csv2gdx GenCostDatacombinedbyTbl.csv id=GenCostDatacombinedbyTbl index=2..4 values=5..lastCol useHeader=y')

os.system('csv2gdx GeneratorDispatchUnitsData.csv id=GenTbl index=2..4 useHeader=y output=GenTbl.gdx')
os.system('csv2gdx ActivePowerDispatchTables.csv id=TblTbl index=2..3 useHeader=y output=TblTbl.gdx')
os.system('csv2gdx PiecewiseLinearCostCurve.csv id=Tblh index=2..3 useHeader=y output=Tblh.gdx')


os.system('csv2gdx UIAGRData.csv id=UIAGRData index=2..3 values=3..lastCol useHeader=y')
os.system('csv2gdx ContingencyLabel.csv id=ContingencyLabel index=2 useHeader=y')
os.system('csv2gdx BranchOutofServiceEvent.csv id=BranchOutofServiceEvent index=2..5 useHeader=y')
os.system('csv2gdx GeneratorOutofServiceEvent.csv id=GeneratorOutofServiceEvent index=2..4 useHeader=y')

os.system('gams MyGams1.gms --havedata=yes')
