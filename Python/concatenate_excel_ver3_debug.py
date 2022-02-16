import encodings
import numpy as np
import pandas as pd
import glob
import datetime
import re
import json
import openpyxl

#現在時刻を取得
dt_now = datetime.datetime.now()
dt_now_str = dt_now.strftime('%Y%m%d%H%M')

file_list = glob.glob("/Users/try21/OneDrive/デスクトップ/Baiyo/*.xlsx")

new_cols = ['Experimenter','Experiment_date','Index','Cell_line','Vial','Passage','Start','Day','State',
'Protocol','Description','Do','Condition','Factors','Factors_n','Data','Data_n','Cells_per_well','Live_cells','Memo','mTime']
df_out = pd.DataFrame(columns=new_cols) # 出力用のDataFrame, 列名はnew_colsで指定

for file in file_list:
    try:
        header = pd.read_excel(file).columns.values # 先に1行目をリストとして取得しておく
    except:
        print(file) # 日付が「標準」でなく「日付」になっているセルを含むファイルを表示