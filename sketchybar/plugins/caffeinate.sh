#!/bin/sh


# Flag tracking whether we've already flashed for the current active session.
# We tick every second while a timer counts down, so re-launching the flash on
# every run would stack overlapping animations and look erratic. Instead we
# flash once (smoothly) on the transition to active, then just hold steady red.
FLASH_FLAG="/tmp/sketchybar_${NAME}_flashed"

if pgrep caffeinate > /dev/null; then
    DRAW=yes
    if [ ! -f "$FLASH_FLAG" ]; then
        touch "$FLASH_FLAG"
        (
            # Animate the color transitions so the flash fades instead of
            # hard-toggling, which reads much smoother.
            for c in 0xFFFFFFFF 0xFFFF0000 0xFFFFFFFF 0xFFFF0000; do
                sketchybar --animate sin 18 --set "$NAME" icon.color="$c"
                sleep 0.4
            done
            sketchybar --animate sin 18 --set "$NAME" icon.color=0xFFFF0000
        ) &
    else
        # Already flashed this session: keep it steady red (idempotent, no flicker).
        sketchybar --set "$NAME" icon.color=0xFFFF0000
    fi
else
    DRAW=no
    rm -f "$FLASH_FLAG"
fi

# If a caffeinate process was launched with a timeout (-t <seconds>), show the
# time remaining as the label. ps reports elapsed wall-clock time (etime) as
# [[DD-]HH:]MM:SS, so the remaining time is (timeout - elapsed). If several
# timed processes are running, we display the one with the most time left.
REMAINING=$(ps -axo etime=,args= | awk '
    function etime2s(t,   d, n, dd, a, m) {
        d = 0
        n = split(t, dd, "-")
        if (n == 2) { d = dd[1]; t = dd[2] }
        m = split(t, a, ":")
        if (m == 3) return d*86400 + a[1]*3600 + a[2]*60 + a[3]
        else if (m == 2) return d*86400 + a[1]*60 + a[2]
        else return d*86400 + a[1]
    }
    /caffeinate/ && !/awk/ {
        for (i = 2; i < NF; i++) {
            if ($i == "-t") {
                rem = $(i + 1) - etime2s($1)
                if (!found || rem > max) { max = rem; found = 1 }
            }
        }
    }
    END { if (found) print max }
')

if [ -n "$REMAINING" ] && [ "$REMAINING" -gt 0 ]; then
    # A timer is active: show it and tick every second so the countdown is live.
    LABEL=$(printf '%d:%02d' $((REMAINING / 60)) $((REMAINING % 60)))
    sketchybar --set "$NAME" label="$LABEL" label.drawing=on update_freq=1
else
    # No timer: hide the label and fall back to the slow refresh cycle.
    sketchybar --set "$NAME" label.drawing=off update_freq=10
fi

if [[ "$(/Applications/BetterDisplay.app/Contents/MacOS/BetterDisplay get -name=OLED -active)" = "on" ]]; then
    ICON=􂇗
    DRAW=yes
    sketchybar --set "$NAME" icon.color=0xFFFFFFFF
    killall caffeinate > /dev/null
else
    ICON=􂊭
fi

sketchybar --set "$NAME" drawing=$DRAW icon="$ICON"
