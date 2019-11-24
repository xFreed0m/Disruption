#!/bin/bash
set -e
INTERNETIP="$(curl icanhazip.com)"
jq -n --arg internetip "$INTERNETIP" '{"internet_ip":$internetip}'
