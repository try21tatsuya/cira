import os
import re
import shutil
import time
from datetime import datetime

# コピーする画像の検索条件を入力させる
try:
    start_date = datetime.strptime(input('\nコピーを行う開始日を入力\n'), '%Y%m%d')
except ValueError as e:
    print('西暦で年月日を入力すること（例）20210416', e)

try:
    end_date = datetime.strptime(input('コピーを行う終了日を入力\n'), '%Y%m%d')
except ValueError as e:
    print('西暦で年月日を入力すること（例）20210416', e)

# 実行時間の計測
start_time = time.time() # 開始時間

# パスの指定（適宜変更を）
search_path = 'E:/Data_2021/CQ1' # 普通のスラッシュでもいける
out_path = 'C:/Users/try21/OneDrive/デスクトップ/test'

dir_list = os.listdir(search_path) # os.listdirでディレクトリの一覧をリストで取得できる

def copy_files(d):
    path = search_path + '/' + d + '/Image'
    file_list = os.listdir(path)
    print('Copying...  ', end='') # コピー中のフォルダを出力するようにしてみた
    print(d)
    for f in file_list:
        original_file = path + '/' + f # shutil.copy2では絶対パスでの指定が必要である
        new_fname = d + f
        new_fname = re.sub('[CFTWZ]', '_', new_fname)
        new_fname = out_path + '/' + new_fname
        shutil.copy2(original_file, new_fname) # shutil.copy2はメタデータもコピーされ、ファイル作成日に変更が生じない

for d in dir_list:
    dirname = re.split('[T_]', d) # ファイル名をsplitして、
    if start_date <= datetime.strptime(dirname[2], '%Y%m%d') <= end_date: # datetime型に変換したdirname[2]が検索条件を満たすか判断
        copy_files(d) # Trueならフォルダを開いて、コピーを実行

# 実行時間の出力
elapsed_time = time.time() - start_time # 経過秒数
print('')
print('Completed...')
print('Elapsed_time: {0}'.format(round(elapsed_time, 2)) + ' sec')