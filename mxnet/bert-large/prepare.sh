#!/bin/bash

# Docker Image: zycccc/bsc-mxnet-py3
git clone -b bytescheduler https://github.com/netx-repo/byteps.git
bash byteps/bytescheduler/setup_nodes_mxnet_ps.sh
cd byteps && git clone https://github.com/ZYCCC927/examples.git


# install gluon-nlp under this dir
cd /home/cluster/byteps/examples/mxnet/bert-large/gluon-nlp
python3 setup.py install

# prepare dict 
mkdir -p /home/cluster/.mxnet/models
cd /home/cluster/.mxnet/models 
wget https://apache-mxnet.s3-accelerate.dualstack.amazonaws.com/gluon/dataset/vocab/book_corpus_wiki_en_uncased-a6607397.zip
apt-get install unzip
unzip *.zip

