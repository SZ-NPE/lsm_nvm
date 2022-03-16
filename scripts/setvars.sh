#!/bin/bash

# 设置相应的路径信息
export NOVELSMSRC=$PWD
export NOVELSMSCRIPT=$NOVELSMSRC/scripts
export DBBENCH=$NOVELSMSRC/out-static

# 设置 PMEM 的路径
export TEST_TMPDIR=/mnt/pmemdir
#DRAM buffer size in MB
export DRAMBUFFSZ=64
#NVM buffer size in MB
export NVMBUFFSZ=4096
# 设置对应的配置文件的路径
export INPUTXML=$NOVELSMSCRIPT/input.xml

# 原始的 LevelDB 1.20
#Vanilla LevelDB benchmark
export LEVELDB_VANILLA=$NOVELSMSRC/leveldb-1.20
# 原始的 LevelDB 静态库路径
export DBBENCH_VANLILLA=$LEVELDB_VANILLA/out-static
# 几个属性
export PARA=40
# 倾向于从 socket 0 上分配内存和使用 CPU
export NUMA_AFFINITY=0
#Numa binding 
export APP_PREFIX="numactl --membind=$NUMA_AFFINITY --cpunodebind=$NUMA_AFFINITY"
#export APP_PREFIX=""
