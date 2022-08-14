#!/bin/bash
# BRGOLI005 and PRKRAZ006 automated test script

# If the program failed in progress, there will still be backup files so we can retrieve this backups to restore the program
cd C 
mv src/CHeterodyning_threaded_backup.c src/CHeterodyning_threaded.c
mv src/CHeterodyning_backup.c src/CHeterodyning.c
mv src/globals_backup.h src/globals.h
mv makefile_backup makefile
cd ..
# Number of times to run each program
# We run the script a number of times to account for cache warmup and runtime variance
r=0

# Debug mode
debug=0

# Accuracy mode
acc=0

# This is a list of possible optimisation flags
opts=('1' '2' '3' 'fast' 's' 'g' '0')
loops=('' '-funroll-loops')

# This is a list of possible variable types
vars=('float' 'double' '__fp16')

# Clear the results file and write test information
echo "Start of python golden measure tests" > results.txt

# Run the python golden measure
for i in $( seq 0 $r )
do
    echo "Run $i" >> results.txt
    # valgrind --tool=massif --stacks=yes --depth=1 --massif-out-file=massif.out 
    python3 Python/PythonHeterodyning.py >> results.txt
    # peak=$(ms_print massif.out | grep Detailed | grep -Eo "[0-9]+ \(" | grep -Eo "[0-9]+")
    # ms_print massif.out | grep " $peak  " >> results.txt
    ls -l Python | grep "PythonHeterodyning" >> results.txt
done

cd C
#Initialise counter and testcount
count=1
max_count=252
# Make backups of the C files
cp src/CHeterodyning_threaded.c src/CHeterodyning_threaded_backup.c
cp src/CHeterodyning.c src/CHeterodyning_backup.c
cp src/globals.h src/globals_backup.h
cp makefile makefile_backup
# Different variable types
for var in "${vars[@]}"
do
    # Reset the C files
    cp src/CHeterodyning_threaded_backup.c src/CHeterodyning_threaded.c
    cp src/CHeterodyning_backup.c src/CHeterodyning.c
    cp src/globals_backup.h src/globals.h
    # Replace the variable types in the C files
    text=$(<src/CHeterodyning_threaded.c)
    echo "${text//float/"$var"}" > src/CHeterodyning_threaded.c
    text=$(<src/CHeterodyning.c)
    echo "${text//float/"$var"}" > src/CHeterodyning.c
    text=$(<src/globals.h)
    echo "${text//float/"$var"}" > src/globals.h
    # Check if extra compiler flag is needed for fp16
    extra=''
    if [ $var == '__fp16' ]
    then
        extra='-mfp16-format=ieee'
    fi
    
    # Optimisation parameters for both C programs
    for loopopt in "${loops[@]}"
    do
        for opt in "${opts[@]}"
        do
            # Replace the third line of the makefile with the flags we want
            sed -i "3s/.*/CFLAGS = -lm -lrt -O$opt $loopopt $extra/" makefile
            # Compile and pipe to /dev/null to keep terminal clean
            if [ $debug == 0 ]
            then
                make > /dev/null
            fi
            # This is used to deliminate tests with different parameters
            # The parameters for the test are also written to the file
            echo "-----------------------------------" >> ../results.txt
            echo "Start of unthreaded C tests with options" >> ../results.txt
            cat makefile | grep "CFLAGS =" >> ../results.txt
            echo $var >> ../results.txt
            echo "-----------------------------------" >> ../results.txt
            # Run the unthreaded tests
            
            if [ $debug == 0 ]
            then
                make run > /dev/null
                if [ $acc == 1 ]
                then
                    echo "Accuracy: " >> ../results.txt
                    make check >> ../results.txt
                fi
                for i in $( seq 0 $r )
                do
                    echo "Run $i" >> ../results.txt
                    make run >> ../results.txt
                    # peak=$(ms_print massif.out | grep Detailed | grep -Eo "[0-9]+ \(" | grep -Eo "[0-9]+")
                    # ms_print massif.out | grep " $peak  " >> ../results.txt
                    ls -l bin | grep "CHeterodyning" >> ../results.txt
                done
                
            fi
            
            # Thread counts for threaded C program
            for t in 1 2 4 8 16 32
            do
                echo "Started running test $count out of $max_count"
                # Replace the fifteenth line of the header file with the number of threads we want
                sed -i "15s/.*/#define Thread_Count $t/" src/CHeterodyning_threaded.h
                # Compile and pipe to /dev/null to keep terminal clean
                if [ $debug == 0 ]
                then
                    make threaded > /dev/null
                fi
                # This is used to deliminate tests with different parameters
                # The parameters for the test are also written to the file
                echo "-----------------------------------" >> ../results.txt
                echo "Start of threaded C tests with options" >> ../results.txt
                cat makefile | grep "CFLAGS =" >> ../results.txt
                echo $var >> ../results.txt
                cat src/CHeterodyning_threaded.h | grep "Thread" >> ../results.txt
                echo "-----------------------------------" >> ../results.txt
                # Run the threaded tests
                if [ $debug == 0 ]
                then
                    make run_threaded > /dev/null
                    if [ $acc == 1 ]
                    then
                        echo "Accuracy: " >> ../results.txt
                        make check >> ../results.txt
                    fi
                    for i in $( seq 0 $r )
                    do
                        echo "Run $i" >> ../results.txt
                        make run_threaded >> ../results.txt
                        # peak=$(ms_print massif.out | grep Detailed | grep -Eo "[0-9]+ \(" | grep -Eo "[0-9]+")
                        # ms_print massif.out | grep " $peak  " >> ../results.txt
                        ls -l bin | grep "CHeterodyning" >> ../results.txt
                    done
                    
                fi

                echo "Finished running test $count out of $max_count"
                # Increment counter
                ((count++))
            done
        done
    done
done


# Replace the files with the originals
mv src/CHeterodyning_threaded_backup.c src/CHeterodyning_threaded.c
mv src/CHeterodyning_backup.c src/CHeterodyning.c
mv src/globals_backup.h src/globals.h
mv makefile_backup makefile
 
cd ..
timestamp=$(date +%s)
cp results.txt results/results$timestamp.txt
git add results/results$timestamp.txt
git commit -m "Finished running tests at $timestamp"

sed -i "1s/.*/with open('results\/results$timestamp.txt', 'r') as f:/" convert.py
python3 convert.py
cp results.csv results/results$timestamp.csv
cp results.csv /mnt/c/Users/otrol/OneDrive/EEE3095S/results/results$timestamp.csv
