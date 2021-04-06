import numpy as np
import pandas as pd
import glob
import datetime
import re
import json
import openpyxl # .xlsxを開くのに必要

#現在時刻を取得
dt_now = datetime.datetime.now()
dt_now_str = dt_now.strftime('%Y%m%d%H%M')

file_list = glob.glob("/Users/try21/OneDrive/デスクトップ/Baiyo/*.xlsx")

new_cols = ['Experimenter','Experiment_date','Index','Cell_line','Vial','Passage','Start','Day','State',
'Protocol','Description','Do','Condition','Factors','Factors_n','Data','Data_n','Cells_per_well','Live_cells','Memo','mTime']
df_out = pd.DataFrame(columns=new_cols) # 出力用のDataFrame, 列名はnew_colsで指定

for file in file_list:
    header = pd.read_excel(file).columns.values # 先に1行目をリストとして取得しておく
    if header[2] == 'ver_2': # フォーマットが'ver_2'かどうかで処理を分ける
        df = pd.read_excel(file, header=1, skiprows=0, dtype=str) # あらためて2行目をheaderに指定して取り込み, 1行目はskip
        df = df.replace(np.nan, ' ', regex=True) # 欠損値は空白にする
        filename = re.split('[/_.\\\]', file) # ファイル名をsplitして、「実験者」と「実験日」を取得
        df['Experimenter'] = filename[-3]
        df['Experiment_date'] = filename[-2]
        df['Index'] = df.index.values # 行番号を取得
        df['Start'] = df['Start-y'].str.cat(df['Start-md']) # Start-yとStart-mdを連結して、新たな列を作成
        
        # header行9列目のデフォルトのfactorsとFactors列の新しい因子の情報を統合して、Factors_n列を作成する
        factors = [x.strip() for x in header[9].split(sep=',')] # その日に使用していたデフォルトのfactors(header[9])をカンマでsplitしてリストで取得
        factors_dic = {} # 一日毎のデフォルトのfactorsを格納する辞書を作成
        for factor in factors:
            factor = factor.split(sep='_') # 一旦リストに分割
            key = factor.pop(0) # 最初の要素をkeyとして取り出して、
            factors_dic[key] = '_'.join(factor) # 残りをもう一度結合し、辞書に格納
        list_for_Factors_n = [] # 以下の処理でjson.dumps(copy_of_factors_dic)を追加していくために、最初にリストを作成しておく
        for row in df.itertuples(): # DataFrameを一行ずつ処理（タプルが返ってくることに注意）
            copy_of_factors_dic = factors_dic # 一日毎のデフォルトのfactors_dicは更新しないように、copyを作成して利用する
            factors_new = {} # 「Factors」の列に記載されている新しい因子について、辞書を作成していく(forループ内で(row毎に)作成している事に留意)
            new_factors = [x.strip() for x in row[13].split(sep=',')] # タプル「row」中で「Factors」に相当するrow[13]に記載されている新しい因子につきリストを作成
            for new_factor in new_factors:
                new_factor = new_factor.split(sep='_') # 一旦リストに分割
                key = new_factor.pop(0) # 最初の要素をkeyとして取り出して、
                factors_new[key] = '_'.join(new_factor) # 残りをもう一度結合し、辞書に格納
            #print(factors_new) # ここまではできてる
            copy_of_factors_dic.update(factors_new)
            #print(row[22], copy_of_factors_dic, '\n') # ここもいけてる
            list_for_Factors_n.append(json.dumps(copy_of_factors_dic)) # copy_of_factors_dicをjson形式に変換してリストに追加
        df['Factors_n'] = list_for_Factors_n
        #print(df['Factors_n']) # いけたっぽい

        # Dataの列とData_1～Data_4の列の内容を統合して、Data_n列にjson形式で書き出す
        list_for_Data_n = [] # json.dumpsの結果を追加していくために、最初にリストを作成しておく
        for row in df.itertuples():
            Data_dic = {}
            Data_n = [x.strip() for x in row[11].split(sep=',')] # タプル「row」中で「Data」に相当するrow[11]に記載されている内容につきリストを作成
            for i in range(len(Data_n)):
                if Data_n[i] == 'CC' or Data_n[i] == 'Confluency': continue # Data_1～Data_4の列に対応するデータがないものはスキップ
                Data_dic[Data_n[i]] = row[14+i]
            #print(Data_dic)
            list_for_Data_n.append(json.dumps(Data_dic))
        df['Data_n'] = list_for_Data_n

        df['mTime'] = dt_now_str
        df_out = pd.concat([df_out, df])

df_out = df_out.iloc[:,0:21]

# tsvとして保存
fname = 'Baiyo_log_' + dt_now_str + '.tsv'
df_out.to_csv(fname, sep='\t', index=False)

# csvとして保存
fname2 = 'Baiyo_log_' + dt_now_str + '.csv'
df_out.to_csv(fname2, index=False)