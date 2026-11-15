#!/bin/sh

# how to run : https://serverfault.com/a/801261

# for cron user :
# you can't do `VISUAL="micro" EDITOR="micro" sudo crontab -e`, nor `export VISUAL="micro"; export EDITOR="micro"; sudo crontab -e` work. you shall drop into `su`, and `VISUAL="micro" EDITOR="micro" crontab -e`
# I use anacron, because I use FreeBSD as a desktop

set -eo pipefail

# dataset format is "dataset;dataset2;dataset3"
if [ -z "$1" ]; then
    echo "no datasets given"
    exit 1
fi
if [ -z "$2" ]; then
    echo "no max number of a dataset given"
    exit 1
fi
if [ "$(id -u)" -ne 0 ]; then
    echo "script shall be run as root"
    exit 1
fi

# https://stackoverflow.com/a/8743103
separate() {
    inp="$1"
    sep="$2"

    at_ifs_old="$IFS"
    IFS="$sep"

    echo "$(echo $inp | cut -f 1 -d " ")"

    IFS="$at_ifs_old"
}
regenerate() {
    datasets="$(zfs list | tail -n +2)"
    datasets_snapshot="$(zfs list -t snapshot | tail -n +2)"
}

dataset_target="$1"
max_dataset=$2

if [ "$max_dataset" -lt 1 ]; then
    echo "invalid max dataset num"
    exit 1
fi

# https://stackoverflow.com/a/2923963, https://stackoverflow.com/a/23142895, https://stackoverflow.com/a/23142984
# not sure why +1 didn't do anything
datasets=""
datasets_snapshot=""

regenerate

# validate first
semicolon_ifs_old="$IFS"
IFS=";"
for x in $dataset_target; do
    found=0
    # https://unix.stackexchange.com/a/314497
    newline_ifs_old="$IFS"
    IFS=$'\n'

    for y in $datasets; do
        dataset_name="$(echo "$y" | cut -f 1 -d " ")"
        if [ "$dataset_name" == "$x" ]; then
            found=1
            break
        fi
    done
    if [ "$found" = 0 ]; then
        echo "dataset '$x' not found?"
        exit 1
    fi

    IFS="$newline_ifs_old"
done
IFS="$semicolon_ifs_old"

# https://stackoverflow.com/a/30274965
newline_ifs_old="$IFS"
# https://stackoverflow.com/a/16831721
IFS=$'\n'
for x in $datasets_snapshot; do
    # https://superuser.com/a/365577
    dataset_name="$(separate "$x" "@")"
    # https://serverfault.com/a/151112
    nanosec="$(date "+%s%N")"
    found_count="0"
    for y in $datasets_snapshot; do
        dataset_name2="$(separate "$y" "@")"
        if [ "$dataset_name2" == "$dataset_name" ]; then
            found_count="$(bc -e "$found_count+1")"
        fi
    done
    # because the check runs earlier than the add process, we actually need to check if greater than or equal
    if [ "$found_count" -ge "$max_dataset" ]; then
        database_and_snapshot="$(separate "$x" "")"
        zfs destroy "$database_and_snapshot"
        regenerate
        echo "deleted snapshot '$database_and_snapshot'"
    fi
done
IFS="$newline_ifs_old"

snap_name_curr="$(date "+%d-%m-%Y")"
nanosec="$(date "+%s%N")"

semicolon_ifs_old="$IFS"
IFS=";"
for x in $dataset_target; do
    zfs snapshot "$x@${nanosec}_$snap_name_curr"
done
IFS="$semicolon_ifs_old"

echo "success"
