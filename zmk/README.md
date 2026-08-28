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
1 NUM    numbers + symbols        hold SW19 (outer left thumb)
2 NAV    arrows, F-keys, media    hold SW20 (middle left thumb)
3 TEST   RGB + reset              hold both left thumbs, or latch with T3
```

**BASE**

```
TAB    Q  W  E  R  T      Y  U  I  O  P  BSPC
CTRL   A  S  D  F  G      H  J  K  L  ;  '
SHIFT  Z  X  C  V  B      N  M  ,  .  /  ESC
          SPC  BSPC  --   RET  NAV  ALT
```

The left thumb cluster is SW19/SW20/SW21 outer-to-inner. The encoder sits on
**SW21** and this build has no encoder push switch, so that position is `&none`
and only two thumb switches exist.

Both are hold-taps, which is what makes every layer reachable from the left half
on its own:

| | tap | hold |
|---|---|---|
| SW19 | space | NUM |
| SW20 | backspace | NAV |
| both | — | TEST |

`GUI` moved to NUM's bottom-left pinky, since the thumbs no longer have room.

**NUM**

```
`    1  2  3  4  5      6  7  8  9  0  BSPC
     !  @  #  $  %      ^  &  *  (  )  |
GUI  -  =  [  ]  \      _  +  {  }  ~  DEL
```

**NAV**

```
ESC  F1   F2   F3  F4  F5      F6    F7   F8    F9    F10   DEL
     F11  F12                  ←     ↓    ↑     →     HOME  END
T3                             PREV  P/P  NEXT  PGUP  PGDN
```

`&lt` is tap-preferred with a 200 ms term: the layer only engages once you've
held past that, so a fast press gives you the tap. A long-held space types no
space and enters NUM instead — swap SW19 to `&kp SPACE` if that bites, at the
cost of NUM (and therefore TEST) being unreachable from this half.

Encoder: volume on every layer.

## Testing keys

Open **Karabiner-EventViewer** (already installed via `../karabiner`) and press
every key. It logs modifiers and layer keys too, which a text editor won't show
— `SHIFT`, `CTRL`, `GUI` and the thumb layer keys produce no character.

A missing event is a dead switch, socket, or matrix trace. A whole row or column
dropping out points at the matrix pin, not the switches.

## Testing RGB

Hold **both left thumbs** for TEST. To latch it instead of holding, hold SW20
(NAV) and tap the bottom-left pinky — `T3` — which leaves TEST on until you tap
the same key again.

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
