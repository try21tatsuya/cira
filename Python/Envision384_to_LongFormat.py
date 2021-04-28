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
path = 'G:/Data/Envision/renamed/*/*LDH*.csv' # 普通のスラッシュでもいける
out_path = 'C:/Users/try21/OneDrive/デスクトップ/LDH_results_' + dt_now_str + '.csv'

new_file = open(out_path, 'w') # 書き出すファイル
new_file.write('Assay_date,Assay_type,Plate_ID_date,Assay_Plate_number,Well_number_384,Plate_ID_number,Well_number,Absorbance\n')
f_list = glob.glob(path, recursive=True) # CSVファイルの一覧をリストで取得

for f in f_list:
    fname = os.path.basename(f) # 測定年月日_LDH_Plate-ID-date_Plate-ID-number(1-3).csv
    fname = fname.replace('_', ',').replace('.csv', ',') # カンマに変換しておく
    LDH_plate_number = int(fname.split(',')[3]) # ファイル名から、何枚目のLDHプレートかを取得して、intergerに変換
    odd_row_flag = True # 1行目の
    odd_col_flag = True # 1列目からスタート
    well_number_384 = 1
    #print(LDH_plate_number)
    with open(f) as csv_file:
        reader = csv.reader(csv_file)
        l = [row for row in reader] # 二次元のリストに変換
        l = l[10:26] # 測定値の行だけ抜き出す
        well_number = 1 # もとのwell_number
        for row in l:
            row = row[1:25] # 測定値が入っている列だけ抜き出す
            for col in row:
                # もとのplate_ID_numberをLDH_plate_number中の位置から求める
                if odd_row_flag and odd_col_flag: # 奇数行でかつ奇数列なら、もとのplate_ID_numberはLDH_plate_numberと同じ
                    plate_ID_number = LDH_plate_number
                elif odd_row_flag and (not odd_col_flag): # 奇数行でかつ偶数列なら、もとのplate_ID_numberはLDH_plate_number+6
                    plate_ID_number = LDH_plate_number + 6
                elif (not odd_row_flag) and odd_col_flag: # 偶数行でかつ奇数列なら、もとのplate_ID_numberはLDH_plate_number+3
                    plate_ID_number = LDH_plate_number + 3
                else: # 偶数行でかつ偶数列なら、もとのplate_ID_numberはLDH_plate_number+9
                    plate_ID_number = LDH_plate_number + 9
                data = fname + str(well_number_384) + ',' + str(plate_ID_number) + ',' + str(well_number) + ',' + col
                #print(well_number_384, odd_col_flag, odd_row_flag)
                new_file.write(data) # 書き出す
                new_file.write('\n')
                if well_number_384 % 2 == 0:
                    well_number += 1
                if odd_row_flag and well_number_384 % 24 == 0: # 奇数行で端(24列目)まで行ったら、一旦11引いて戻る
                    well_number = well_number - 12
                well_number_384 += 1
                odd_col_flag = not odd_col_flag # 1回ごとに奇数列と偶数列が入れ替わる
                if (well_number_384 - 1) % 24 == 0:
                    odd_row_flag = not odd_row_flag # 24wellごとに次のrowにいく

# ファイルを閉じる
new_file.close()

# 実行時間の出力
elapsed_time = time.time() - start_time # 経過秒数
print('')
print('Completed...')
print('Elapsed_time: {0}'.format(round(elapsed_time, 2)) + ' sec')