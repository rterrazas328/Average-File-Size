#!/bin/bash

function convertToBytes() {
	local sizeStr
	sizeStr=$1
	sizeStr=`echo ${sizeStr// /}`
	local len
	len=${#sizeStr}
	local suffix
	suffix=${sizeStr:($len-1):$len}
	local num
	num=${sizeStr:0:($len-1)}
	num=${num/.*}
	if [ $suffix == "G" ]; then
		expr $num \* 1073741824
	elif [ $suffix == "M" ]; then
		expr $num \* 1048576
	elif [ $suffix == "K" ]; then
		expr $num \* 1024
	else
		echo $num
	fi
}

function computeAverage() {
	local total
	local numStr
	local bytes
	total=`du -hs "$dir" | cut -f1`
	total=$(convertToBytes $total)
	expr $total / ${#dirlst[@]}
}

function filter() {
	local average=$1 #in bytes

	for a in "${!dirlst[@]}"; do
		local sizeStr
		local size
		local path
		local str
		str="${dirlst[$a]}" #same as array[i]
		path="$dir/$str"
		sizeStr=`du -hs "$path" | cut -f1`
		size=$(convertToBytes $sizeStr)

		if [ $size -gt $average ]; then
			printf "%s(%d bytes)\n" $str $size
		fi
		done
}

function main() {
average=$(computeAverage)
echo "Average file size for chosen directory: "$average" (bytes)"
echo "Printing files above the average file size"
filter $average

echo "end..."
}

echo "starting..."
dir="$1"
if [ ! -z "$dir" ]; then
	IFS=$'\t\n'
	dirlst=(`ls "$dir"`)
	unset $IFS
	main
else
	echo "Error: Please pass a directory path as an argument to this script"
fi

