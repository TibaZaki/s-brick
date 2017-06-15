#!/bin/bash
# input file of word class pairs, that is output of word2vec. extract the first field

#File1=$1 # parameter file name
File1=classes.sorted_vocab.txt
File1=Iraqi_train.ATB.tok_classes_BOW_10.s.sorted.txt
echo $File1
cf=${File1%.txt} #truncate .txt from file name

awk -F ' ' '{print $1}' $File1 > ${cf}_vocab.txt |exit 1



# Determine vocabulary:
	#ngram-count -text turkish.train -write-order 1 -write turkish.train.1cnt
	#awk '$2>1'  turkish.train.1cnt | cut -f1 | sort > turkish.train.vocab
	#awk '$2==1' turkish.train.1cnt | cut -f1 | sort > turkish.train.oov



