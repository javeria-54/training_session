#!/bin/bash

declare -A capitals
capitals=(
    ["Pakistan"]="Islamabad"
    ["India"]="New Delhi"
    ["China"]="Beijing"
    ["Japan"]="Tokyo"
    ["USA"]="Washington D.C."
    ["Turkey"]="Ankara"
    ["Iraq"]="Baghdad"
    ["Iran"]="Tehran"
    ["England"]="London"
    ["Portugal"]="Lisbon"
    ["Spain"]="Madrid"
    ["Germany"]="Berlin"
    ["France"]="Paris"
    ["Malaysia"]="Kuala Lampur"
)

get_capital() {
    read -p "Enter a country name: " country

    if [[ -n "${capitals[$country]}" ]]; then
        echo "The capital of $country is: ${capitals[$country]}"
    else
        echo "Error: Capital for '$country' not found in the list."
    fi
}

get_capital

