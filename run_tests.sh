#!/bin/bash

# Run configs
group_folder='has_deadlock'
num_run=3 # number of run for isolation tests
local=1 # whether run locally
global_limit=5 # global time limit for client execution in seconds
client2_limit=5 # isolation/deadlock test with 2 client time limit in seconds
client5_limit=10 # isolation/deadlock test with 5 client time limit in seconds
run_atomicity=0
run_consistency=0
run_isolation=1
run_deadlock=1

# Define variables
curr_folder=$(pwd)
clients=(a b c d e f g h i j k l m n)
servers=(A B C D E)
vms=('sp22-cs425-g01-01.cs.illinois.edu' 'sp22-cs425-g01-02.cs.illinois.edu' 'sp22-cs425-g01-03.cs.illinois.edu' 'sp22-cs425-g01-04.cs.illinois.edu' 'sp22-cs425-g01-05.cs.illinois.edu')
RED='\033[0;31m'
NC='\033[0m'
final_score=0

rm -rf outputs
mkdir outputs
touch outputs/result.txt

if [[ $local -eq 1 ]]; then
	cp config_local.txt ${group_folder}/config.txt
	server_pids=()
	cd $group_folder
	for server in ${servers[@]}; do
		./server $server config.txt > ../outputs/server_${server}.log 2>&1 &
		server_pids+=($!)
	done
	cd $curr_folder
else
	cp config_remote.txt ${group_folder}/config.txt
	for (( i=0; i<5; i++ )); do
		vm=${vms[$i]}
		scp -r ${group_folder}/ jw22@$vm:mp3/
	done
	read -p "Wait for servers..." yn
fi

# Final copy files
cleanup () {
	cd $curr_folder
    grade_folder='grade-'${group_folder}'/'
    rm -rf $grade_folder
    mkdir $grade_folder
	if [[ $local -eq 1 ]]; then
		for pid in ${server_pids[@]}; do
			kill -9 $pid
		done
	else
		cp ${group_folder}/*.log ${grade_folder}/
		for (( i=0; i<5; i++ )); do
			vm=${vms[$i]}
			scp jw22@$vm:mp3/${group_folder}/server_${servers[$i]}.log ${grade_folder}/
		done
	fi

	echo 'Final Score: '$final_score
	echo 'Final score is: '$final_score >> outputs/result.txt

	mkdir $grade_folder/atomicity/
	mv outputs/a*.log $grade_folder/atomicity/
	mkdir $grade_folder/consistency/
	mv outputs/c*.log $grade_folder/consistency/
	mkdir $grade_folder/isolation/
	mkdir $grade_folder/isolation/test1/
	mv outputs/i1*.log $grade_folder/isolation/test1/
	mkdir $grade_folder/isolation/test2/
	mv outputs/i2*.log $grade_folder/isolation/test2/
	mkdir $grade_folder/isolation/test3/
	mv outputs/i3*.log $grade_folder/isolation/test3/
	mkdir $grade_folder/deadlock/
	mv outputs/d*.log $grade_folder/deadlock/
	mv outputs/result.txt $grade_folder
	mv outputs/*.log $grade_folder
}

trap cleanup EXIT

# Atomicity Tests (3, 3, 4, 5)
atests () {
	cd ${group_folder}
	if [[ $1 -eq 1 ]]; then
		score=3
	elif [[ $1 -eq 2 ]]; then
		score=3
	elif [[ $1 -eq 3 ]]; then
		score=4
	elif [[ $1 -eq 4 ]]; then
		score=5
	fi

	timeout -s SIGKILL ${global_limit}s ./client a config.txt < ../atomicity/a${1}1.txt > ../outputs/a${1}1.log 2>&1
	timeout -s SIGKILL ${global_limit}s ./client a config.txt < ../atomicity/a${1}2.txt > ../outputs/a${1}2.log 2>&1
	timeout -s SIGKILL ${global_limit}s ./client a config.txt < ../atomicity/a${1}3.txt > ../outputs/a${1}3.log 2>&1
	
	diff ../outputs/a${1}1.log ../atomicity/a${1}1-expected.txt
	diff ../outputs/a${1}2.log ../atomicity/a${1}2-expected.txt
	diff ../outputs/a${1}3.log ../atomicity/a${1}3-expected.txt

	read -p "Atomicity $1 Test Passed? (y/n)" yn
	echo "Atomicity Test $1: " >> ../outputs/result.txt
	case $yn in
		[Nn]* ) echo 'Test Failed' >> ../outputs/result.txt;;
	    * ) final_score=$(( $final_score+$score )); echo 'Test Passed ('$score' points)' >> ../outputs/result.txt;;
	esac
	cd ${curr_folder}
	echo; echo;
}

# Consistency Tests (5, 5, 5)
ctests () {
	cd ${group_folder}
	score=5

	timeout -s SIGKILL ${global_limit}s ./client a config.txt < ../consistency/c${1}1.txt > ../outputs/c${1}1.log 2>&1
	timeout -s SIGKILL ${global_limit}s ./client a config.txt < ../consistency/c${1}2.txt > ../outputs/c${1}2.log 2>&1
	timeout -s SIGKILL ${global_limit}s ./client a config.txt < ../consistency/c${1}3.txt > ../outputs/c${1}3.log 2>&1
	
	diff ../outputs/c${1}1.log ../consistency/c${1}1-expected.txt
	diff ../outputs/c${1}2.log ../consistency/c${1}2-expected.txt
	diff ../outputs/c${1}3.log ../consistency/c${1}3-expected.txt

	read -p "Consistency $1 Test Passed? (y/n)" yn
	echo "Consistency Test $1: " >> ../outputs/result.txt
	case $yn in
		[Nn]* ) echo 'Test Failed' >> ../outputs/result.txt;;
	    * ) final_score=$(( $final_score+$score )); echo 'Test Passed ('$score' points)' >> ../outputs/result.txt;;
	esac
	cd ${curr_folder}
	echo; echo;
}

# Isolation Test 1 (3, 4)
itest1 () {
	cd ${group_folder}
	if [[ $1 -eq 2 ]]; then
		score=3
		limit=$client2_limit
	elif [[ $1 -eq 5 ]]; then
		score=4
		limit=$client5_limit
	fi

	for (( i=0; i<$num_run; i++ )); do
		echo 'run num: '$i
		pids=()
		timeout -s SIGKILL ${global_limit}s ./client a config.txt < ../isolation/test1/i$1-1-$i.txt > ../outputs/i1-$1-$i-00.log 2>&1
		for (( j=0; j<$1; j++ )); do
			timeout -s SIGKILL ${limit}s ./client ${clients[$j]} config.txt < ../isolation/test1/i$1-2-$i.txt > ../outputs/i1-$1-$i-$j.log 2>&1 &
			pids+=($!)
		done
		for pid in ${pids[@]}; do
			wait $pid
			if [[ $? -eq 124 ]]; then
				echo -e "${RED}Timed out: process did not complete within $limit seconds${NC}"
				echo "Isolation 1 Test $1-client timed out" >> ../outputs/result.txt
			fi
		done
		timeout -s SIGKILL ${global_limit}s ./client a config.txt < ../isolation/test1/i$1-3-$i.txt > ../outputs/i1-$1-$i.log 2>&1
		python3 ../isolation/test1/check.py $1 ../outputs/i1-$1-$i
		echo
	done

	read -p "Isolation 1 $1 Test Passed? (y/n)" yn
	echo "Isolation Test 1 with $1 clients: " >> ../outputs/result.txt
	case $yn in
		[Nn]* ) echo 'Test Failed' >> ../outputs/result.txt;;
	    * ) final_score=$(( $final_score+$score )); echo 'Test Passed ('$score' points)' >> ../outputs/result.txt;;
	esac
	cd ${curr_folder}
	echo; echo;
}

# Isolation Test 2 (3, 3)
itest2 () {
	cd ${group_folder}
	score=3
	if [[ $1 -eq 2 ]]; then
		limit=$client2_limit
	elif [[ $1 -eq 5 ]]; then
		limit=$client5_limit
	fi

	for (( i=0; i<$num_run; i++ )); do
		echo 'run num: '$i
		pids=()
		timeout -s SIGKILL ${global_limit}s ./client a config.txt < ../isolation/test2/i$1-1-$i.txt > ../outputs/i2-$1-$i-00.log 2>&1
		for (( j=0; j<$1; j++ )); do
			timeout -s SIGKILL ${limit}s ./client ${clients[$j]} config.txt < ../isolation/test2/i$1-2-$i.txt > ../outputs/i2-$1-$i-$j.log 2>&1 &
			pids+=($!)
		done
		for pid in ${pids[@]}; do
			wait $pid
			if [[ $? -eq 124 ]]; then
				echo -e "${RED}Timed out: process did not complete within $limit seconds${NC}"
				echo "Isolation 2 Test $1-client timed out" >> ../outputs/result.txt
			fi
		done
		timeout -s SIGKILL ${global_limit}s ./client a config.txt < ../isolation/test2/i$1-3-$i.txt > ../outputs/i2-$1-$i.log 2>&1
		python3 ../isolation/test2/check.py $1 ../outputs/i2-$1-$i
		echo
	done

	read -p "Isolation 2 $1 Test Passed? (y/n)" yn
	echo "Isolation Test 2 with $1 clients: " >> ../outputs/result.txt
	case $yn in
		[Nn]* ) echo 'Test Failed' >> ../outputs/result.txt;;
	    * ) final_score=$(( $final_score+$score )); echo 'Test Passed ('$score' points)' >> ../outputs/result.txt;;
	esac
	cd ${curr_folder}
	echo; echo;
}

# Isolation Test 3 (3, 3)
itest3 () {
	cd ${group_folder}
	score=3
	if [[ $1 -eq 2 ]]; then
		limit=$client2_limit
	elif [[ $1 -eq 5 ]]; then
		limit=$client5_limit
	fi

	for (( i=0; i<$num_run; i++ )); do
		echo 'run num: '$i
		pids=()
		timeout -s SIGKILL ${global_limit}s ./client a config.txt < ../isolation/test3/i$1-1-$i.txt > ../outputs/i3-$1-$i-00.log 2>&1
		for (( j=0; j<$1; j++ )); do
			timeout -s SIGKILL ${limit}s ./client ${clients[$j]} config.txt < ../isolation/test3/i$1-2-$i.txt > ../outputs/i3-$1-$i-$j.log 2>&1 &
			pids+=($!)
		done
		for pid in ${pids[@]}; do
			wait $pid
			if [[ $? -eq 124 ]]; then
				echo -e "${RED}Timed out: process did not complete within $limit seconds${NC}"
				echo "Isolation 3 Test $1-client timed out" >> ../outputs/result.txt
			fi
		done
		timeout -s SIGKILL ${global_limit}s ./client a config.txt < ../isolation/test3/i$1-3-$i.txt > ../outputs/i3-$1-$i.log 2>&1
		python3 ../isolation/test3/check.py $j ../outputs/i3-$1-$i
		echo
	done

	read -p "Isolation 3 $1 Test Passed? (y/n)" yn
	echo "Isolation Test 3 with $1 clients: " >> ../outputs/result.txt
	case $yn in
		[Nn]* ) echo 'Test Failed' >> ../outputs/result.txt;;
	    * ) final_score=$(( $final_score+$score )); echo 'Test Passed ('$score' points)' >> ../outputs/result.txt;;
	esac
	cd ${curr_folder}
	echo; echo;
}

# Isolation Test 4 (3, 3)
itest4 () {
	cd ${group_folder}
	score=3
	if [[ $1 -eq 2 ]]; then
		limit=$client2_limit
	elif [[ $1 -eq 5 ]]; then
		limit=$client5_limit
	fi
	
	for (( i=0; i<$num_run; i++ )); do
		echo 'run num: '$i
		pids=()
		for (( j=0; j<$1/2; j++ )); do
			timeout -s SIGKILL ${limit}s ./client ${clients[$j]} config.txt < ../isolation/test4/i$1-1-$i.txt > ../outputs/i4-$1-$i-$j.log 2>&1 &
			pids+=($!)
		done
		for (( j=$1/2; j<$1; j++ )); do
			echo 'here'
			timeout -s SIGKILL ${limit}s ./client ${clients[$j]} config.txt < ../isolation/test4/i$1-2-$i.txt > ../outputs/i4-$1-$i-$j.log 2>&1 &
			pids+=($!)
		done
		for pid in ${pids[@]}; do
			wait $pid
			if [[ $? -eq 124 ]]; then
				echo -e "${RED}Timed out: process did not complete within $limit seconds${NC}"
				echo "Isolation 4 $1-client Test timed out" >> ../outputs/result.txt
			fi
		done
		timeout -s SIGKILL ${global_limit}s ./client a config.txt < ../isolation/test4/i$1-3-$i.txt > ../outputs/i4-$1-$i.log 2>&1
		python3 ../isolation/test4/check.py $j ../outputs/i4-$1-$i
		echo
	done

	read -p "Isolation 4 $1 Test Passed? (y/n)" yn
	echo "Isolation Test 4 with $1 clients: " >> ../outputs/result.txt
	case $yn in
		[Nn]* ) echo 'Test Failed' >> ../outputs/result.txt;;
	    * ) final_score=$(( $final_score+$score )); echo 'Test Passed ('$score' points)' >> ../outputs/result.txt;;
	esac
	cd ${curr_folder}
	echo; echo;
}

# Deadlock Test (2, 3)
dtest () {
	cd ${group_folder}
	if [[ $1 -eq 2 ]]; then
		score=2
		limit=$(( client2_limit*2 ))
	elif [[ $1 -eq 5 ]]; then
		score=3
		limit=$(( client5_limit*2 ))
	fi

	for (( i=0; i<$num_run; i++ )); do
		echo 'run num: '$i
		pids=()
		for (( j=0; j<$1; j++ )); do
			timeout -s SIGKILL ${limit}s ./client ${clients[$j]} config.txt < ../deadlock/d$1-$j-$i.txt > ../outputs/d$1-$j-$i.log 2>&1 &
			pids+=($!)
		done
		for pid in ${pids[@]}; do
			wait $pid
			if [[ $? -eq 124 ]]; then
				echo -e "${RED}Timed out: process did not complete within $limit seconds${NC}"
				echo "Deadlock Test $1-client timed out" >> ../outputs/result.txt
			fi
		done
		echo
	done

	read -p "Deadlock $1-client Test Number of Runs Passed (out of "$num_run")? " n
	echo 'Deadlock Test with '$1' clients: ' >> ../outputs/result.txt
	curr_score=$( bc <<< 'scale=2; '$n'/'$num_run'*'$score )
	echo $n'/'$num_run' Runs Passed ('$curr_score/$score'.00 points)' >> ../outputs/result.txt
	echo 'score is: '$curr_score/$score'.00'
	final_score=$( bc <<< 'scale=2; '$final_score'+'$curr_score )
	cd ${curr_folder}
	echo; echo;
}


# Atomicity Tests
if [[ $run_atomicity -eq 1 ]]; then
	atests 1
	atests 2
	atests 3
	atests 4
fi

# Consistency Tests
if [[ $run_consistency -eq 1 ]]; then
	ctests 1
	ctests 2
	ctests 3
fi

# Isolation Tests
if [[ $run_isolation -eq 1 ]]; then
	# itest1 2
	# itest1 5
	# itest2 2
	# itest2 5
	# itest3 2
	# itest3 5
	itest4 2
	itest4 5
fi

# Deadlock Tests
if [[ $run_deadlock -eq 1 ]]; then
	dtest 2
	dtest 5
fi

