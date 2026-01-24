# https://unix.stackexchange.com/a/283875
tmp_file="$(mktemp /tmp/turbostat_mangohud-XXXXXX)"
tmp_file2="$(mktemp /tmp/turbostat_mangohud_raw-XXXXXX)"
echo "File is $tmp_file, $tmp_file2"

sudo turbostat -q -i 0.25 --out "$tmp_file2" --show Bzy_MHz &
pid=$!
trap "kill $pid; echo Terminating process PID $pid" SIGINT

# wtf?
while inotifywait -e modify "$tmp_file2" >/dev/null 2>&1; do
    pcregrep -M "Bzy_MHz(\n\d+)+\n$" "$tmp_file2" > "$tmp_file"
done
