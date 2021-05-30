import csv
import datetime
import glob
import os
import re
import time

# 実行時間の計測
start_time = time.time() # 開始時間

#現在時刻を取得
dt_now = datetime.datetime.now()
dt_now_str = dt_now.strftime('%Y%m%d%H%M')

# パスの指定（適宜変更を）
path = 'G:/Data/Envision/renamed/*/*ATP*.csv' # 普通のスラッシュでもいける
out_path = 'C:/Users/try21/OneDrive/デスクトップ/ATP_results_' + dt_now_str + '.csv'

new_file = open(out_path, 'w') # 書き出すファイル
new_file.write('Assay_date,Assay_type,Plate_ID_date,Plate_ID_number,Well_number,Luminescence\n')
f_list = glob.glob(path, recursive=True) # CSVファイルの一覧をリストで取得

for f in f_list:
    fname = os.path.basename(f) # 測定年月日_LDH_Plate-ID-date_Plate-ID-number.csv
    fname = fname.replace('_', ',').replace('.csv', ',') # カンマに変換しておく
    well_number = 1 # カウンター
    odd_row_flag = True # 1行目の
    odd_col_flag = True # 1列目からスタート
    with open(f) as csv_file:
        reader = csv.reader(csv_file)
        l = [row for row in reader] # 二次元のリストに変換
        l = l[10:18] # 測定値の行だけ抜き出す
        for row in l:
            row = row[1:13] # 測定値が入っている列だけ抜き出す
            for col in row:
                data = fname + str(well_number) + ',' + col
                new_file.write(data) # 書き出す
                new_file.write('\n')
                well_number += 1

# ファイルを閉じる
new_file.close()

# 実行時間の出力
elapsed_time = time.time() - start_time # 経過秒数
print('')
print('Completed...')
print('Elapsed_time: {0}'.format(round(elapsed_time, 2)) + ' sec')

# 最後に入力待ちにして、コマンドプロンプトを閉じない
print('')
input('Press Enter key...')