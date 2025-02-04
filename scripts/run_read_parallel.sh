#!/bin/bash
#set -x

NUMTHREAD=1
BENCHMARKS="fillrandom,readrandom,stats"
NUMKEYS="1000000"
#NoveLSM specific parameters
#NoveLSM uses memtable levels, always set to num_levels 2
#write_buffer_size DRAM memtable size in MBs
#write_buffer_size_2 specifies NVM memtable size; set it in few GBs for perfomance;
OTHERPARAMS="--num_levels=2 --write_buffer_size=$DRAMBUFFSZ --nvm_buffer_size=$NVMBUFFSZ"
NUMREADTHREADS="1"
VALUSESZ=16384

SETUP() {
  source $NOVELSMSCRIPT/setvars.sh
  if [ ! -z "$TEST_TMPDIR" ]; then
      rm -rf $TEST_TMPDIR/*
  fi
}

MAKE() {
  cd $NOVELSMSRC
  #make clean
  make -j8
}

# 检查参数以及编译
SETUP
MAKE

# 读线程为 0，即只有一个主线程去读
echo " "
echo "**************************************"
echo "  Without Read Threading              "
echo "**************************************"
echo " "

$APP_PREFIX $DBBENCH/db_bench --threads=$NUMTHREAD --num=$NUMKEYS --benchmarks=$BENCHMARKS \
	--value_size=$VALUSESZ $OTHERPARAMS --num_read_threads=0
SETUP

# 读线程为 1，需要检查 dbbench 实现
#Run all benchmarks
echo " "
echo "**************************************"
echo "  With Read Threading                 "
echo "**************************************"
echo " "
$APP_PREFIX $DBBENCH/db_bench --threads=$NUMTHREAD --num=$NUMKEYS --benchmarks=$BENCHMARKS \
	 --value_size=$VALUSESZ $OTHERPARAMS --num_read_threads=$NUMREADTHREADS

set +x
