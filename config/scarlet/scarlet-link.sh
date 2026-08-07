#!/bin/sh

link() {
    output=$(pw-link "$1" "$2" 2>&1)
    [ -z "$output" ] || case "$output" in *"File exists"*) ;; *) return 1 ;; esac
}

for _ in $(seq 60); do
    microphone=$(pw-link -o | sed -n 's/^\(alsa_input\.usb-Focusrite[^:]*\):capture_FL$/\1/p' | head -1)
    if [ -n "$microphone" ] &&
        link "$microphone:capture_FL" "Carla:audio-in1" &&
        link "$microphone:capture_FL" "Carla:audio-in2" &&
        link "Carla:audio-out1" "scarlet-input:input_MONO"; then
        amixer -c Gen cset name='Line In 1 Gain Capture Volume' 24 >/dev/null
        exit 0
    fi
    sleep 0.5
done

exit 1
