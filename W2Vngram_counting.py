#! /usr/bin/python3
# Done by: Tiba Zaki Abdulhameed , Western Michigan University and Al-Nahrain University
# jun 9,2017
# This code will take  2 argument 
# first argument indicates number of classes  from word2vec where the file name of (word class) pair from word2vec is supposed to be named
# as <corpus>_classes_SKIP_<number of classes>s.sorted.txt
#example Iraqi_train_classes_SKIP_3oos.sorted.txt
# SRILM tool ngram-count and ngram for counting class-based LM
#<s> start of statement
#</s> end of statement
#<unk> word that is not in vocabulary nor classified because vocabulary is the first field of the (word class)file
##################################################################################################################
import itertools
import collections
import sys
if(len(sys.argv)!=3):print('Arguments error ')
else:
	class_word_file=sys.argv[2]+'_classes_BOW_'+sys.argv[1]+'.s.sorted.txt' #input words and their classes#
	print (class_word_file)

	#class_word_file='chunck_class_word.txt'
	with open(class_word_file) as f:
	  d = dict(x.rstrip().split(None, 1) for x in f)# save the file as dictioary with word as key
	words_file='Iraqi_train.txt' #corpus file
	words_file=sys.argv[2]+'.txt'
	print(words_file)
	#words_file='chunk.txt'
	with open(words_file) as f:
		L= list(itertools.chain( line.split() for line in f)) #save the file as list of lines
	L = list(filter(None, L))#delete empty lines
	for a in itertools.islice(L, len(L)): 
		a.insert(0, '<s>') #surround each line with<s> </s>
		a.insert(len(a),'</s>')
	Class_prob_word='CPW.txt' #output file 2 for SRILM ngram-count input
	#Class_prob_word='toyCPW.txt' 	
	target = open(Class_prob_word, 'w')
	
	
	
	L=list(itertools.chain(*L))# convert 2d list to 1d list
	#print(' 1D List corpus')
	#print(L)
	cL=[]#corpus order classes list
	unkclass=str(999)#<unk> unclassified words have class 999
	#create list of classes of same word order
	for a in itertools.islice(L, len(L)):#iterate through corpus	
		found=0	
		for w, c in d.items():#iterate through dictionary of (word class) pair
			if (a == w):#if word has a class i.e. defined in vocabulary
				cL.append(c) #find class of in corpus word
				found=1
		if (found==0):
			cL.append(unkclass)
			unk=1
				
	prob={}
	
	for a in itertools.islice(L, len(L)):
		for w, c in d.items():#iterate through dictionary of (word class) pair
			if (a == w ):
				prob[a]=(L.count(a)/cL.count(c))
				if (c!='<s>' and c!='</s>'):c='CLASS-'+c.zfill(5) #naming  normal classes
				line=c+' '+str(prob[a])+' '+a+'\n'
				target.write(line)#write (class prob word ) that is prob of word in class
			
	if (unk==1):
		line='CLASS-00'+unkclass+' '+'1.0'+' '+'<unk>'+'\n'
		target.write(line)
			
	
	target.close
	
	Class_count='CS.txt'#output file 2 for SRILM ngram input
	#Class_count='toyCS.txt'
	target = open(Class_count, 'w')
	grouped = itertools.groupby(sorted(zip(cL, cL[1:])), lambda x: x[0])
	
	C_count={k: dict(collections.Counter(x[1] for x in g)) for k,g in grouped} #count occurance of pair of classes 'bigram' 

	for class_key, contextlist  in C_count.items():
		if (class_key=='<s>' or class_key=='</s>'):c=class_key#naming different than normal classes
		else:
			c='CLASS-'+class_key.zfill(5)
		c1=cL.count(class_key)
		line=c+' '+str(c1)+'\n'
		target.write(line) # write (class count)
		for n1_key, count in contextlist.items():
			if (n1_key=='<s>' or n1_key=='</s>'):n1=n1_key
			else: n1='CLASS-'+n1_key.zfill(5)#naming issue
			if((not(n1_key=='<s>' and class_key=='</s>') )and(not(class_key=='<s>' and n1_key=='</s>') )):
				line = c+' '+n1+' '+str(count)+'\n'
				target.write(line)#write (class class count)
	
	target.close
	
