#!/usr/local/bin/zsh

set -eo pipefail

FFMPEG_USE_NVSGL_RUN=1

VOSS_BUFF_PERIOD="16ms" # at 48kHz, this is ~21ms
VOSS_SAMPLE_RATE="48000"

ffmpeg_pid_vid=""
ffmpeg_pid_aud=""
voss_pid=""

# https://tratt.net/laurie/blog/2022/making_a_video_of_a_single_window.html
if [ -z "$1" ]; then
    echo "output directory not specified"
    exit 1
fi
if [ -z "$2" ]; then
    echo "/dev/dsp redirect for virtual_oss not specified"
    exit 1
fi

input="$1"
voss_redirect="$2"

main() {
    # prompt the sudo password first
    sudo printf ""

    #win_info="$(xwininfo)"
    #win_width="$(echo "$win_info" | grep "Width:" | sed "s/Width: //" | xargs)"
    #win_height="$(echo "$win_info" | grep "Height:" | sed "s/Height: //" | xargs)"
    #win_abs_left_x="$(echo "$win_info" | grep "Absolute upper-left X:" | sed "s/Absolute upper-left X: //" | xargs)"
    #win_abs_left_y="$(echo "$win_info" | grep "Absolute upper-left Y:" | sed "s/Absolute upper-left Y: //" | xargs)"

    #echo "$win_width, $win_height, $win_abs_left_x, $win_abs_left_y"

    sudo virtual_oss -C 2 -c 2 -r "$VOSS_SAMPLE_RATE" -b 16 -s "$VOSS_BUFF_PERIOD" -P "$voss_redirect" -R "/dev/null" -d "dsp" -l "mixer" &
    voss_pid=$!

    # since we get jittery audio regardless, we separate them. crisis averted?
    vid_tmp="$(mktemp /tmp/oah_vid_XXXXXX)"
    mv "$vid_tmp" "$vid_tmp.mkv"
    vid_tmp="$vid_tmp.mkv"
    aud_tmp="$(mktemp /tmp/oah_aud_XXXXXX)"
    mv "$aud_tmp" "$aud_tmp.mka"
    aud_tmp="$aud_tmp.mka"

    # thanks Claude for the filter, yoink
    #vid_size="${win_width}x${win_height}"
    # https://superuser.com/a/196545
    vid_size="$(xdpyinfo | grep dimensions | sed -r 's/^[^0-9]*([0-9]+x[0-9]+).*$/\1/')"
    win_size="+${win_abs_left_x},${win_abs_left_y}"
    if [[ "$FFMPEG_USE_NVSGL_RUN" ]]; then
        nv-sglrun ffmpeg -y -hide_banner -video_size "$vid_size" -framerate 60 -f "x11grab" -i "$win_size" -c:v "hevc_nvenc" -preset p7 -tune uhq -profile:v main -rc 0 -2pass true -qp 12 -multipass fullres -vf "crop=trunc(iw/2)*2:trunc(ih/2)*2" -pix_fmt "yuv420p" "$vid_tmp" &
    else
        ffmpeg -y -hide_banner -video_size "$vid_size" -framerate 60 -f "x11grab" -i "$win_size" -c:v "libx264" -preset veryfast -profile:v high -qp 18 -vf "crop=trunc(iw/2)*2:trunc(ih/2)*2" -pix_fmt "yuv420p" "$vid_tmp" &
    fi
    ffmpeg_pid_vid=$!
    ffmpeg -y -hide_banner -f "oss" -ac 2 -i "/dev/mixer" -c:a "pcm_s16le" "$aud_tmp" >/dev/null 2>&1 &
    ffmpeg_pid_aud=$!

    #ffmpeg -hide_banner -i $vid_tmp -i $aud_tmp -map 0:v -map 0:a -c copy "$input";
    trap cleanup SIGINT

    while true; do
        sleep 0
    done
}

cleanup() {
    echo "waiting for FFmpeg, and virtual_oss to fully terminate"
    # I got this one from Claude
    wait "$ffmpeg_pid_vid" "$ffmpeg_pid_aud" "$voss_pid" || true
    echo "concatenating final file"
    # TODO: ADD OVERWRITE DETECTION WTF? THIS DELETED MY 70GB RECORDING. THANKS ZFS SNAPSHOTS FOR SAVING MY ASS!
    ffmpeg -y -hide_banner -i "$vid_tmp" -i "$aud_tmp" -map "0:v" -map "1:a" -c "copy" "$input"
    rm "$vid_tmp"
    rm "$aud_tmp"
}

main
