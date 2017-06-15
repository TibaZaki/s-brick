#!/bin/sh

export word2vec_ROOT=`pwd`/../../../word2vec
 
export PATH=$PATH:$word2vec_ROOT

echo $1
echo $2
echo $3
echo $4 
/$word2vec_ROOT/word2vec -train  $4.txt -output ${4}_classes_BOW_${1}v${2}w${3}.txt  -cbow 1 -size $2 -window $3 -negative 25 -hs 0 -sample 1e-4 -threads 20 -iter 15 -classes $1
sort ${4}_classes_BOW_$1v${2}w${3}.txt -k 2 -n > ${4}_classes_BOW_$1v${2}w${3}.sorted.txt

t=temp1.txt

awk -F' ' '{print $2}' ${4}_classes_BOW_$1v${2}w${3}.sorted.txt|uniq -c > $t # t contains (freq cluster)pairs

 Min_cluster_size=$(awk -F' ' '{print $1}' $t|sort -n |head -1) 
 Max_cluster_size=$(awk -F' ' '{print $1}' $t|sort -n |tail -1)
echo
echo '----------train w2v' ${4}_classes_BOW_$1v${2}w${3}.sorted.txt
echo 'min cluster size '$Min_cluster_size
echo 'max cluster size '$Max_cluster_size
printf "%s" 'avr='
awk -F ' ' '{ sum += $1; n++ } END { if (n > 0) print sum / n; }' $t
echo '---------------------------------------------'
