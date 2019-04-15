import numpy as np
import csv
import pandas as pd
import sys

#set display column width
pd.set_option('display.max_colwidth',1000)
pd.set_option('display.max_rows',1000000)

filename = 'solution1.txt'


linnow = 3
data = pd.read_table(filename,sep='\r\t',header=None,skip_blank_lines=False,engine='python')
#print(data)
Bus_Section = pd.DataFrame(columns = ["i", "v","theta","bcs"])
for i in range(2,len(data)):
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
    #print(strlist)
    if strlist[0].startswith('--'):
        linnow = i
        #print(i)
        break
    Bus_Section = Bus_Section.append(pd.Series((v for v in strlist) ,index=["i", "v","theta","bcs"]), ignore_index=True)
Bus_Section["i"] = Bus_Section["i"].astype('int')
Bus_Section["v"] = Bus_Section["v"].astype('float64')
Bus_Section["theta"] = Bus_Section["theta"].astype('float64')
Bus_Section["bcs"] = Bus_Section["bcs"].astype('float64')
print(Bus_Section)

Generator_Section = pd.DataFrame(columns = ["i", "id", "p", "q"])
for i in range(linnow+2,len(data)):
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
    #print(strlist)
    Generator_Section = Generator_Section.append(pd.Series((v for v in strlist) ,index=["i", "id","p","q"]), ignore_index=True)
Generator_Section["i"] = Generator_Section["i"].astype('int')
Generator_Section["id"] = Generator_Section["id"].astype('int')
Generator_Section["p"] = Generator_Section["p"].astype('float64')
Generator_Section["q"] = Generator_Section["q"].astype('float64')
print(Generator_Section)

file_path = 'txt2xls.xlsx'
writer = pd.ExcelWriter(file_path)
Bus_Section.to_excel(writer,'BusSection',index=False)
Generator_Section.to_excel(writer,'GeneratorSection',index=False)
writer.save()
writer.close()
