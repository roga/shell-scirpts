#!/usr/bin/env bash

netstat -np | grep SYN_REC
# 檢查有多少 SYN_REC

netstat -np | grep SYN_REC | awk '{print $5}' | awk -F: '{print $1}'
# 檢查有多少 IP 送 SYN_REC

netstat -np | grep TIME_WAIT | awk '{print $5}' | awk -F: '{print $1}'
# 檢查有多少 IP 處於 TIME_WAIT 狀態 (Debian 預設 TIME_WAIT 是 60 秒, cat /proc/sys/net/ipv4/tcp_fin_timeout 可以看到 )

netstat -ntu | awk '{print $5}' | cut -d: -f1 | sort | uniq -c | sort -n
# 檢查單一 IP 對 Server 的連數

netstat -anp | grep 'tcp\|udp' | awk '{print $5}' | cut -d: -f1 | sort | uniq -c | sort -n
# 檢查單一 IP 對 Server 的連線數 (包含 tcp/udp)

netstat -plan | grep :80 | awk {'print $5'} | cut -d: -f 1| sort | uniq -c | sort -nk 1
# 檢查單一 IP 對 Port 80 的連線數

netstat -n | awk '/^tcp/ {++state[$NF]} END {for(key in state) print key,"\t",state[key]}'
# 列出各種狀態的連線數 (SYN_RECV, TIME_WAIT, ESTABLISHED..等等)

