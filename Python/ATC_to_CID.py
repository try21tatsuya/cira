import csv
import json
import sys

with open(sys.argv[1], 'r') as f:
    all_data = json.load(f)

annotations = all_data['Annotations']
#print(annotations.keys()) # ['Annotation', 'Page', 'TotalPages']
#print(type(annotations['Annotation'])) # listになっている
#print(type(annotations['Annotation'][0])) # dict

entries = annotations['Annotation']

with open('ATC_to_CID.csv', 'w', newline='') as f:
    for i in range(len(entries)):
        annotation = entries[i]
        data = annotation['Data'][0]
        entry = data['Value']['StringWithMarkup'][-1]['String'] # 一番下の階層（添え字[-1]）のATC codeだけ取得
        #print(entry)
        ATC_code = entry.split(' - ')[0]
        drug = entry.split(' - ')[1]
        CID = annotation['LinkedRecords']['CID'][0]
        #print(CID)
        csvwriter = csv.writer(f, delimiter=',', quotechar='"', quoting=csv.QUOTE_NONNUMERIC)
        csvwriter.writerow([ATC_code, drug, CID])