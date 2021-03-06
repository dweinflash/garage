# java methods assumed to have the following bracket format:
# public method(arg1)
# {
# }

# find java files, redirect error output if none found
JAVA_FILES=$(ls *.java 2>/dev/null)

# exit if no java files found
if [[ $JAVA_FILES == "" ]]
then
	echo "No java files found in current directory."
	exit 1
fi

echo "Java files available for commenting: "
echo $JAVA_FILES
read FILE 

# No file name
if [[ $FILE == "" ]]
then
	exit 1
fi

# More than one file
NUM_FILES=$(echo $FILE | wc -w)

if [ $NUM_FILES -gt 1 ]; then
	echo "Can only handle one file."
	exit 1
fi

# Search for exact match of file name
FOUND=$(ls *.java | grep -x $FILE)

# File not found
if [[ $FOUND == "" ]]
then
	echo "File not found."
	exit 1
fi

# Header
echo -n "Class: "
read CLASS

echo -n "Section: "
read SECTION

echo -n "Assignment: "
read ASSIGNMENT

MONTH=$(date -d "$D" '+%m')
YEAR=$(date -d "$D" '+%Y')

if [ $MONTH -lt 6 ];then
	SEMESTER="Spring"
elif [ $MONTH -lt 8 ];then
	SEMESTER="Summer"
else
	SEMESTER="Fall"
fi

sed -i "1i/*" $FILE
sed -i "2i* David Weinflash" $FILE
sed -i "3i* Class: $CLASS, $SEMESTER $YEAR" $FILE
sed -i "4i* Section: $SECTION" $FILE
sed -i "5i*" $FILE
sed -i "6i* Assignment: $ASSIGNMENT" $FILE

echo -n "Description (first line): "
read DESCRIPTION

MORE=1
LINE=7

# read DESCRIPTION line by line
while [ $MORE == 1 ]
do
	sed -i "${LINE}i* ${DESCRIPTION}" $FILE
	((LINE++))
	echo -n "Description (q to Quit): "
	read DESCRIPTION
	
	if [[ $DESCRIPTION == q ]]
	then
		MORE=0
	fi
done
 
sed -i "${LINE}i*/" $FILE
((LINE++))
sed -i "${LINE}s/^/\n/" $FILE

BRACKETS=$(cat $FILE | grep -n "{" | cut -f 1 -d ":")

# loop through function headers in file
for i in ${BRACKETS[@]}
do
	# display line before {
	line=$i
	line=$((line-1))
	echo "${line}p" | ed -s "$FILE"

	# ask if method comment appropriate
	echo -n "Comment? (y/n) "
	read COMMENT

	# comment method
	if [[ $COMMENT == y ]]
	then
		line=$((line+2))
		sed -i "${line}i/*" $FILE
		((line++))
		echo -n "Description (first line): "
		read DESCRIPTION
	
		# method description, line by line
		MORE=1	
		while [ $MORE == 1 ]
		do
			sed -i "${line}i* ${DESCRIPTION}" $FILE
			((line++))
			echo -n "Description (q to Quit): "
			read DESCRIPTION
	
			if [[ $DESCRIPTION == q ]]
			then
				MORE=0
			fi
		done

		# end comment
		sed -i "${line}i*/" $FILE
		((line++))
		sed -i "${line}s/^/\n/" $FILE					
	fi
done	
