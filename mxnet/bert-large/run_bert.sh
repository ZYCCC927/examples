#!/bin/bash

# install gluon-nlp under this dir
cd /home/cluster/byteps/examples/mxnet/bert-large/gluon-nlp
python3 setup.py install

# prepare dict 
mkdir -p /home/cluster/.mxnet/models
cd /home/cluster/.mxnet/models 
wget https://apache-mxnet.s3-accelerate.dualstack.amazonaws.com/gluon/dataset/vocab/book_corpus_wiki_en_uncased-a6607397.zip
apt-get install unzip
unzip *.zip

# below params are used in T4-16GB, with synthetic data
export dmlc_num_server=2
export dmlc_num_worker=2
export dmlc_ps_root_uri='172.31.21.133'

# baseline
export use_bytescheduler=0
export bytescheduler_queue_type=0
export bytescheduler_partition=8000000
export bytescheduler_credit=160000000
export bytescheduler_credit_tuning=0
export bytescheduler_partition_tuning=0

# schedule
#export use_bytescheduler=1
#export bytescheduler_queue_type=0
#export bytescheduler_partition=480000000
#export bytescheduler_credit=480000000
#export bytescheduler_credit_tuning=0
#export bytescheduler_partition_tuning=0

# partition
#export use_bytescheduler=1
#export bytescheduler_queue_type=1
#export bytescheduler_partition=4096000
#export bytescheduler_credit=20000000
#export bytescheduler_credit_tuning=0
#export bytescheduler_partition_tuning=0

# bytescheduler
#export use_bytescheduler=1
#export bytescheduler_queue_type=0
#export bytescheduler_partition=4096000
#export bytescheduler_credit=20000000
#export bytescheduler_credit_tuning=0
#export bytescheduler_partition_tuning=0

export COMMAND='python3 /home/cluster/byteps/examples/mxnet/bert-large/gluon-nlp/scripts/bert/run_pretraining.py  --data=/data/book-corpus/book-corpus-large-split/*.train,/data/enwiki/enwiki-feb-doc-split/*.train --data_eval=/data/book-corpus/book-corpus-large-split/*.test,/data/enwiki/enwiki-feb-doc-split/*.test --optimizer bertadam --warmup_ratio 0.1 --num_steps 281250 --ckpt_interval 300000000 --ckpt_dir ckpt_stage1_lamb_16k-682a361-c5fd6fc-0412-cu90  --lr 0.00354 --accumulate 1 --model bert_24_1024_16 --max_seq_length 128 --max_predictions_per_seq 20 --num_data_workers 4 --no_compute_acc --comm_backend bytescheduler --log_interval 10  --total_batch_size 32  --total_batch_size_eval 32 --synthetic_data --eval_use_npz'

# scheduler
DMLC_ROLE='scheduler' DMLC_NUM_SERVER=$dmlc_num_server DMLC_NUM_WORKER=$dmlc_num_worker USE_BYTESCHEDULER=$use_bytescheduler BYTESCHEDULER_QUEUE_TYPE=$bytescheduler_queue_type BYTESCHEDULER_PARTITION=$bytescheduler_partition BYTESCHEDULER_CREDIT=$bytescheduler_credit DMLC_PS_ROOT_URI=$dmlc_ps_root_uri DMLC_PS_ROOT_PORT=8000 BYTESCHEDULER_CREDIT_TUNING=$bytescheduler_credit_tuning BYTESCHEDULER_PARTITION_TUNING=$bytescheduler_partition_tuning PS_SLICER=0 KVSTORE_MAP_KIND=0 KVSTORE_MAP_MODEL=1 $COMMAND > /home/cluster/byteps/examples/mxnet/bert-large/scheduler.txt &

# server
ssh cluster@172.31.21.133 "cd /home/cluster/byteps/examples/mxnet/bert-large/gluon-nlp/scripts/bert;DMLC_ROLE='server' DMLC_NUM_SERVER=$dmlc_num_server DMLC_NUM_WORKER=$dmlc_num_worker USE_BYTESCHEDULER=$use_bytescheduler BYTESCHEDULER_QUEUE_TYPE=$bytescheduler_queue_type BYTESCHEDULER_PARTITION=$bytescheduler_partition BYTESCHEDULER_CREDIT=$bytescheduler_credit DMLC_PS_ROOT_URI=$dmlc_ps_root_uri DMLC_PS_ROOT_PORT=8000 BYTESCHEDULER_CREDIT_TUNING=$bytescheduler_credit_tuning BYTESCHEDULER_PARTITION_TUNING=$bytescheduler_partition_tuning PS_SLICER=0 KVSTORE_MAP_KIND=0 KVSTORE_MAP_MODEL=1 $COMMAND >/home/cluster/byteps/examples/mxnet/bert-large/server.txt 2>&1 &" &
ssh cluster@172.31.25.63 "cd /home/cluster/byteps/examples/mxnet/bert-large/gluon-nlp/scripts/bert;DMLC_ROLE='server' DMLC_NUM_SERVER=$dmlc_num_server DMLC_NUM_WORKER=$dmlc_num_worker USE_BYTESCHEDULER=$use_bytescheduler BYTESCHEDULER_QUEUE_TYPE=$bytescheduler_queue_type BYTESCHEDULER_PARTITION=$bytescheduler_partition BYTESCHEDULER_CREDIT=$bytescheduler_credit DMLC_PS_ROOT_URI=$dmlc_ps_root_uri DMLC_PS_ROOT_PORT=8000 BYTESCHEDULER_CREDIT_TUNING=$bytescheduler_credit_tuning BYTESCHEDULER_PARTITION_TUNING=$bytescheduler_partition_tuning PS_SLICER=0 KVSTORE_MAP_KIND=0 KVSTORE_MAP_MODEL=1 $COMMAND >/home/cluster/byteps/examples/mxnet/bert-large/server.txt 2>&1 &" &
#ssh cluster@172.31.25.63 "cd /home/cluster/byteps/bytescheduler/examples/mxnet-image-classification;DMLC_ROLE='server' DMLC_NUM_SERVER=$dmlc_num_server DMLC_NUM_WORKER=$dmlc_num_worker USE_BYTESCHEDULER=$use_bytescheduler BYTESCHEDULER_QUEUE_TYPE=$bytescheduler_queue_type BYTESCHEDULER_PARTITION=$bytescheduler_partition BYTESCHEDULER_CREDIT=$bytescheduler_credit DMLC_PS_ROOT_URI=$dmlc_ps_root_uri DMLC_PS_ROOT_PORT=8000 BYTESCHEDULER_CREDIT_TUNING=$bytescheduler_credit_tuning BYTESCHEDULER_PARTITION_TUNING=$bytescheduler_partition_tuning PS_SLICER=0 KVSTORE_MAP_KIND=0 KVSTORE_MAP_MODEL=1 $COMMAND &" &
#ssh cluster@172.31.94.128 "cd /home/cluster/byteps/bytescheduler/examples/mxnet-image-classification;DMLC_ROLE='server' DMLC_NUM_SERVER=$dmlc_num_server DMLC_NUM_WORKER=$dmlc_num_worker USE_BYTESCHEDULER=$use_bytescheduler BYTESCHEDULER_QUEUE_TYPE=$bytescheduler_queue_type BYTESCHEDULER_PARTITION=$bytescheduler_partition BYTESCHEDULER_CREDIT=$bytescheduler_credit DMLC_PS_ROOT_URI=$dmlc_ps_root_uri DMLC_PS_ROOT_PORT=8000 BYTESCHEDULER_CREDIT_TUNING=$bytescheduler_credit_tuning BYTESCHEDULER_PARTITION_TUNING=$bytescheduler_partition_tuning PS_SLICER=0 KVSTORE_MAP_KIND=0 KVSTORE_MAP_MODEL=1 $COMMAND &" &
#ssh cluster@172.31.93.240 "cd /home/cluster/byteps/bytescheduler/examples/mxnet-image-classification;DMLC_ROLE='server' DMLC_NUM_SERVER=$dmlc_num_server DMLC_NUM_WORKER=$dmlc_num_worker USE_BYTESCHEDULER=$use_bytescheduler BYTESCHEDULER_QUEUE_TYPE=$bytescheduler_queue_type BYTESCHEDULER_PARTITION=$bytescheduler_partition BYTESCHEDULER_CREDIT=$bytescheduler_credit DMLC_PS_ROOT_URI=$dmlc_ps_root_uri DMLC_PS_ROOT_PORT=8000 BYTESCHEDULER_CREDIT_TUNING=$bytescheduler_credit_tuning BYTESCHEDULER_PARTITION_TUNING=$bytescheduler_partition_tuning PS_SLICER=0 KVSTORE_MAP_KIND=0 KVSTORE_MAP_MODEL=1 $COMMAND &" &
#ssh cluster@172.31.89.77 "cd /home/cluster/byteps/bytescheduler/examples/mxnet-image-classification;DMLC_ROLE='server' DMLC_NUM_SERVER=$dmlc_num_server DMLC_NUM_WORKER=$dmlc_num_worker USE_BYTESCHEDULER=$use_bytescheduler BYTESCHEDULER_QUEUE_TYPE=$bytescheduler_queue_type BYTESCHEDULER_PARTITION=$bytescheduler_partition BYTESCHEDULER_CREDIT=$bytescheduler_credit DMLC_PS_ROOT_URI=$dmlc_ps_root_uri DMLC_PS_ROOT_PORT=8000 BYTESCHEDULER_CREDIT_TUNING=$bytescheduler_credit_tuning BYTESCHEDULER_PARTITION_TUNING=$bytescheduler_partition_tuning PS_SLICER=0 KVSTORE_MAP_KIND=0 KVSTORE_MAP_MODEL=1 $COMMAND &" &
#ssh cluster@172.31.89.77 "cd /home/cluster/byteps/bytescheduler/examples/mxnet-image-classification;DMLC_ROLE='server' DMLC_NUM_SERVER=$dmlc_num_server DMLC_NUM_WORKER=$dmlc_num_worker USE_BYTESCHEDULER=$use_bytescheduler BYTESCHEDULER_QUEUE_TYPE=$bytescheduler_queue_type BYTESCHEDULER_PARTITION=$bytescheduler_partition BYTESCHEDULER_CREDIT=$bytescheduler_credit DMLC_PS_ROOT_URI=$dmlc_ps_root_uri DMLC_PS_ROOT_PORT=8000 BYTESCHEDULER_CREDIT_TUNING=$bytescheduler_credit_tuning BYTESCHEDULER_PARTITION_TUNING=$bytescheduler_partition_tuning PS_SLICER=0 KVSTORE_MAP_KIND=0 KVSTORE_MAP_MODEL=1 $COMMAND &" &
#ssh cluster@172.31.89.77 "cd /home/cluster/byteps/bytescheduler/examples/mxnet-image-classification;DMLC_ROLE='server' DMLC_NUM_SERVER=$dmlc_num_server DMLC_NUM_WORKER=$dmlc_num_worker USE_BYTESCHEDULER=$use_bytescheduler BYTESCHEDULER_QUEUE_TYPE=$bytescheduler_queue_type BYTESCHEDULER_PARTITION=$bytescheduler_partition BYTESCHEDULER_CREDIT=$bytescheduler_credit DMLC_PS_ROOT_URI=$dmlc_ps_root_uri DMLC_PS_ROOT_PORT=8000 BYTESCHEDULER_CREDIT_TUNING=$bytescheduler_credit_tuning BYTESCHEDULER_PARTITION_TUNING=$bytescheduler_partition_tuning PS_SLICER=0 KVSTORE_MAP_KIND=0 KVSTORE_MAP_MODEL=1 $COMMAND &" &
#ssh cluster@172.31.89.77 "cd /home/cluster/byteps/bytescheduler/examples/mxnet-image-classification;DMLC_ROLE='server' DMLC_NUM_SERVER=$dmlc_num_server DMLC_NUM_WORKER=$dmlc_num_worker USE_BYTESCHEDULER=$use_bytescheduler BYTESCHEDULER_QUEUE_TYPE=$bytescheduler_queue_type BYTESCHEDULER_PARTITION=$bytescheduler_partition BYTESCHEDULER_CREDIT=$bytescheduler_credit DMLC_PS_ROOT_URI=$dmlc_ps_root_uri DMLC_PS_ROOT_PORT=8000 BYTESCHEDULER_CREDIT_TUNING=$bytescheduler_credit_tuning BYTESCHEDULER_PARTITION_TUNING=$bytescheduler_partition_tuning PS_SLICER=0 KVSTORE_MAP_KIND=0 KVSTORE_MAP_MODEL=1 $COMMAND &" &

# worker
ssh cluster@172.31.21.133 "cd /home/cluster/byteps/examples/mxnet/bert-large/gluon-nlp/scripts/bert;DMLC_ROLE='worker' DMLC_NUM_SERVER=$dmlc_num_server DMLC_NUM_WORKER=$dmlc_num_worker USE_BYTESCHEDULER=$use_bytescheduler BYTESCHEDULER_QUEUE_TYPE=$bytescheduler_queue_type BYTESCHEDULER_PARTITION=$bytescheduler_partition BYTESCHEDULER_CREDIT=$bytescheduler_credit DMLC_PS_ROOT_URI=$dmlc_ps_root_uri DMLC_PS_ROOT_PORT=8000 BYTESCHEDULER_CREDIT_TUNING=$bytescheduler_credit_tuning BYTESCHEDULER_PARTITION_TUNING=$bytescheduler_partition_tuning PS_SLICER=0 KVSTORE_MAP_KIND=0 KVSTORE_MAP_MODEL=1 $COMMAND >/home/cluster/byteps/examples/mxnet/bert-large/worker.txt 2>&1 &" &
ssh cluster@172.31.25.63 "cd /home/cluster/byteps/examples/mxnet/bert-large/gluon-nlp/scripts/bert;DMLC_ROLE='worker' DMLC_NUM_SERVER=$dmlc_num_server DMLC_NUM_WORKER=$dmlc_num_worker USE_BYTESCHEDULER=$use_bytescheduler BYTESCHEDULER_QUEUE_TYPE=$bytescheduler_queue_type BYTESCHEDULER_PARTITION=$bytescheduler_partition BYTESCHEDULER_CREDIT=$bytescheduler_credit DMLC_PS_ROOT_URI=$dmlc_ps_root_uri DMLC_PS_ROOT_PORT=8000 BYTESCHEDULER_CREDIT_TUNING=$bytescheduler_credit_tuning BYTESCHEDULER_PARTITION_TUNING=$bytescheduler_partition_tuning PS_SLICER=0 KVSTORE_MAP_KIND=0 KVSTORE_MAP_MODEL=1 $COMMAND >/home/cluster/byteps/examples/mxnet/bert-large/worker.txt 2>&1 &" &
#ssh cluster@172.31.89.189 "cd /home/cluster/byteps/bytescheduler/examples/mxnet-image-classification;DMLC_ROLE='worker' DMLC_NUM_SERVER=$dmlc_num_server DMLC_NUM_WORKER=$dmlc_num_worker USE_BYTESCHEDULER=$use_bytescheduler BYTESCHEDULER_QUEUE_TYPE=$bytescheduler_queue_type BYTESCHEDULER_PARTITION=$bytescheduler_partition BYTESCHEDULER_CREDIT=$bytescheduler_credit DMLC_PS_ROOT_URI=$dmlc_ps_root_uri DMLC_PS_ROOT_PORT=8000 BYTESCHEDULER_CREDIT_TUNING=$bytescheduler_credit_tuning BYTESCHEDULER_PARTITION_TUNING=$bytescheduler_partition_tuning PS_SLICER=0 KVSTORE_MAP_KIND=0 KVSTORE_MAP_MODEL=1 $COMMAND >test.txt 2>&1 &" &
#ssh cluster@172.31.88.246 "cd /home/cluster/byteps/bytescheduler/examples/mxnet-image-classification;DMLC_ROLE='worker' DMLC_NUM_SERVER=$dmlc_num_server DMLC_NUM_WORKER=$dmlc_num_worker USE_BYTESCHEDULER=$use_bytescheduler BYTESCHEDULER_QUEUE_TYPE=$bytescheduler_queue_type BYTESCHEDULER_PARTITION=$bytescheduler_partition BYTESCHEDULER_CREDIT=$bytescheduler_credit DMLC_PS_ROOT_URI=$dmlc_ps_root_uri DMLC_PS_ROOT_PORT=8000 BYTESCHEDULER_CREDIT_TUNING=$bytescheduler_credit_tuning BYTESCHEDULER_PARTITION_TUNING=$bytescheduler_partition_tuning PS_SLICER=0 KVSTORE_MAP_KIND=0 KVSTORE_MAP_MODEL=1 $COMMAND >test.txt 2>&1 &" &
#ssh cluster@172.31.94.200 "cd /home/cluster/byteps/bytescheduler/examples/mxnet-image-classification;DMLC_ROLE='worker' DMLC_NUM_SERVER=$dmlc_num_server DMLC_NUM_WORKER=$dmlc_num_worker USE_BYTESCHEDULER=$use_bytescheduler BYTESCHEDULER_QUEUE_TYPE=$bytescheduler_queue_type BYTESCHEDULER_PARTITION=$bytescheduler_partition BYTESCHEDULER_CREDIT=$bytescheduler_credit DMLC_PS_ROOT_URI=$dmlc_ps_root_uri DMLC_PS_ROOT_PORT=8000 BYTESCHEDULER_CREDIT_TUNING=$bytescheduler_credit_tuning BYTESCHEDULER_PARTITION_TUNING=$bytescheduler_partition_tuning PS_SLICER=0 KVSTORE_MAP_KIND=0 KVSTORE_MAP_MODEL=1 $COMMAND >test.txt 2>&1 &" &
#ssh cluster@172.31.89.77 "cd /home/cluster/byteps/bytescheduler/examples/mxnet-image-classification;DMLC_ROLE='worker' DMLC_NUM_SERVER=$dmlc_num_server DMLC_NUM_WORKER=$dmlc_num_worker USE_BYTESCHEDULER=$use_bytescheduler BYTESCHEDULER_QUEUE_TYPE=$bytescheduler_queue_type BYTESCHEDULER_PARTITION=$bytescheduler_partition BYTESCHEDULER_CREDIT=$bytescheduler_credit DMLC_PS_ROOT_URI=$dmlc_ps_root_uri DMLC_PS_ROOT_PORT=8000 BYTESCHEDULER_CREDIT_TUNING=$bytescheduler_credit_tuning BYTESCHEDULER_PARTITION_TUNING=$bytescheduler_partition_tuning PS_SLICER=0 KVSTORE_MAP_KIND=0 KVSTORE_MAP_MODEL=1 $COMMAND >test.txt 2>&1 &" &
#ssh cluster@172.31.89.77 "cd /home/cluster/byteps/bytescheduler/examples/mxnet-image-classification;DMLC_ROLE='worker' DMLC_NUM_SERVER=$dmlc_num_server DMLC_NUM_WORKER=$dmlc_num_worker USE_BYTESCHEDULER=$use_bytescheduler BYTESCHEDULER_QUEUE_TYPE=$bytescheduler_queue_type BYTESCHEDULER_PARTITION=$bytescheduler_partition BYTESCHEDULER_CREDIT=$bytescheduler_credit DMLC_PS_ROOT_URI=$dmlc_ps_root_uri DMLC_PS_ROOT_PORT=8000 BYTESCHEDULER_CREDIT_TUNING=$bytescheduler_credit_tuning BYTESCHEDULER_PARTITION_TUNING=$bytescheduler_partition_tuning PS_SLICER=0 KVSTORE_MAP_KIND=0 KVSTORE_MAP_MODEL=1 $COMMAND >test.txt 2>&1 &" &
#ssh cluster@172.31.89.77 "cd /home/cluster/byteps/bytescheduler/examples/mxnet-image-classification;DMLC_ROLE='worker' DMLC_NUM_SERVER=$dmlc_num_server DMLC_NUM_WORKER=$dmlc_num_worker USE_BYTESCHEDULER=$use_bytescheduler BYTESCHEDULER_QUEUE_TYPE=$bytescheduler_queue_type BYTESCHEDULER_PARTITION=$bytescheduler_partition BYTESCHEDULER_CREDIT=$bytescheduler_credit DMLC_PS_ROOT_URI=$dmlc_ps_root_uri DMLC_PS_ROOT_PORT=8000 BYTESCHEDULER_CREDIT_TUNING=$bytescheduler_credit_tuning BYTESCHEDULER_PARTITION_TUNING=$bytescheduler_partition_tuning PS_SLICER=0 KVSTORE_MAP_KIND=0 KVSTORE_MAP_MODEL=1 $COMMAND >test.txt 2>&1 &" &
#ssh cluster@172.31.89.77 "cd /home/cluster/byteps/bytescheduler/examples/mxnet-image-classification;DMLC_ROLE='worker' DMLC_NUM_SERVER=$dmlc_num_server DMLC_NUM_WORKER=$dmlc_num_worker USE_BYTESCHEDULER=$use_bytescheduler BYTESCHEDULER_QUEUE_TYPE=$bytescheduler_queue_type BYTESCHEDULER_PARTITION=$bytescheduler_partition BYTESCHEDULER_CREDIT=$bytescheduler_credit DMLC_PS_ROOT_URI=$dmlc_ps_root_uri DMLC_PS_ROOT_PORT=8000 BYTESCHEDULER_CREDIT_TUNING=$bytescheduler_credit_tuning BYTESCHEDULER_PARTITION_TUNING=$bytescheduler_partition_tuning PS_SLICER=0 KVSTORE_MAP_KIND=0 KVSTORE_MAP_MODEL=1 $COMMAND >test.txt 2>&1 &" &
