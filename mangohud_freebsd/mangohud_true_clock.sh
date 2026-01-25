#!/usr/local/bin/zsh

if (( $(id -u) == 0 )); then
    echo "You shall not run this script as root right away. If you do, the files created by this script will be owned by root as default, causing you to have to elevate to root to delete the files created"
    exit 1
fi

# https://unix.stackexchange.com/a/283875
tmp_file="$(mktemp /tmp/turbostat_mangohud-XXXXXX)"
tmp_file2="$(mktemp /tmp/turbostat_mangohud_raw-XXXXXX)"
echo "File is $tmp_file, $tmp_file2"

sudo turbostat -q -i 0.5 --out "$tmp_file2" --show Bzy_MHz &
pid=$!
trap "kill $pid; rm $tmp_file2; echo Terminating process PID $pid" SIGINT

# wtf?
while inotifywait -e modify "$tmp_file2" >/dev/null 2>&1; do
    pcregrep -M "Bzy_MHz(\n\d+)+\n$" "$tmp_file2" > "$tmp_file"
done
