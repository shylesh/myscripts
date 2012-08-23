#!/bin/bash

mkdir 1 
i=1
j=2

trap "echo ctrl+c pressed" 2
while true
do
	
	mv $i $j
	(( i++ ))
	(( j++ ))
done

		
