import pandas as pd
import numpy as np
import sys
import csv
import re



#load datasets
filedata='indis_2019/reno/source/processed/reorder_25/elephant.log'
savefile='processedfiles/renoreorder25ele.csv'



def load_files_tocsv():
    normal_file=open(filedata,"r")

    normaldf=pd.DataFrame()

    line=normal_file.readline()
    while line !='': #not EOF
        line = line.split()
        rowdata=pd.DataFrame(data=[line])
        normaldf=normaldf.append(rowdata)
        #next line
        line=normal_file.readline()

    print(normaldf)
    
    #change name of the file to save
    normaldf.to_csv(savefile, index=False, header=False)

    normal_file.close()


load_files_tocsv()
    