#!/bin/bash

#Author: Saulo Domingos de Souza Pedro

#A run interface for the SS-Crowd algorithm with Twitter

option=$1		#option for this runner
exp_name=$2		#name of the experiment
question_source=$3	#name of the file with the questions or image paths

root_dir=$(cat conf/sscrowd.conf | grep experiments_dir | cut -f2 -d'=') #path to experiment's directory
logs_dir=$(echo $root_dir/logs)		#path to logs directory
data_dir=$(echo $root_dir/data)		#path to data directory
answer_dir=$(echo $data_dir/answers)	#path to answers directory
img_dir=$(echo $data_dir/img)

#builds a ss-crowd environment
function build(){

	mkdir $root_dir
	mkdir $logs_dir
	mkdir $data_dir
	mkdir $answer_dir
	mkdir $img_dir

	cp $question_source $data_dir/questionsource.raw	#rename questionfile to questionsource.raw

	touch $logs_dir/script.log
	touch $logs_dir/error.log

	scripts/log-sender -m $root_dir "created the experiment $exp_name"
}

#post questions on Twitter
function send(){
	scripts/question-sender $root_dir $data_dir
}

#post images on Twitter
function send_image(){
	scripts/question-img-sender $root_dir $data_dir $img_dir
}

#receive answers from Twitter
function receive(){
	scripts/answer-receiver $root_dir $data_dir
}

#set the time of posting for each question
function schedule(){
	max_qpd=0 
	read -p "experiment to be used as reference: " ref_exp
	if [ $ref_exp != 0 ]; then 
		read -p "max questions per day: " max_qpd
	fi
	scripts/timeframer $data_dir $ref_exp $data_dir/questionsource.raw $max_qpd
}

function reschedule(){

	read -p "answers threshold: " min_answers
	scripts/rescheduler $data_dir $min_answers

	max_qpd=0 
	read -p "experiment to be used as reference: " ref_exp
	if [ $ref_exp != 0 ]; then 
		read -p "max questions per day: " max_qpd
	fi
	scripts/timeframer $data_dir $ref_exp $data_dir/questionsource_resched.raw $max_qpd
}

function list(){
	ls $root_dir
}

#prints the usage of the options
function helpp(){
	echo "SS-Crowd Help"
	echo "Usage:"
	echo "-b: build a new SS-Crowd task"
	echo "-s: start posting questions"
	echo "-i: start posting images"
	echo "-r: start receiving answers"
	echo "-c: schedule questions to be posted"
	echo "-d: reschedule questions with few answers"
	echo "-l: list all experiments"
	echo "-h: show SS-Crowd task"
}

case $option in
	-b)build;;
	-s)send;;
	-i)send_image;;
	-r)receive;;
	-c)schedule;; 				# needs extra parameter (reference experiment)
	-d)reschedule;;
	-l)list;;
	-h)helpp;;
esac
