
echo   'START RUN'

export IRSTLM=/home/user/kaldi/tools/irstlm
export PATH=${PATH}:${IRSTLM}/bin
export LIBLBFGS=/home/user/kaldi/tools/liblbfgs-1.10
export LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:${LIBLBFGS}/lib/.libs
export SRILM=/home/user/kaldi/tools/srilm
export PATH=${PATH}:${SRILM}/bin:${SRILM}/bin/i686-m64

train=corpus_train.txt
#train=corpus_train.ATB.tok.txt
echo 'train set is '$train
test=devtest.txt
#test=devtest.ATB.tok.txt
echo 'test set is '$test
#--------------------------word based LM -----------------------------------------

#ngram-count -kndiscount -interpolate -order 2 -text  $train -lm bi_corpus.lm

#ngram-count -kndiscount -interpolate -order 3 -text $train -lm tri_corpus.lm
#echo 'bigram '
#ngram -lm bi_corpus.lm -ppl $test
#echo 'trigram'
#ngram -lm tri_corpus.lm -ppl $test
#-------------------------------------------------------------------
#
#--------------------------Class Based LM-----------------------------------------
#classes formats should be class [p] word1 word2 ...
#-classes file
#    Interpret the LM as an N-gram over word classes. The expansions of the classes are given in file in classes-format(5). Tokens in the #LM that are not defined as classes in file are assumed to be plain words, so that the LM can contain mixed N-grams over both words and #word classes.
#    Class definitions may also follow the N-gram definitions in the LM file (the argument to -lm). In that case -classes /dev/null should #be specified to trigger interpretation of the LM as a class-based model. Otherwise, class definitions specified with this option override #any definitions found in the LM file itself. 
#-simple-classes
#    Assume a "simple" class model: each word is member of at most one word class, and class expansions are exactly one word long. 
#-expand-classes k
#    Replace the read class-N-gram model with an (approximately) equivalent word-based N-gram. The argument k limits the length of the N-#grams included in the new model (k=0 allows N-grams of arbitrary length).



#-----------------------------------------------------------------

echo '-------------- Word2vec-------------'
#ngram-class -vocab classes.sorted_vocab.txt \
#            -text $train \
#           -numclasses $n\
#            -class-counts output.class-counts \
#            -classes output.classes

K_Values=(10 150 300 450 500 700) # kmeans values
V=200
W=5
for c in ${K_Values[@]}; do
  ./train_word2vec.sh $c $V $W ${train%.txt} # train should be in same drive 

   cat s.txt ${train%.txt}_classes_BOW_${c}v${V}w${W}.sorted.txt >${train%.txt}_classes_BOW_${c}v${V}w${W}.s.sorted.txt
   ./W2Vngram_counting.py ${c}v${V}w${W} ${train%.txt} 

   sort CS.txt|uniq >output.WV-class_BOW_${c}v${V}w${W}.s-counts
   sort CPW.txt|uniq >output.WV-classes_BOW_${c}v${V}w${W}.s

   ngram-count -order 2 \
           -read  output.WV-class_BOW_${c}v${V}w${W}.s-counts \
            -write outputWV_BOW_${c}v${V}w${W}.s.ngrams

   ngram-count   -order 2  \
            -read outputWV_BOW_${c}v${V}w${W}.s.ngrams \
            -lm  corpus_WV_Class_BOW_${c}v${V}w${W}.s_Based.lm

   ngram -lm corpus_WV_Class_BOW_${c}v${V}w${W}.s_Based.lm -classes output.WV-classes_BOW_${c}v${V}w${W}.s -ppl $test
done

exit 0 #for dubuging
echo '-------------Brown----------------'
#ngram-count -text $train -write-order 1 -write $train.1cnt
#	awk '$2>1'  $train.1cnt | cut -f1 | sort > $train.vocab
#	awk '$2==1' $train.1cnt | cut -f1 | sort > $train.oov

K_Values=(10 150 300 450 500 700 900 950)
for n in ${K_Values[@]}; do
   echo 'Brown, number of classes= ' $n 
   ngram-class -vocab corpus_train_vocab.txt \
            -text $train \
           -numclasses $n\
            -class-counts output.class-counts.$n \
            -classes output.classes.$n

   ngram-count  -order 2 \
            -read  output.class-counts.$n \
            -write output.ngrams.$n

   ngram-count  -order 2  \
            -read output.ngrams.$n \
            -lm  corpus_Brown_Class_Based.$n.lm

   ngram -lm corpus_Brown_Class_Based.$n.lm -classes output.classes.$n -ppl $test

done

