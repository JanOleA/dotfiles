#!/bin/sh
# Region screenshot to clipboard that looks right on HDR outputs.
#
# grim copies the raw HDR framebuffer (PQ curve, BT.2020 colours) into a normal
# PNG, so it looks washed out. On HDR machines this converts it to sRGB with
# ffmpeg afterwards, without touching the display.
#
# Environment (e.g. in ~/.profile on the HDR machine):
#   HDR_OUTPUTS   non-empty = convert screenshots (names aren't used here)
#   SDR_NITS      brightness Sway shows SDR white at; 203 is the usual default.
#                 Raise it if screenshots look too bright, lower if too dark.
#   HDR_TONEMAP   clip (default, exact for normal desktop content),
#                 mobius or hable (keep detail in bright HDR highlights,
#                 but noticeably dim normal content)
# Requires: grim, slurp, wl-clipboard, ffmpeg (with the zscale filter)

region=$(slurp) || exit 0    # cancelled with Esc

if [ -z "$HDR_OUTPUTS" ]; then
    grim -g "$region" -t png - | wl-copy --type image/png
    exit
fi

nits=${SDR_NITS:-203}
tm=${HDR_TONEMAP:-clip}
tmp=$(mktemp --suffix=.png)
out=$(mktemp --suffix=.png)
trap 'rm -f "$tmp" "$out"' EXIT

grim -g "$region" -t png "$tmp"

# Every colour property is given explicitly for both input and output of each
# step: the PNG from grim carries no colour tags, and zscale refuses to convert
# between "unspecified" colour spaces.
rgb="min=gbr:rin=full:m=gbr:r=full"

# PQ/BT.2020 -> linear light (SDR white = 1.0) -> BT.709 colours -> tone map -> sRGB
ffmpeg -loglevel error -y -i "$tmp" -vf "\
zscale=tin=smpte2084:pin=bt2020:t=linear:p=bt2020:npl=$nits:$rgb,\
format=gbrpf32le,\
zscale=tin=linear:pin=bt2020:t=linear:p=bt709:$rgb,\
tonemap=tonemap=$tm:desat=0,\
zscale=tin=linear:pin=bt709:t=iec61966-2-1:p=bt709:$rgb,\
format=rgb24" "$out" || exit 1

wl-copy --type image/png < "$out"
