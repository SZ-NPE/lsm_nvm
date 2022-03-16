#!/bin/bash
#set -x
NUMTHREAD=1
BENCHMARKS="fillrandom,readrandom"
NUMKEYS="1000000"

# Buffer 64MB
let BUFFBYTES=$DRAMBUFFSZ*1024*1024
OTHERPARAMS="--write_buffer_size=$BUFFBYTES"
VALUSESZ=4096

# 检查 PMEM 挂载的路径是否为空
SETUP() {
  if [ -z "$TEST_TMPDIR" ]
  then
        echo "DB path empty. Run source scripts/setvars.sh from source parent dir"
        exit
  fi
  rm -rf $TEST_TMPDIR/*
  mkdir -p $TEST_TMPDIR
}

# 编译 leveldb1.20
MAKE() {
  cd $LEVELDB_VANILLA
  #make clean
  make -j8
}

SETUP
MAKE

# 运行 dbbench
# 单线程 100w keys，随机写随机读，value4K，buffer 大小 64M
$DBBENCH_VANLILLA/db_bench --threads=$NUMTHREAD --num=$NUMKEYS --benchmarks=$BENCHMARKS --value_size=$VALUSESZ $OTHERPARAMS
SETUP

# 运行所有类型的 dbbench 负载
#Run all benchmarks
$DBBENCH_VANLILLA/db_bench --threads=$NUMTHREAD --num=$NUMKEYS --value_size=$VALUSESZ $OTHERPARAMS

