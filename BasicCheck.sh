#!/bin/bash

#Set defaults for check marks.
memoryLeak="FAIL"
compliation="FAIL"
threadRace="FAIL"
currentlocation=pwd
sum=7
#Go to the given path.
#check if path contains file
if [ -f $1 ]; then 
cd $(dirname $1)
fullfile=$1
#Assumes file is makefile
make -f "${fullfile##*/}"
res=$?
fi
#path is a directory
if [ -d $1 ]; then 
cd $1
#Look for an existing default makefile in directory.
#Note default "By default, when make looks for the makefile, it tries the following names, in order: GNUmakefile, makefile and Makefile."
if  [ -e "makefile" ] || [ -e "GNUmakefile" ] || [ -e "Makefile" ]; then
make
res=$?
fi
fi
#Check for no errors from makefile.
#Note non-zero number is an error
if [ $res -eq 0 ]; then
compliation="PASS"
sum=0
#Check for any memory-leaks in given application as '$2' and application arguments starts from the $3.
valgrind --leak-check=full --error-exitcode=1 ./$2 ${@:3}
#Check for no errors from valgrind.
#Note non-zero number is an error
res=$?
if [ $res -eq 0 ]; then memoryLeak="PASS"
else sum=2
fi
#Check for any thread error in given application as '$2' and application arguments starts from the $3.
valgrind --tool=helgrind ./$2 ${@:3}.
#Check for no errors from helgrind.
#Note non-zero number is an error
res=$?
if [ $res -eq 0 ]; then threadRace="PASS"
else sum=$(($sum + 1))
fi
fi
#Print out the results
echo -e "Compliation \t\t Memory leaks \t\t thread race\n  ${compliation} \t\t\t  ${memoryLeak} \t\t\t  ${threadRace}\nCode summary:  ${sum}"
#Return status code
exit $sum
cd $currentlocation