#!/bin/bash

#Name:Jinwon Lee; Student ID: 261048866; Email: jinwon.lee@mail.mcgill.ca; Department: Computer Science

if [[ $# != 1 ]] #It checks if there is only one argument
then
	echo "Usage ./wparser.bash <weatherdatadir>"
	exit 1
elif [[ ! -d $1 ]] #It checks if the given argument is a directory
then
	echo "Error! $1 is not a valid directory name"
	exit 1
fi


function extractData
{
echo "Processing Data From $1"
echo "===================================="
echo "Year,Month,Day,Hour,TempS1,TempS2,TempS3,TempS4,TempS5,WindS1,WindS2,WindS3,WindDir"
# pattern0 will change the YYYY-MM-DD format into YYYY,MM,DD format and change all the occurance of ":" into whitespace(" ").
# Also, it will get rid of [data log flushed] and change "MISSED SYNC STEP" and "NOINF" into "missed".
# After replacing all the patterns, awk command will grep all the lines where "observation" appears and print
# the data in the order of Year,Month,Day,Hour,TempS1,TempS2,TempS3,TempS4,TempS5,WindS1,WindS2,WindS3,WindDir.
pattern0=$(sed -e 's/-/,/' -e 's/-/,/' -e 's/:/ /g' -e 's/data log flushed//g' -e 's/[[]]//g' -e 's/MISSED SYNC STEP/missed/g' -e 's/NOINF/missed/g' $1 | awk '/observation/ { print $1, $2, $7, $8, $9, $10, $11, $12, $13, $14, $15}') 
# pattern1 will create two arrays. prevdata will store the data that appears in the previous line.
# It will go through the array named data using for loop. In this forloop, if data array's output is "missed" 
# then replace the data[i] with prevdata[i]. 
#After going through the for loop. it will replace the prevdata array with the data array.
pattern1=$(echo "$pattern0" | awk 'BEGIN {
prevdata["TempS1"]=0;  
prevdata["TempS2"]=0; 
prevdata["TempS3"]=0; 
prevdata["TempS4"]=0; 
prevdata["TempS5"]=0; 
prevdata["WindS1"]=0; 
prevdata["WindS2"]=0;
prevdata["WindS3"]=0; 
prevdata["WindDir"]=0;
} /,/ { data["TempS1"]=$3; 
data["TempS2"]=$4; 
data["TempS3"]=$5;
data["TempS4"]=$6;
data["TempS5"]=$7; 
data["WindS1"]=$8;
data["WindS2"]=$9;
data["WindS3"]=$10;
data["WindDir"]=$11;
for (i=3; i<12; i++){
	if (i == 3 && data["TempS1"] == "missed")
		{data["TempS1"]=prevdata["TempS1"]}
	if (i == 4 && data["TempS2"] == "missed")
		{data["TempS2"]=prevdata["TempS2"]}
	if (i == 5 && data["TempS3"] == "missed")
		{data["TempS3"]=prevdata["TempS3"]}
	if (i == 6 && data["TempS4"] == "missed")
		{data["TempS4"]=prevdata["TempS4"]}
	if (i == 7 && data["TempS5"] == "missed")
		{data["TempS5"]=prevdata["TempS5"]}
	if (i == 8 && data["WindS1"] == "missed")
		{data["WindS1"]=prevdata["WindS1"]}
	if (i == 9 && data["WindS2"] == "missed")
		{data["WindS2"]=prevdata["WindS2"]}
	if (i == 10 && data["WindS3"] == "missed")
		{data["WindS3"]=prevdata["WindS3"]}
	if (i == 11 && data["WindDir"] == "missed")
		{data["WindDir"]=prevdata["WindDir"]}
	if (i == 11) 
		{print $1, $2, data["TempS1"], data["TempS2"], data["TempS3"], data["TempS4"], data["TempS5"], data["WindS1"], data["WindS2"], data["WindS3"], data["WindDir"]} };
prevdata["TempS1"]=data["TempS1"]; 
prevdata["TempS2"]=data["TempS2"]; 
prevdata["TempS3"]=data["TempS3"]; 
prevdata["TempS4"]=data["TempS4"]; 
prevdata["TempS5"]=data["TempS5"]; 
prevdata["WindS1"]=data["WindS1"]; 
prevdata["WindS2"]=data["WindS2"]; 
prevdata["WindS3"]=data["WindS3"];
prevdata["WindDir"]=data["WindDir"];
} ')

# pattern2 replaces all the whitespace with ",".
pattern2=$(echo "$pattern1" | sed -e 's/ /,/g')
#It checks the WindDir and replace it with N,NE,E,SE,S,SW,W,NW depending on its value.
pattern3=$(echo "$pattern2"| awk ' BEGIN {FS=","} /,/ {
{ if ($13 == 0) 
	{print $1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, "N"} 
else if ($13 == 1)
       	{print $1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, "NE"} 
else if ($13 == 2) 
	{print $1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, "E"} 
else if ($13 == 3) 
	{print $1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, "SE"} 
else if ($13 == 4) 
	{print $1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, "S"} 
else if ($13 == 5) 
	{print $1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, "SW"} 
else if ($13 == 6) 
	{print $1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, "W"} 
else if ($13 == 7) 
	{print $1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, "NW"}}}' | sed -e 's/ /,/g')
echo "$pattern3"
echo "===================================="
echo "Observation summary"
echo "Year,Month,Day,Hour,MaxTemp,MinTemp,MaxWS,MinWS"
#It uses pattern0 and checks for the MaxTemp, MinTemp, MaxWS, MinWS
echo "$pattern0" | sed -e 's/ /,/g' | awk 'BEGIN {FS=","; MaxTemp=-111; MinTemp=111; MaxWS=-10; MinWS=210;} /,/ { 
for (i=5; i<13; i++) {
	if ( $i == "missed" ) {continue}
	if ( $i > MaxTemp && i < 10 ) { MaxTemp=$i }
	if ( $i < MinTemp && i < 10 ) { MinTemp=$i }
	if ( $i > MaxWS && i > 9 ) { MaxWS=$i }
	if ( $i < MinWS && i > 9 ) { MinWS=$i }};
print $1, $2, $3, $4, MaxTemp, MinTemp, MaxWS, MinWS; MaxTemp=-111; MinTemp=111; MaxWS=-10; MinWS=210;}'| sed -e 's/ /,/g'
echo "===================================="
echo ""

}
#It finds all the files that has the same pattern as 'weather_info_*.data'.
#Then it calles extractData function on the each file.
for i in $(find $1 -name 'weather_info_*.data')
do
	extractData $i
done
#It creates sensorstats.html file in the current directory and writes the header and 
# Year,Month,Day,Hour,TempS1,TempS2,TempS3,TempS4,TempS5,WindS1,WindS2,WindS3,WindDir.
echo "<HTML><BODY><H2>Sensor error statistics</H2><TABLE> <TR><TH>Year</TH><TH>Month</TH><TH>Day</TH><TH>TempS1</TH><TH>TempS2</TH><TH>TempS3</TH><TH>TempS4</TH><TH>TempS5</TH><TH>Total</TH></TR>" > sensorstats.html

#It goes through every file that has the same patternas 'weather_info_*.data'.
#Then, it counts how many errors were there in TempS1, TempS2, TempS3, TempS4, TempS5.
#It also counts how many errors there were in total.
#Then, it will sort the informations and appends in sensorstats.html.
for i in $(find $1 -name 'weather_info_*.data')
do

sed -e 's/-/,/' -e 's/-/,/' -e 's/:/ /g' -e 's/data log flushed//g' -e 's/[[]]//g' -e 's/MISSED SYNC STEP/missed/g' -e 's/NOINF/missed/g' $i | awk '/observation/ { print $1, $2, $7, $8, $9, $10, $11, $12, $13, $14, $15 }' | sed -e 's/ /,/g' | awk 'BEGIN {FS=","; TempS1=0; TempS2=0; TempS3=0; TempS4=0; TempS5=0; Total=0;} /,/ {
for (i=1;i<10;i++) {
if (i == 5 && $i == "missed") {TempS1++}
if (i == 6 && $i == "missed") {TempS2++}
if (i == 7 && $i == "missed") {TempS3++}
if (i == 8 && $i == "missed") {TempS4++}
if (i == 9 && $i == "missed") {TempS5++}
}} END { Total=TempS1+TempS2+TempS3+TempS4+TempS5; print "<TR><TH>", $1,"</TH><TH>", $2,"</TH><TH>", $3,"</TH><TH>", TempS1,"</TH><TH>", TempS2,"</TH><TH>", TempS3,"</TH><TH>", TempS4,"</TH><TH>", TempS5,"</TH><TH>", Total, "</TH></TR>" }'

done | sort -n -k18nr,18 -k2,2 -k4,4 -k6,6 >> sensorstats.html 
#It sorts sensorstats.html file. It first sorts by Total number of errors. Then Year,Month,Day respectively.

#adds the proper syntax
echo "</TABLE></BODY></HTML>" >> sensorstats.html





