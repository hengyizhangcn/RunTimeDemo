#!/bin/bash
#this script is built for modify the podspec version and add a new tag to the project.

#1.fetch the newest commit
#2.modify the podspec
#3.push the modification
#4.add a new tag and push tags

PodspecPath="SCCommonModule.podspec"

#get the newest info
git pull

#get the version string, 
# left part get the match string, like s.version          = '1.0.2.7'
# right part will separate the string by "'", -f2 will get the second part the separated strings, like 1.0.2.7, then the version is got
OriginVersion=`grep -E 's.version.*=' $PodspecPath | cut -d \' -f2`

#awk, line processor
#FS: field separator
#OFS: output field separator
#NF: number of fields. $NF point to the value of the last field 
NewVersion=`echo $OriginVersion | awk 'BEGIN{FS=OFS="."}{$NF+=1;print}'` #print str separated by "." and add 1 to the last field

#`grep -nE`, -n the line number, -e support the regular expression
# the left part separated by "|" will find the line string which match 's.version.*=', like 
# 11:  s.version          = '1.0.2.7'
# and the right part of the command will separated the string by ":", -f1 will get the first part the separated strings, like 11, then the line number is got
LineNumber=`grep -nE 's.version.*=' $PodspecPath | cut -d : -f1`

#-i, modify the file directly
#s, use replace pattern
#g, global scope
sed -i "" "${LineNumber}s/${OriginVersion}/${NewVersion}/g" $PodspecPath #identifical line number

git add .
git commit -m 'update podspec'
git tag -a $NewVersion -m $NewVersion
git push origin --tags