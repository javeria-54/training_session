#!/bin/bash
filename="log.txt"
lineno=1
while read -r line
    do
        echo "$lineno: $line"
        ((lineno++))
    done < "$filename"

