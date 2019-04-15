import numpy as np
import csv
import pandas as pd
import sys

#set display column width
pd.set_option('display.max_colwidth',1000)
if sys.argv[1] == 'case.inl':
    filename = sys.argv[1]
else:
    filename = sys.argv[1]
    print(filename)

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

    if strlist[0].startswith("0"):
        #print('End of data')
        linnow = i
        #print(i)
        break
    Unit_Inertia_and_Governor_Response_Data = Unit_Inertia_and_Governor_Response_Data.append(pd.Series((v for v in strlist) ,index=["I", "ID", "H", "PMAX", "PMIN", "R", "D"]), ignore_index=True)
#Unit_Inertia_and_Governor_Response_Data.loc[:,"I"] = 'BUS' + Unit_Inertia_and_Governor_Response_Data.loc[:,"I"]
Unit_Inertia_and_Governor_Response_Data["I"] = Unit_Inertia_and_Governor_Response_Data["I"].astype('int')
Unit_Inertia_and_Governor_Response_Data.loc[:,"ID"] = 'GEN' + Unit_Inertia_and_Governor_Response_Data.loc[:,"ID"]
Unit_Inertia_and_Governor_Response_Data["H"] = Unit_Inertia_and_Governor_Response_Data["H"].astype('float64')
Unit_Inertia_and_Governor_Response_Data["PMAX"] = Unit_Inertia_and_Governor_Response_Data["PMAX"].astype('float64')
Unit_Inertia_and_Governor_Response_Data["PMIN"] = Unit_Inertia_and_Governor_Response_Data["PMIN"].astype('float64')
Unit_Inertia_and_Governor_Response_Data["R"] = Unit_Inertia_and_Governor_Response_Data["R"].astype('float64')
Unit_Inertia_and_Governor_Response_Data["D"] = Unit_Inertia_and_Governor_Response_Data["D"].astype('float64')

file_path = r'./inl2xls.xlsx'
writer = pd.ExcelWriter(file_path)
df = pd.DataFrame(Unit_Inertia_and_Governor_Response_Data)
df.to_excel(writer,'UIAGRData')

writer.save()
writer.close()
