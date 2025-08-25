#!/bin/bash

fruit(){
	Fruits=("apple"" banana"" orange")
	echo "fruits are $Fruits"
	new_fruit+=("grapes")
	echo "now fruits are $Fruits $new_fruit"
}
fruit

