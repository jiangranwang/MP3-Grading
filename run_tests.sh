#!/bin/bash
group=13
group_folder='../g'$group
curr_folder='../tests'
num_run=5 # number of run for isolation tests
local=0
global_limit=5
client2_limit=5
client5_limit=10
client10_limit=15

clients=(a b c d e f g h i j k l m n)
servers=(A B C D E)
vms=('fa21-cs425-g01-01.cs.illinois.edu' 'fa21-cs425-g01-02.cs.illinois.edu' 'fa21-cs425-g01-03.cs.illinois.edu' 'fa21-cs425-g01-04.cs.illinois.edu' 'fa21-cs425-g01-05.cs.illinois.edu')
RED='\033[0;31m'
NC='\033[0m'

final_score=0
rm ../result.txt
touch ../result.txt

if [[ $local -eq 1 ]]; then
	server_pids=()
	cd $group_folder
	for server in ${servers[@]}; do
		./server $server config.txt > ../server_${server}.log 2>&1 &
		server_pids+=($!)
	done
	cd $curr_folder
else
	cp config.txt ${group_folder}/
	for (( i=1; i<5; i++ )); do
		vm=${vms[$i]}
		scp -r ${group_folder}/ jw22@$vm:mp3/
	done
	read -p "Wait for servers..." yn
fi

# Final copy files
cleanup () {
        grade_folder=${group_folder}'-grade/'
        mkdir $grade_folder
	if [[ $local -eq 1 ]]; then
		for pid in ${server_pids[@]}; do
			kill $pid
		done
	else
		cp ${group_folder}/*.log ${grade_folder}/
		for (( i=1; i<5; i++ )); do
			vm=${vms[$i]}
			scp jw22@$vm:mp3/g${group}/server_${servers[$i]}.log ${grade_folder}/
		done
	fi

	echo 'Final Score: '$final_score
	echo 'Final score is: '$final_score >> ../result.txt

	mkdir $grade_folder/atomicity/
	mv ../a*.log $grade_folder/atomicity/
	mkdir $grade_folder/consistency/
	mv ../c*.log $grade_folder/consistency/
	mkdir $grade_folder/isolation/
	mkdir $grade_folder/isolation/test1/
	mv ../i1*.log $grade_folder/isolation/test1/
	mkdir $grade_folder/isolation/test2/
	mv ../i2*.log $grade_folder/isolation/test2/
	mkdir $grade_folder/isolation/test3/
	mv ../i3*.log $grade_folder/isolation/test3/
	mkdir $grade_folder/deadlock/
	mv ../d*.log $grade_folder/deadlock/
	mv ../result.txt $grade_folder
	mv ../*.log $grade_folder
}

trap cleanup exit

# Atomicity Tests (4)
atests () {
	cd ${group_folder}
	score=4

	timeout ${global_limit}s ./client a config.txt < ../tests/atomicity/a$1.txt > ../a$1.log 2>&1
	if [[ $? -eq 124 ]]; then
		echo -e "${RED}Timed out: process did not complete within 5 seconds${NC}"
		echo "Atomicity $1 Test timed out" >> ../result.txt
	fi
	diff ../a$1.log ../tests/atomicity/a$1-expected.txt

	read -p "Atomicity $1 Test Passed? (y/n)" yn
	echo "Atomicity Test $1: " >> ../result.txt
	case $yn in
		[Nn]* ) echo 'Test Failed' >> ../result.txt;;
	    * ) final_score=$(( $final_score+$score )); echo 'Test Passed ('$score' points)' >> ../result.txt;;
	esac
	cd ${curr_folder}
	echo; echo;
}

# Consistency Test 1 (8)
ctest1 () {
	cd ${group_folder}
	score=8

	timeout ${global_limit}s ./client a config.txt < ../tests/consistency/c1.txt > ../c1.log 2>&1
	if [[ $? -eq 124 ]]; then
		echo -e "${RED}Timed out: process did not complete within 5 seconds${NC}"
		echo 'Consistency 1 Test timed out' >> ../result.txt
	fi
	diff ../c1.log ../tests/consistency/c1-expected.txt

	read -p "Consistency 1 Test Passed? (y/n)" yn
	echo 'Consistency Test 1: ' >> ../result.txt
	case $yn in
		[Nn]* ) echo 'Test Failed' >> ../result.txt;;
	    * ) final_score=$(( $final_score+$score )); echo 'Test Passed ('$score' points)' >> ../result.txt;;
	esac
	cd ${curr_folder}
	echo; echo;
}

# Consistency Test 2 (6)
ctest2 () {
	cd ${group_folder}
	score=6

	timeout ${global_limit}s ./client a config.txt < ../tests/consistency/c2.txt > ../c2.log 2>&1
	if [[ $? -eq 124 ]]; then
		echo -e "${RED}Timed out: process did not complete within 5 seconds${NC}"
		echo 'Consistency 2 Test timed out' >> ../result.txt
	fi
	diff ../c2.log ../tests/consistency/c2-expected.txt

	read -p "Consistency 2 Test Passed? (y/n)" yn
	echo 'Consistency Test 2: ' >> ../result.txt
	case $yn in
		[Nn]* ) echo 'Test Failed' >> ../result.txt;;
	    * ) final_score=$(( $final_score+$score )); echo 'Test Passed ('$score' points)' >> ../result.txt;;
	esac
	cd ${curr_folder}
	echo; echo;
}

# Consistency Test 3 (6)
ctest3 () {
	cd ${group_folder}
	score=6

	timeout ${global_limit}s ./client a config.txt < ../tests/consistency/c3.txt > ../c3.log 2>&1
	if [[ $? -eq 124 ]]; then
		echo -e "${RED}Timed out: process did not complete within 5 seconds${NC}"
		echo 'Consistency 3 Test timed out' >> ../result.txt
	fi
	diff ../c3.log ../tests/consistency/c3-expected.txt

	read -p "Consistency 3 Test Passed? (y/n)" yn
	echo 'Consistency Test 3: ' >> ../result.txt
	case $yn in
		[Nn]* ) echo 'Test Failed' >> ../result.txt;;
	    * ) final_score=$(( $final_score+$score )); echo 'Test Passed ('$score' points)' >> ../result.txt;;
	esac
	cd ${curr_folder}
	echo; echo;
}

# Time Limit Test (5)
tlimit () {
	cd ${group_folder}
	score=5
	while true; do
		TIME=($( { time ./client a config.txt < ../tests/isolation/limit/i1.txt > /dev/null; } 2>&1 ))
		echo 'single client takes: '${TIME[1]}

		for (( i=2; i<=11; i++ )); do 
			timeout 10s time ./client ${clients[$i]} config.txt < ../tests/isolation/limit/i$i.txt > /dev/null & 
		done
		sleep 2

	    read -p "Rerun?" yn
	    case $yn in
	        [Yy]* ) echo 'rerunning';;
	        * ) break;;
	    esac
	done

	read -p "Time Limit Test Passed? (y/n)" yn
	echo 'Time Limit Test 1: ' >> ../result.txt
	case $yn in
		[Nn]* ) echo 'Test Failed' >> ../result.txt;;
	    * ) final_score=$(( $final_score+$score )); echo 'Test Passed ('$score' points)' >> ../result.txt;;
	esac
	cd ${curr_folder}
	echo; echo;
}

# Isolation Test 1 (2,3,5)
itest1 () {
	cd ${group_folder}
	if [[ $1 -eq 2 ]]; then
		score=2
		limit=$client2_limit
	elif [[ $1 -eq 5 ]]; then
		score=3
		limit=$client5_limit
	elif [[ $1 -eq 10 ]]; then
		score=5
		limit=$client10_limit
	fi

	for (( i=0; i<$num_run; i++ )); do
		echo 'run num: '$i
		pids=()
		timeout 5s ./client a config.txt < ../tests/isolation/test1/i$1-1-$i.txt > ../i1-$1-$i-00.log 2>&1
		for (( j=0; j<$1; j++ )); do
			timeout ${limit}s ./client ${clients[$j]} config.txt < ../tests/isolation/test1/i$1-2-$i.txt > ../i1-$1-$i-$j.log 2>&1 &
			pids+=($!)
		done
		for pid in ${pids[@]}; do
			wait $pid
			if [[ $? -eq 124 ]]; then
				echo -e "${RED}Timed out: process did not complete within $limit seconds${NC}"
				echo 'Isolation 1 Test timed out' >> ../result.txt
			fi
		done
		timeout 5s ./client a config.txt < ../tests/isolation/test1/i$1-3-$i.txt > ../i1-$1-$i.log 2>&1
		diff ../i1-$1-$i.log ../tests/isolation/test1/i$1-3-expected-$i.txt
		echo
	done

	read -p "Isolation 1 $1-client Test Number of Runs Passed (out of "$num_run")? " n
	echo 'Isolation Test 1 with '$1' clients: ' >> ../result.txt
	curr_score=$( bc <<< 'scale=2; '$n'/'$num_run'*'$score )
	echo $n'/'$num_run' Runs Passed ('$curr_score/$score'.00 points)' >> ../result.txt
	echo 'score is: '$curr_score/$score'.00'
	final_score=$( bc <<< 'scale=2; '$final_score'+'$curr_score )
	cd ${curr_folder}
	echo; echo;
}

# Isolation Test 2 (2,3,5)
itest2 () {
	cd ${group_folder}
	if [[ $1 -eq 2 ]]; then
		score=2
		limit=$client2_limit
	elif [[ $1 -eq 5 ]]; then
		score=3
		limit=$client5_limit
	elif [[ $1 -eq 10 ]]; then
		score=5
		limit=$client10_limit
	fi

	for (( i=0; i<$num_run; i++ )); do
		echo 'run num: '$i
		pids=()
		timeout 5s ./client a config.txt < ../tests/isolation/test2/i$1-4-$i.txt > ../i2-$1-$i-00.log 2>&1
		for (( j=0; j<$1; j++ )); do
			timeout ${limit}s ./client ${clients[$j]} config.txt < ../tests/isolation/test2/i$1-5-$i.txt > ../i2-$1-$i-$j.log 2>&1 &
			pids+=($!)
		done
		for pid in ${pids[@]}; do
			wait $pid
			if [[ $? -eq 124 ]]; then
				echo -e "${RED}Timed out: process did not complete within $limit seconds${NC}"
				echo 'Isolation 2 Test timed out' >> ../result.txt
			fi
		done
		python3 ../tests/isolation/test2/check.py $j ../i2-$1-$i
		timeout 5s ./client a config.txt < ../tests/isolation/test2/i$1-6-$i.txt > ../i2-$1-$i.log 2>&1
		diff ../i2-$1-$i.log ../tests/isolation/test2/i$1-6-expected-$i.txt
		echo
	done

	read -p "Isolation 2 $1-client Test Number of Runs Passed (out of "$num_run")? " n
	echo 'Isolation Test 2 with '$1' clients: ' >> ../result.txt
	curr_score=$( bc <<< 'scale=2; '$n'/'$num_run'*'$score )
	echo $n'/'$num_run' Runs Passed ('$curr_score/$score'.00 points)' >> ../result.txt
	echo 'score is: '$curr_score/$score'.00'
	final_score=$( bc <<< 'scale=2; '$final_score'+'$curr_score )
	cd ${curr_folder}
	echo; echo;
}

# Isolation Test 3 (2,3,5)
itest3 () {
	cd ${group_folder}
	if [[ $1 -eq 2 ]]; then
		score=2
		abort=1
		write=1
		read=0
		limit=$client2_limit
	elif [[ $1 -eq 5 ]]; then
		score=3
		abort=2
		write=2
		read=1
		limit=$client5_limit
	elif [[ $1 -eq 10 ]]; then
		score=5
		abort=4
		write=4
		read=2
		limit=$client10_limit
	fi
	
	for (( i=0; i<$num_run; i++ )); do
		echo 'run num: '$i
		pids=()
		for (( j=0; j<$abort; j++ )); do
			timeout ${limit}s ./client ${clients[$j]} config.txt < ../tests/isolation/test3/i$1-7-$i.txt > ../i3-$1-$i-$j.log 2>&1 &
			pids+=($!)
		done
		for (( j=$abort; j<$write+$abort; j++ )); do
			timeout ${limit}s ./client ${clients[$j]} config.txt < ../tests/isolation/test3/i$1-8-$i.txt > ../i3-$1-$i-$j.log 2>&1 &
			pids+=($!)
		done
		for (( j=$write+$abort; j<$read+$write+$abort; j++ )); do
			timeout ${limit}s ./client ${clients[$j]} config.txt < ../tests/isolation/test3/i$1-9-$i.txt > ../i3-$1-$i-$j.log 2>&1 &
			pids+=($!)
		done
		for pid in ${pids[@]}; do
			wait $pid
			if [[ $? -eq 124 ]]; then
				echo -e "${RED}Timed out: process did not complete within $limit seconds${NC}"
				echo 'Isolation 3 Test timed out' >> ../result.txt
			fi
		done
		python3 ../tests/isolation/test3/check.py $read ../i3-$1-$i
		timeout 5s ./client a config.txt < ../tests/isolation/test3/i$1-10-$i.txt > ../i3-$1-$i.log 2>&1
		diff ../i3-$1-$i.log ../tests/isolation/test3/i$1-10-expected-$i.txt
		echo
	done

	read -p "Isolation 3 $1-client Test Number of Runs Passed (out of "$num_run")? " n
	echo 'Isolation Test 3 with '$1' clients: ' >> ../result.txt
	curr_score=$( bc <<< 'scale=2; '$n'/'$num_run'*'$score )
	echo $n'/'$num_run' Runs Passed ('$curr_score/$score'.00 points)' >> ../result.txt
	echo 'score is: '$curr_score/$score'.00'
	final_score=$( bc <<< 'scale=2; '$final_score'+'$curr_score )
	cd ${curr_folder}
	echo; echo;
}

# Deadlock Test (2,3,5)
dtest () {
	cd ${group_folder}
	if [[ $1 -eq 2 ]]; then
		score=2
		limit=$client2_limit
	elif [[ $1 -eq 5 ]]; then
		score=3
		limit=$client5_limit
	elif [[ $1 -eq 10 ]]; then
		score=5
		limit=$client10_limit
	fi

	for (( i=0; i<$num_run; i++ )); do
		echo 'run num: '$i
		pids=()
		for (( j=0; j<$1; j++ )); do
			timeout ${limit}s ./client ${clients[$j]} config.txt < ../tests/deadlock/d$1-$j-$i.txt > ../d$1-$j-$i.log 2>&1 &
			pids+=($!)
		done
		for pid in ${pids[@]}; do
			wait $pid
			if [[ $? -eq 124 ]]; then
				echo -e "${RED}Timed out: process did not complete within $limit seconds${NC}"
				echo 'Deadlock Test timed out' >> ../result.txt
			fi
		done
		echo
	done

	read -p "Deadlock $1-client Test Number of Runs Passed (out of "$num_run")? " n
	echo 'Deadlock Test with '$1' clients: ' >> ../result.txt
	curr_score=$( bc <<< 'scale=2; '$n'/'$num_run'*'$score )
	echo $n'/'$num_run' Runs Passed ('$curr_score/$score'.00 points)' >> ../result.txt
	echo 'score is: '$curr_score/$score'.00'
	final_score=$( bc <<< 'scale=2; '$final_score'+'$curr_score )
	cd ${curr_folder}
	echo; echo;
}


# Atomicity Tests
atests 1
atests 2
atests 3
atests 4
atests 5

# Consistency Tests
ctest1
ctest2
ctest3

# Isolation Tests
itest1 2
itest1 5
itest1 10
itest2 2
itest2 5
itest2 10
itest3 2
itest3 5
itest3 10
tlimit

# Deadlock Tests
dtest 2
dtest 5
dtest 10

