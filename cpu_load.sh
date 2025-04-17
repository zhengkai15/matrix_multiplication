#!/bin/bash
set -x 
# 检查是否提供了使用率参数
if [ $# -ne 1 ]; then
    echo "Usage: $0 <target_cpu_usage_percentage>"
    exit 1
fi

# 获取目标 CPU 使用率
target_usage=$1

# 检查目标使用率是否在 1 到 100 之间
if [ $target_usage -lt 1 ] || [ $target_usage -gt 100 ]; then
    echo "Target CPU usage must be between 1 and 100."
    exit 1
fi

# 获取 CPU 核心数
cpu_cores=$(nproc)

# 计算每个核心的工作时间和空闲时间比例
work_time=$((target_usage * 10))
idle_time=$((1000 - work_time))

# 定义一个函数来模拟 CPU 负载
cpu_load() {
    while true; do
        start_time=$(date +%s%N)
        end_time=$((start_time + work_time * 1000000))  # 转换为纳秒
        while [ $(date +%s%N) -lt $end_time ]; do
            :  # 空操作，占用 CPU
        done
        sleep_time=$(echo "scale=3; $idle_time / 1000" | bc)
        sleep $sleep_time
    done
}
# 为每个核心启动一个负载进程
for ((i = 0; i < cpu_cores; i++)); do
    cpu_load &
done

# # 等待所有子进程结束
wait

# dd if=/dev/zero of=/dev/null
# bash cpu_load.sh 50 # CPU 使用率达到 50%
