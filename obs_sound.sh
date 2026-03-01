#!/usr/local/bin/zsh

set -eo pipefail

voss_pid=""
voss_sr=""

if [ -z "$1" ]; then
    echo "/dev/dsp redirect for virtual_oss not specified"
    exit 1
fi

if [ -z "$2" ]; then
    echo "sample rate not set, defaulting to 44100kHz"
    voss_sr="44100"
else
    voss_sr="$2"
fi

voss_redirect="$1"

main() {
    echo "How to use: Add Audio Input Capture (OSS), set DSP to Custom, then specify /dev/mixer!"
    # prompt the sudo password first
    sudo printf ""

    sudo virtual_oss -Q 2 -C 2 -c 2 -r 48000 -b 16 -s 1024 -P "$voss_redirect" -R "/dev/null" -w vdsp.wav -d "dsp" -l "mixer" &
    voss_pid=$!
    trap cleanup SIGINT

    while true; do
        sleep 0
    done
}

cleanup() {
    # I got this one from Claude
    wait "$voss_pid" || true
    echo "Make sure to terminate OBS first, and do NOT force-terminate this script. If not, $voss_redirect will be hogged by OBS, and virtual_oss can't terminate! Use lsof $voss_redirect to see them processes that is using the device"
}

main
