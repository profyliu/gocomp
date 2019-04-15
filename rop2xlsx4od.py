import numpy as np
import csv
import pandas as pd
import sys

#set display column width
pd.set_option('display.max_colwidth',2000)
pd.set_option('display.max_rows',1000000)
if sys.argv[1] == 'case.rop':
    filename = sys.argv[1]
else:
    filename = sys.argv[1]
    print(filename)

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
Generator_Dispatch_Units_Data.loc[:,"GENID"] = 'GEN' + Generator_Dispatch_Units_Data.loc[:,"GENID"]
Generator_Dispatch_Units_Data.loc[:,"DSPTBL"] = 'TBL' + Generator_Dispatch_Units_Data.loc[:,"DSPTBL"]
Generator_Dispatch_Units_Data["DISP"] = Generator_Dispatch_Units_Data["DISP"].astype('float64')
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

file_path = r'./rop2xls.xlsx'
writer = pd.ExcelWriter(file_path)
df6 = pd.DataFrame(Generator_Dispatch_Units_Data)
df6.to_excel(writer,'GeneratorDispatchUnitsData')
df7 = pd.DataFrame(Active_Power_Dispatch_Tables_Data)
df7.to_excel(writer,'ActivePowerDispatchTables')
df11 = pd.DataFrame(Piecewise_Linear_Cost_Curve_Tables_Data)
df11.to_excel(writer,'PiecewiseLinearCostCurve')
df12 = pd.DataFrame(LTBLNPAIRS)
df12.to_excel(writer,'LTBLNPAIRS')
df13 = pd.DataFrame(GenCostDatacombinedbyTbl)
df13.to_excel(writer,'GenCostDatacombinedbyTbl')
writer.save()
writer.close()
