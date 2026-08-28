# Aurora Corne rev1.1 — ZMK config

splitkb Aurora Corne rev1.1 on nice!nano v2 (bootloader reports
`nRF52840-nicenano-v2`), 21 per-key SK6812MINI-E LEDs per half, EC11 encoder on
each half.

## Setup

```sh
./setup.sh          # one time: west, Zephyr 3.5, Zephyr SDK 0.16.8 (arm only)
./build.sh left
./build.sh right
./flash.sh left     # double-tap reset when prompted
```

The workspace (ZMK + Zephyr sources, SDK, build output) lives in
`~/zmk-workspace`; only this directory is tracked in git. The keymap and `.conf`
reach the build via `-DZMK_CONFIG`, so edits here are picked up directly.

If `flash.sh` gives `Permission denied`, grant your terminal **Removable
Volumes** in System Settings → Privacy & Security → Files and Folders.

## Layers

```
0 BASE   QWERTY, LEDs off
1 NUM    symbols left, numpad right   hold inner left thumb (space)   blue
2 NAV    F-keys, arrows, media        hold middle left thumb (bspc)   green
3 TEST   RGB + reset                  hold both, or latch with T3
```

**BASE**

```
DEL    Q  W  E  R  T      Y  U  I  O  P    \
NAV    A  S  D  F  G      H  J  K  L  ;*   '*
SHIFT  Z* X  C  V  B      N  M  ,  .  /*   CMD
          --  BSPC  SPC   RET  TAB  --
```

`*` marks the dual-role keys carried over from the Moonlander: `;` is NAV on
hold, `'` is GUI, `Z` is Ctrl, `/` is Ctrl. `DEL` above `NAV` above `SHIFT` on
the left pinky mirrors that layout's outer column.

**NUM** — left-hand symbols, right-hand numpad, as on the Moonlander

```
ESC  -  +  {  }  !      ↑  7  8  9  *  F12
     *  =  (  )  &      ↓  4  5  6  +  `
GUI  #  $  [  ]  |      0  1  2  3  \  ~
```

**NAV** — F-keys, arrows, media, and the `Ctrl+digit` grid

```
SPTL  F1      F2      F3      F4      F5       F6    F7   F8    F9    F10   F11
      Ctrl+1  Ctrl+2  Ctrl+3  Ctrl+4  Ctrl+5   ←     ↓    ↑     →     HOME  END
T3    Ctrl+6  Ctrl+7  Ctrl+8  Ctrl+9  ALT      PREV  P/P  NEXT  PGUP  PGDN  F12
```

`SPTL` is `Gui+Space`. The `Ctrl+1..9` grid reads left-to-right rather than as a
numpad — three rows of five don't divide into a 3×3.

Encoders: left is volume, right is scroll. Both work on every layer.

The outermost thumb on each half is the encoder position and has no switch, so
there are two thumb keys per side. `&lt` is tap-preferred with a 200 ms term: the
layer engages only once you've held past that, and a long-held space types
nothing and shifts to NUM instead.

## Lighting

Base is dark. Each layer key is a macro that turns the strip on, sets its colour,
and turns it off on release — `RGB_OFF` drops the LED power rail too, so the
base layer costs no current. Both halves follow, because `&rgb_ug` is a
global-locality behaviour that relays to the peripheral.

Three consequences worth knowing:

- **TEST has no colour of its own.** Holding both thumbs fires both macros; the
  last press wins, and releasing either one cuts the strip while the other is
  still held. Press `ON` or a colour key on TEST to light it.
- **Colours set on TEST don't stick.** The next layer release turns the strip off.
- Toggling the strip writes the underglow state to settings, debounced at 60 s
  (`CONFIG_ZMK_SETTINGS_SAVE_DEBOUNCE`), so heavy layer use costs at most one
  flash write a minute, not one per keypress.

## Testing keys

Open **Karabiner-EventViewer** and press every key. It logs modifiers and layer
keys, which a text editor won't show.

## Testing RGB

Hold both left thumbs for TEST, or hold the middle thumb and tap `T3` to latch.

```
TOG   RED   GRN   BLU   WHT   EFF        BOOT  RESET  BTCLR  USB  BLE  -
EP    HUE+  SAT+  BRI+  SPD+  ON         -     -      -      -    -    -
T3    HUE-  SAT-  BRI-  SPD-  OFF        -     -      -      -    -    -
```

1. **RED / GRN / BLU / WHT** — each drives a single channel of every LED, so a
   die with a dead green channel shows as an off-colour pixel on the green
   screen. This is the test that finds real faults.
2. **EFF** cycles solid → breathe → spectrum → swirl.
3. **EP** toggles the LED power rail.

### What this cannot test

ZMK addresses the strip as a whole. `rgb_underglow.c` has four effects, all
writing every pixel in a loop, and subscribes to no key events — so there is no
per-key or reactive lighting, and no heatmap. That is a QMK RGB Matrix feature
with no ZMK equivalent; it would need a custom module plus an extension to ZMK's
split protocol, which syncs only hue/sat/brightness/effect and never per-pixel
frames.

The chain is serial: a broken LED kills everything downstream, so the first dark
LED is the suspect and the ones after it are innocent. `chain-length` is 21; the
ZMK shield ships a placeholder of 10.

## Notes

- OLED is off. Uncomment `CONFIG_ZMK_DISPLAY=y` in the `.conf` if one is populated.
- The left half is the split central and enumerates over USB on its own.
