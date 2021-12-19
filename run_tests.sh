#!/bin/bash
clients=(a b c d e f g h i j k l m n)
group_folder='../g2'
curr_folder='../tests'
final_score=0
cp config.txt ${group_folder}/
touch result.txt

# Atomicity Test 1 (8)
atest1 () {
	cd ${group_folder}
	score=8

	./client a config.txt < ../tests/atomicity/a1.txt > ../a1.log
	sed -i '' -e '$ d' ../a1.log
	diff ../a1.log ../tests/atomicity/a1-expected.txt

	read -p "Atomicity 1 Test Passed? (y/n)" yn
	echo 'Atomicity Test 1: ' >> ../result.txt
	case $yn in
		[Nn]* ) echo 'Test Failed' >> ../result.txt;;
	    * ) final_score=$(( $final_score+$score )); echo 'Test Passed' >> ../result.txt;;
	esac
	cd ${curr_folder}
	echo; echo;
}

# Atomicity Test 2 (8)
atest2 () {
	cd ${group_folder}
	score=8

	./client a config.txt < ../tests/atomicity/a2.txt > ../a2.log
	sed -i '' -e '$ d' ../a2.log
	diff ../a2.log ../tests/atomicity/a2-expected.txt

	read -p "Atomicity 2 Test Passed? (y/n)" yn
	echo 'Atomicity Test 2: ' >> ../result.txt
	case $yn in
		[Nn]* ) echo 'Test Failed' >> ../result.txt;;
	    * ) final_score=$(( $final_score+$score )); echo 'Test Passed' >> ../result.txt;;
	esac
	cd ${curr_folder}
	echo; echo;
}

# Atomicity Test 3 (4)
atest3 () {
	cd ${group_folder}
	score=4

	./client a config.txt < ../tests/atomicity/a3.txt > ../a3.log
	sed -i '' -e '$ d' ../a3.log
	diff ../a3.log ../tests/atomicity/a3-expected.txt

	read -p "Atomicity 3 Test Passed? (y/n)" yn
	echo 'Atomicity Test 3: ' >> ../result.txt
	case $yn in
		[Nn]* ) echo 'Test Failed' >> ../result.txt;;
	    * ) final_score=$(( $final_score+$score )); echo 'Test Passed' >> ../result.txt;;
	esac
	cd ${curr_folder}
	echo; echo;
}

# Consistency Test 1 (8)
ctest1 () {
	cd ${group_folder}
	score=8

	./client a config.txt < ../tests/consistency/c1.txt > ../c1.log
	sed -i '' -e '$ d' ../c1.log
	diff ../c1.log ../tests/consistency/c1-expected.txt

	read -p "Consistency 1 Test Passed? (y/n)" yn
	echo 'Consistency Test 1: ' >> ../result.txt
	case $yn in
		[Nn]* ) echo 'Test Failed' >> ../result.txt;;
	    * ) final_score=$(( $final_score+$score )); echo 'Test Passed' >> ../result.txt;;
	esac
	cd ${curr_folder}
	echo; echo;
}

# Consistency Test 2 (6)
ctest2 () {
	cd ${group_folder}
	score=6

	./client a config.txt < ../tests/consistency/c2.txt > ../c2.log
	sed -i '' -e '$ d' ../c2.log
	diff ../c2.log ../tests/consistency/c2-expected.txt

	read -p "Consistency 2 Test Passed? (y/n)" yn
	echo 'Consistency Test 2: ' >> ../result.txt
	case $yn in
		[Nn]* ) echo 'Test Failed' >> ../result.txt;;
	    * ) final_score=$(( $final_score+$score )); echo 'Test Passed' >> ../result.txt;;
	esac
	cd ${curr_folder}
	echo; echo;
}

# Consistency Test 3 (6)
ctest3 () {
	cd ${group_folder}
	score=6

	./client a config.txt < ../tests/consistency/c3.txt > ../c3.log
	sed -i '' -e '$ d' ../c3.log
	diff ../c3.log ../tests/consistency/c3-expected.txt

	read -p "Consistency 3 Test Passed? (y/n)" yn
	echo 'Consistency Test 3: ' >> ../result.txt
	case $yn in
		[Nn]* ) echo 'Test Failed' >> ../result.txt;;
	    * ) final_score=$(( $final_score+$score )); echo 'Test Passed' >> ../result.txt;;
	esac
	cd ${curr_folder}
	echo; echo;
}

# Time Limit Test (5)
tlimit () {
	cd ${group_folder}
	score=5
	while true; do
		TIME=($( { time ./client a config.txt < ../tests/isolation/i1.txt > /dev/null; } 2>&1 ))
		echo 'single client takes: '${TIME[1]}

		for (( i=2; i<=11; i++ )); do 
			time ./client ${clients[$i]} config.txt < ../tests/isolation/i$i.txt > /dev/null & 
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
	    * ) final_score=$(( $final_score+$score )); echo 'Test Passed' >> ../result.txt;;
	esac
	cd ${curr_folder}
	echo; echo;
}

# Isolation Test 1 (2,3,5)
itest1 () {
	cd ${group_folder}
	if [[ $1 -eq 2 ]]; then
		score=2
	elif [[ $1 -eq 5 ]]; then
		score=3
	elif [[ $1 -eq 10 ]]; then
		score=5
	fi
	num_run=5

	for (( i=0; i<$num_run; i++ )); do
		echo 'run num: '$i
		./client a config.txt < ../tests/isolation/test1/i$1-1-$i.txt > /dev/null
		for (( j=0; j<$1; j++ )); do
			./client ${clients[$j]} config.txt < ../tests/isolation/test1/i$1-2-$i.txt > ../i1-$1-$i-$j.log &
		done
		./client a config.txt < ../tests/isolation/test1/i$1-3-$i.txt > ../i1-$1-$i.log
		sed -i '' -e '$ d' ../i1-$1-$i.log
		diff ../i1-$1-$i.log ../tests/isolation/test1/i$1-3-expected-$i.txt
		echo
	done

	read -p "Isolation 1 Test Number of Runs Passed (out of "$num_run")? " n
	echo 'Isolation Test 1 with '$1' clients: ' >> ../result.txt
	echo $n'/'$num_run' Runs Passed' >> ../result.txt
	curr_score=$( bc <<< 'scale=2; '$n'/'$num_run'*'$score )
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
	elif [[ $1 -eq 5 ]]; then
		score=3
	elif [[ $1 -eq 10 ]]; then
		score=5
	fi
	num_run=5

	for (( i=0; i<$num_run; i++ )); do
		echo 'run num: '$i
		./client a config.txt < ../tests/isolation/test2/i$1-4-$i.txt > /dev/null
		for (( j=0; j<$1; j++ )); do
			./client ${clients[$j]} config.txt < ../tests/isolation/test2/i$1-5-$i.txt > ../i2-$1-$i-$j.log &
		done
		python3 ../tests/isolation/test2/check.py $j ../i2-$1-$i
		./client a config.txt < ../tests/isolation/test2/i$1-6-$i.txt > ../i2-$1-$i.log
		sed -i '' -e '$ d' ../i2-$1-$i.log
		diff ../i2-$1-$i.log ../tests/isolation/test2/i$1-6-expected-$i.txt
		echo
	done

	read -p "Isolation 2 Test Number of Runs Passed (out of "$num_run")? " n
	echo 'Isolation Test 2 with '$1' clients: ' >> ../result.txt
	echo $n'/'$num_run' Runs Passed' >> ../result.txt
	curr_score=$( bc <<< 'scale=2; '$n'/'$num_run'*'$score )
	echo 'score is: '$curr_score/$score'.00'
	final_score=$( bc <<< 'scale=2; '$final_score'+'$curr_score )
	cd ${curr_folder}
	echo; echo;
}

# Atomicity Tests
# atest1
# atest2
# atest3

# # Consistency Tests
# ctest1
# ctest2
# ctest3

# # Isolation Test
# tlimit
# itest1 2
# itest1 5
# itest1 10
# itest2 2
# itest2 5
# itest2 10

# Deadlock Test

echo 'Final Score: '$final_score

# Copy log files
grade_folder=${group_folder}'-grade/'
mkdir $grade_folder
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

