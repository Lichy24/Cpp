#!/bin/bash

#Set defaults for check marks.
memoryLeak="FAIL"
compliation="FAIL"
threadRace="FAIL"
sum=7
#Look for an existing makefile.
#Note default "By default, when make looks for the makefile, it tries the following names, in order: GNUmakefile, makefile and Makefile."
#Go to the given path.
if [ -f $1 ]; then 
cd $(dirname $1)
fullfile=$1
make -f "${fullfile##*/}"
fi
if [ -d $1 ]; then 
cd $1
if  [ -e "makefile" ] || [ -e "GNUmakefile" ] || [ -e "Makefile" ]; then
make
fi
fi
#Check for no errors from makefile.
res=$?
if [ $res -eq 0 ]; then
compliation="PASS"
sum=0
#Check for any memory-leaks in given application as '$2' and application arguments from the $3.
valgrind --leak-check=full --error-exitcode=1 ./$2 ${@:3}
#Result of check if non-zero number is given error has occur.
res=$?
if [ $res -eq 0 ]; then memoryLeak="PASS"
else sum=2
fi
#Check for any thread errors
valgrind --tool=helgrind ./$2 ${@:3}
#Result of check if non-zero number is given error has occur.
res=$?
if [ $res -eq 0 ]; then threadRace="PASS"
else sum=$(($sum + 1))
fi
fi
#Print out the results
echo "Compliation   Memory leaks    thread race"
echo "  "$compliation"          "$memoryLeak"           "$threadRace"    "
echo "code summary:"$sum
exit $sum
cd $HOME