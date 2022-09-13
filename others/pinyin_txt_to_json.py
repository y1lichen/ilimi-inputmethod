# 將肥米輸入法的注音字典轉為json檔案
import json

# 初始化注符關係字典
def init_dict(r1, r2):
    key_list = r1.split(' ')
    bpmf_list = r2.split(' ')
    key_bpmf_dict = {}
    for i in range(len(key_list)):
        key_bpmf_dict[key_list[i]] = bpmf_list[i]
    return key_bpmf_dict
    
#
def create_json_by_line(dict, row):
    elements_list = row.split(' ')
    chars = []
    for i in range(1, len(elements_list)):
        chars.append(elements_list[i])
    dict[elements_list[0]] = chars


with open('./pinyin.txt') as f:
    # skip first line
    f.readline()
    r1 = f.readline().rstrip()
    r2 = f.readline().rstrip()
    key_bpmf_dict = init_dict(r1, r2)
    json_dict = {}
    line = f.readline()
    while line:
        create_json_by_line(json_dict, line.strip())
        line = f.readline()
    filename = 'pinyin.json'
    with open(filename, 'w') as f:
        json.dump(json_dict, f, ensure_ascii=False, indent=4)
