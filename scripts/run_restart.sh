#!/bin/bash
#set -x

# 设置相关参数，使用了 dbbench
NUMTHREAD="--threads=1"
NUMKEYS="--num=1000000"
#NoveLSM specific parameters
#NoveLSM uses memtable levels, always set to num_levels 2
#write_buffer_size DRAM memtable size in MBs
#nvm_buffer_size specifies NVM memtable size; set it in few GBs for perfomance;
DBMEM="--db_mem=/mnt/pmemdir/dbbench --db_disk=/mnt/pmemdir/dbbench"
OTHERPARAMS="--num_levels=2 --write_buffer_size=$DRAMBUFFSZ --nvm_buffer_size=$NVMBUFFSZ $DBMEM"
VALUSESZ="--value_size=4096"
WRITE="--benchmarks=fillrandom"
READ="--benchmarks=readrandom"
PARAMS="$NUMTHREAD $NUMKEYS $WRITE $VALUSESZ $OTHERPARAMS"

# 检查测试 DB 路径，其实使用的 pmem 挂载路径
SETUP() {
  if [ -z "$TEST_TMPDIR" ] 
  then
        echo "DB path empty. Run source scripts/setvars.sh from source parent dir"
	exit
  fi

  # 清理原来的数据
  rm -rf $TEST_TMPDIR/*
  mkdir -p $TEST_TMPDIR
}

# 编译 NoveLSM
MAKE() {
  cd $NOVELSMSRC
  #make clean
  make -j8
  # 进入脚本目录
  cd $NOVELSMSCRIPT
}

# 杀死运行的 dbbench 进程
KILL() {
  #Wait for 5 seconds and kill the process
  sleep 5
  echo " "
  echo "Randomly killing benchmark before execution completion..."

  # 使用 pgrep 查询 db_bench 进程 ID，然后赋值给 pids
  # 然后 kill 掉对应的进程
  pids=$(pgrep db_bench) && kill -9 $pids
  sleep 5
  echo " "
  echo "Restarting benchmark"
  echo " "
}


# 后台运行，其实就是多个了 &
RUNBG() {
# 绑定 numa 节点到 0
# 传入 DB 相关的参数，并执行随机写负载
$APP_PREFIX $DBBENCH/db_bench $PARAMS $WRITE &
}

# 前台运行
RUN() {
# 绑定 NUMA 节点
# 传入 DB 相关的参数，并执行随机写负载
$APP_PREFIX $DBBENCH/db_bench $PARAMS $WRITE
}

# 重启
RESTART() {
# NUMA 绑核
# 传入相关参数，并执行随机读负载
$APP_PREFIX $DBBENCH/db_bench $PARAMS $READ
}

# 搭建环境并编译
SETUP
MAKE


#Simply run a write workload, wait for it to finish, and re-read data
echo " "
echo " "

# 前台运行负载
RUN
echo " "
echo "**************************************"
echo "  SIMPLE RESTART WITHOUT FAILURE      "
echo "**************************************"
echo " "

# 运行读负载
RESTART

#Run as a background task, then kill the benchmark and restart
#TODO: LevelDB (or may be our bug) does not release this lock.
# So we shamelessly delete it. To be fixed.
echo " "
echo " "

# 后台运行写负载
RUNBG

# 异常中断进程
KILL
echo " "
echo " "
echo "**************************************"
echo " RESTART WITH FAILURE    "
echo "**************************************"
echo " "

# 释放锁
rm /mnt/pmemdir/dbbench/LOCK

# 重启继续读
RESTART
