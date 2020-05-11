#!/bin/bash
#------------------------------config-----------------------------------
model='centermap_obb_r101_fpn_lr001_1x_dota'
epoch=12
dataset='dota'

#------------------------------train-----------------------------------

if [ $1 == 1 ]
then
    # train but not debug
    echo "==== start no debug training ===="
    ./tools/dist_train.sh configs/${dataset}/${model}.py 4
elif [ $1 == 2 ]
then
    # train and debug
    echo "==== start debug training ===="
    export CUDA_VISIBLE_DEVICES=0
    python tools/train.py configs/${dataset}/${model}.py --gpus 1
elif [ $1 == 3 ]
then
    echo "==== start training + validation ===="
    ./tools/dist_train.sh configs/${dataset}/${model}.py 4 --validate
elif [ $1 == 0 ]
then
    # skip training
    echo "==== skip training ===="
fi


#------------------------------inference and eval-----------------------------------
if [ $2 == 1 ]
then
    echo "==== start 4 GPU coco test ===="
    mkdir -p results/${dataset}/${model}

    ./tools/dota/dist_dota_test.sh configs/${dataset}/${model}.py work_dirs/${model}/epoch_${epoch}.pth 4 --out results/${dataset}/${model}/coco_results.pkl --eval hbb obb --options submit_path=$(pwd)/results/dota/${model} annopath=$(pwd)/data/dota/v0/test/labelTxt-v1.0/{:s}.txt imageset_file=$(pwd)/data/dota/v0/test/testset.txt excel=$(pwd)/results/dota/${model}/${model}_results.xlsx jsonfile_prefix=$(pwd)/results/${dataset}/${model}
elif [ $2 == 2 ]
then
    echo "==== start 1 GPU coco test ===="
    export CUDA_VISIBLE_DEVICES=0
    mkdir -p results/${dataset}/${model}

    python tools/dota/dota_test.py configs/${dataset}/${model}.py work_dirs/${model}/epoch_${epoch}.pth --out results/${dataset}/${model}/coco_results.pkl --eval hbb obb --options submit_path=$(pwd)/results/dota/${model} annopath=$(pwd)/data/dota/v0/test/labelTxt-v1.0/{:s}.txt imageset_file=$(pwd)/data/dota/v0/test/testset.txt excel=$(pwd)/results/dota/${model}/${model}_results.xlsx jsonfile_prefix=$(pwd)/results/${dataset}/${model}
elif [ $2 == 0 ]
then
    # read the results file
    echo "==== skip inference ===="
fi

#------------------------------load result file and evaluation-----------------------------------
if [ $3 == 1 ]
then
    echo "==== start loading results files and evaluation ===="

    python tools/dota/dota_eval.py configs/${dataset}/${model}.py --results results/${dataset}/${model}/coco_results.pkl --eval hbb obb --options submit_path=$(pwd)/results/dota/${model} annopath=$(pwd)/data/dota/v0/test/labelTxt-v1.0/{:s}.txt imageset_file=$(pwd)/data/dota/v0/test/testset.txt excel=$(pwd)/results/dota/${model}/${model}_results.xlsx PR_path=$(pwd)/results/${dataset}/${model}/PR jsonfile_prefix=$(pwd)/results/${dataset}/${model}
elif [ $3 == 2 ]
then
    echo "==== skip evaluation ===="
elif [ $3 == 0 ]
then
    # read the results file
    echo "==== skip evaluation ===="
fi

# send the notification email
# cd ../wwtool
# python tools/utils/send_email.py
