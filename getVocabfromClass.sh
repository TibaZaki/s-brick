#!/bin/bash
# input file of word class pairs, that is output of word2vec. extract the first field

File1=$1 # parameter file name
echo $File1
cf=${File1%.txt} #truncate .txt from file name

awk -F ' ' '{print $1}' $File1 > ${cf}_vocab.txt |exit 1
