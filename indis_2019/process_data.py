#!/usr/bin/python3

import os
import pandas as pd

def process_tstat(directory):
    tcp_log_all = None
    tcp_log_temp = None

    exp_data = {
        "normal": {"start": 0, "end": 0, "mice": None, "elephant": None},
        "loss_0.1": {"start": 0, "end": 0, "mice": None, "elephant": None},
        "loss_0.5": {"start": 0, "end": 0, "mice": None, "elephant": None},
        "loss_1": {"start": 0, "end": 0, "mice": None, "elephant": None},
        "duplicate_1": {"start": 0, "end": 0, "mice": None, "elephant": None},
        "duplicate_5": {"start": 0, "end": 0, "mice": None, "elephant": None},
        "reorder_25": {"start": 0, "end": 0, "mice": None, "elephant": None},
        "reorder_50": {"start": 0, "end": 0, "mice": None, "elephant": None}
    }

    start_end_log = os.path.join(directory, "logs/start_end.log")

    with open(start_end_log, 'r') as f:
        lines = f.readlines()
        for line in lines:
            t = int(line.split(':')[0])
            m = line[line.find(": ")+2:].replace('\n', '').split(' ')
            if m[1] == "normal":
                exp_data[m[1]][m[0].lower()] = t
            else:
                exp_data[f'{m[1]}_{m[2]}'][m[0].lower()] = t

    for root, dirs, files in os.walk(os.path.join(directory, "tstat/raw")):
        for d in sorted(dirs):
            tcp_log = os.path.join(root, d, "log_tcp_complete")
            if os.path.getsize(tcp_log) == 0:
                continue
            tcp_log_temp = pd.read_csv(tcp_log, delim_whitespace=True)
            if tcp_log_all is None:
                tcp_log_all = tcp_log_temp
            else:
                tcp_log_all = tcp_log_all.append(tcp_log_temp)

    #size filters
    filter_s1 = tcp_log_all["c_bytes_uniq:7"] > 80*1024*1024
    filter_s2 = tcp_log_all["c_bytes_uniq:7"] < 150*1024*1024
    filter_s3 = tcp_log_all["c_bytes_uniq:7"] > 900*1024*1024
    
    for exp in exp_data:
        if exp_data[exp]["start"] == 0 or exp_data[exp]["end"] == 0:
            continue
        print (exp)
        #time filters
        #tcp_log_all = tcp_log_all[(tcp_log_all["first:29"].notnull()) | (tcp_log_all["last:30"].notnull())]
        filter_t1 = tcp_log_all["first:29"].fillna(0).astype(int) > exp_data[exp]["start"]*1000
        filter_t2 = tcp_log_all["last:30"].fillna(0).astype(int) < exp_data[exp]["end"]*1000
        #find mice
        exp_data[exp]["mice"] = tcp_log_all[filter_t1 & filter_t2 & filter_s1 & filter_s2]
        #find elephant
        exp_data[exp]["elephant"] = tcp_log_all[filter_t1 & filter_t2 & filter_s3]
        
        print( exp_data[exp]["mice"].shape )
        print( exp_data[exp]["elephant"].shape )
    

    for exp in exp_data:
        if exp_data[exp]["start"] == 0 or exp_data[exp]["end"] == 0:
            continue
        
        try:
            os.makedirs(os.path.join(directory, f"processed/{exp}"))
        except:
            pass

        mice_log = os.path.join(directory, f"processed/{exp}/mice.log")
        elephant_log = os.path.join(directory, f"processed/{exp}/elephant.log")
        
        exp_data[exp]["mice"].to_csv(mice_log, sep=' ', index=False)
        exp_data[exp]["elephant"].to_csv(elephant_log, sep=' ', index=False)

    all_log = os.path.join(directory, f"processed/all.log")
    tcp_log_all.to_csv(all_log, sep=' ', index=False)

if __name__ == "__main__":
    raw_data_dirs = ["cubic/source", "reno/source", "hamilton/source", "bbr/source"]
    #raw_data_dirs = ["cubic/destination", "reno/destination", "hamilton/destination", "bbr/destination"]

    for directory in raw_data_dirs:
        process_tstat(directory)
