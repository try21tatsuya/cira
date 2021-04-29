import csv
import json
import math
import re

old_tsv = open('/Users/try21/OneDrive/デスクトップ/Baiyo/Baiyo_log/Baiyo_log.tsv', encoding='utf-8', newline='')
reader = csv.reader(old_tsv, delimiter='\t')
rows = [row for row in reader] # 二次元のリストに変換
rows = rows[1:] # 0行目を削除

new_file = open('C:/Users/try21/OneDrive/デスクトップ/new_Baiyo_log.tsv', 'w') # 書き出すファイル
new_file.write('Experimenter\tExperiment_date\tIndex\tCell_line\tVial\tPassage\tStart\tDay\tState\tProtocol\tDescription\tDo\tCondition\tFactors\tFactors_n\tData\tData_n\tCells_per_well\tLive_cells\tMemo\tmTime\n')

for i in rows:
    filename = re.split('[/_.\\\]', i[16]) # ファイル名をsplitして、「実験者」と「実験日」を取得
    experimenter = filename[-3]
    experiment_date = filename[-2]

    # stateが'M'ならデフォルトでProtocolは'1'に、それ以外（stateが'I'）ならデフォルトでProtocolは'0'に
    if i[5] == 'M':
        protocol = '1'
    else:
        protocol = '0'
    # data列の表記を、Data列の新しい表記に変換
    data = i[8]
    data = data.replace('Cell_count', 'CC').replace('Organoid_sizes', 'OS').replace('Organoid_size', 'OS').replace('Day2_score', 'score').replace('Day3_score', 'score').replace('Day10_score', 'score')

    # Dataの列とdata2～data5の列の内容を統合して、Data_n列にjson形式で書き出す
    data_dic = {}
    data_list = [x.strip() for x in data.split(sep=',')]
    pattern = re.compile(r'.0$') # 「.0」で終わっているデータ(str)を検索して、一旦floatにした後、intに直す
    for j in range(len(data_list)):
        if data_list[j] == 'CC' or data_list[j] == 'Confluency': continue # data2～data5の列に対応するデータがないものはスキップ
        if bool(pattern.search(i[12+j])):
            data_dic[data_list[j]] = math.floor(float(i[12+j]))
        else:
            data_dic[data_list[j]] = i[12+j]
    data_n = json.dumps(data_dic)
    
    # タブ区切りのnew_lineを作成して、書き出す
    new_line = experimenter + '\t' + experiment_date + '\t' + i[0] + '\t' + i[1] + '\t' + '' + '\t' + i[2] + '\t' + i[3] + '\t' + i[4] + '\t' + i[5] + '\t' + protocol + '\t' + i[6] + '\t' + i[7] + '\t' + i[9] + '\t' + '' + '\t' + '' + '\t' + data + '\t' + data_n + '\t' + i[10] + '\t' + i[11] + '\t' + '' + '\t\n'

    new_file.write(new_line)

# ファイルを閉じる
old_tsv.close()
new_file.close()