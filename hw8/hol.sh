#!/bin/bash

rm -r submissions
rm -r __MACOSX
rm a.out
rm grades.txt

echo "------------------------------------------"
unzip -q submissions.zip
submissions=`ls submissions`
expected_output=252

for program in $submissions; do
    echo "Processing" $program "..."
    rename=`echo "${program}" | cut -f4 -d'_'` 
    studentname=`echo "${rename}" | cut -f1 -d'-'`
    studentname=`echo "${studentname}" | cut -f1 -d'.'`
    echo "student name is" $studentname
    filename="${studentname}.cpp"
    echo "program is renamed to" $filename
    mv ./submissions/$program ./submissions/$filename
    dos2unix ./submissions/$filename
    g++ ./submissions/$filename
    output=`./a.out 10 5`
    echo "output is" $output

    if [ $output == $expected_output ]
    then
        writeToGrades=`echo $studentname", correct"`
    else
        writeToGrades=`echo $studentname", incorrect"`
    fi
    if grep -q 252 ./submissions/$filename; then
        echo $writeToGrades "HARD-CODED OUTPUT!" >> grades.txt
    else
        echo $writeToGrades >> grades.txt
    fi
    echo $writeToGrades
    echo
done
