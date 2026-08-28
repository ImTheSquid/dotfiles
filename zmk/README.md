# Aurora Corne rev1.1 — ZMK config

splitkb Aurora Corne rev1.1 on nice!nano v2 (or a pin-compatible clone), 21
per-key SK6812MINI-E LEDs per half, EC11 encoder on the left.

## Setup

```sh
./setup.sh          # one time: west, Zephyr 3.5, Zephyr SDK 0.16.8 (arm only)
./build.sh left
./flash.sh left     # double-tap reset when prompted
```

The workspace (ZMK + Zephyr sources, SDK, build output) lives in
`~/zmk-workspace`; only this directory is tracked in git. The keymap and `.conf`
reach the build via `-DZMK_CONFIG`, so edits here are picked up directly.

## Layers

```
0 BASE   QWERTY
1 NUM    numbers + symbols        hold left thumb
2 NAV    arrows, F-keys, media    hold right thumb
3 TEST   RGB + reset              NUM+NAV together, or latch — see below
```

**BASE**

```
TAB    Q  W  E  R  T      Y  U  I  O  P  BSPC
CTRL   A  S  D  F  G      H  J  K  L  ;  '
SHIFT  Z  X  C  V  B      N  M  ,  .  /  ESC
          GUI  SPC  MUTE  RET  NAV  ALT
```

The left thumb cluster is SW19/SW20/SW21 outer-to-inner, and the encoder sits on
**SW21**, so only two switches are there. Space is `&lt 1 SPACE` on SW20 — tapped
it's a space, held it's NUM. SW21 is bound to mute, which is the encoder's push
switch if this revision wires it into the matrix; if it doesn't, the binding is
simply inert.

**NUM**

```
`   1  2  3  4  5      6  7  8  9  0  BSPC
    !  @  #  $  %      ^  &  *  (  )  |
T3  -  =  [  ]  \      _  +  {  }  ~  DEL
```

**NAV**

```
ESC  F1   F2   F3  F4  F5      F6    F7   F8    F9    F10   DEL
     F11  F12                  ←     ↓    ↑     →     HOME  END
T3                             PREV  P/P  NEXT  PGUP  PGDN
```

A long-held space enters NUM. Change SW20 to `&kp SPACE` and move `&mo 1` to
SW19 if that bites — you'd lose GUI on the thumb.

Encoder: volume on BASE, page up/down on NUM, track skip on NAV, screen
brightness on TEST.

## Testing keys

Open **Karabiner-EventViewer** (already installed via `../karabiner`) and press
every key. It logs modifiers and layer keys too, which a text editor won't show
— `SHIFT`, `CTRL`, `GUI` and the thumb layer keys produce no character.

A missing event is a dead switch, socket, or matrix trace. A whole row or column
dropping out points at the matrix pin, not the switches.

## Testing RGB

Reaching the TEST layer with **only the left half connected**: NAV lives on a
right thumb, so the NUM+NAV combination isn't available. Instead hold the left
thumb (NUM) and tap the bottom-left pinky key — `T3` above — which latches TEST
on. The same key on TEST latches it back off.

```
TOG   RED   GRN   BLU   WHT   EFF        BOOT  RESET  BTCLR  USB  BLE  -
EP    HUE+  SAT+  BRI+  SPD+  ON         -     -      -      -    -    -
T3    HUE-  SAT-  BRI-  SPD-  OFF        -     -      -      -    -    -
```

The strip comes up solid red at boot, so a completely dark board means LED 1 or
its data line, not the firmware.

Procedure:

1. **RED / GRN / BLU / WHT** — solid full-saturation colors. Each drives a single
   channel of every LED, so a die with a dead green channel shows as a red or
   magenta pixel on the green screen. This is the test that finds real faults.
2. **EFF** cycles solid → breathe → spectrum → swirl. Swirl spreads a hue ramp
   across the chain, making position-dependent faults obvious.
3. **BRI± / SAT± / HUE±** exercise the PWM range.
4. **EP** toggles the switched VCC rail the LEDs run from. Everything should go
   dark and come back.

### What this cannot test

ZMK's underglow driver addresses the strip as a whole — there is no per-key or
key-reactive lighting in ZMK, so you can't light one LED at a time. The chain is
serial, so a broken LED kills everything downstream: the first dark LED is the
suspect, and the ones after it are innocent.

`chain-length` is set to 21 in `config/splitkb_aurora_corne.keymap`. The ZMK
shield ships a placeholder of 10; if trailing LEDs stay dark, check that first.

## Notes

- OLED is off. Uncomment `CONFIG_ZMK_DISPLAY=y` in the `.conf` if one is populated.
- Only the left half is needed — it's the split central, so it enumerates over
  USB on its own.
