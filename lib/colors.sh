#!/bin/bash
# intero — Catppuccin Mocha + iTerm "valentine" pastel palette

# ── Truecolor helpers ────────────────────────────────────────────────────────
fg()  { printf "\033[38;2;%d;%d;%dm" "$1" "$2" "$3"; }
bg()  { printf "\033[48;2;%d;%d;%dm" "$1" "$2" "$3"; }
rst() { printf "\033[0m"; }
bld() { printf "\033[1m"; }
dim() { printf "\033[2m"; }
blk() { printf "\033[5m"; }

# ── Catppuccin Mocha accents ─────────────────────────────────────────────────
c_rosewater() { fg 245 224 220; }  # #f5e0dc
c_flamingo()  { fg 242 205 205; }  # #f2cdcd
c_pink()      { fg 245 194 231; }  # #f5c2e7
c_mauve()     { fg 203 166 247; }  # #cba6f7
c_red()       { fg 243 139 168; }  # #f38ba8
c_maroon()    { fg 235 160 172; }  # #eba0ac
c_peach()     { fg 250 179 135; }  # #fab387
c_yellow()    { fg 249 226 175; }  # #f9e2af
c_green()     { fg 166 227 161; }  # #a6e3a1
c_teal()      { fg 148 226 213; }  # #94e2d5
c_sky()       { fg 137 220 235; }  # #89dceb
c_sapphire()  { fg 116 199 236; }  # #74c7ec
c_blue()      { fg 137 180 250; }  # #89b4fa
c_lavender()  { fg 180 190 254; }  # #b4befe

# ── Catppuccin Mocha surfaces & text ─────────────────────────────────────────
c_surface0()  { fg 49 50 68; }     # #313244
c_surface1()  { fg 69 71 90; }     # #45475a
c_overlay0()  { fg 108 112 134; }  # #6c7086
c_overlay1()  { fg 127 132 156; }  # #7f849c
c_subtext0()  { fg 166 173 200; }  # #a6adc8
c_subtext1()  { fg 186 194 222; }  # #bac2de
c_text()      { fg 205 214 244; }  # #cdd6f4

# ── iTerm "valentine" overrides (where they add value) ───────────────────────
c_mint()      { fg 186 255 201; }  # #baffc9 — iTerm green
c_amber()     { fg 255 208 128; }  # #ffd080 — iTerm yellow
c_periwinkle(){ fg 147 175 255; }  # #93afff — iTerm accent
c_coral()     { fg 255 150 141; }  # #ff968d — iTerm bright red

# ── Semantic color aliases (used by widgets) ─────────────────────────────────
clr_model()    { c_mauve; }
clr_thinking() { c_pink; }
clr_branch()   { c_peach; }
clr_sync_ok()  { c_green; }
clr_sync_bad() { c_red; bld; }
clr_ctx()      { c_sky; }
clr_add()      { c_green; }
clr_del()      { c_red; }
clr_burn_low() { c_rosewater; }
clr_burn_mid() { c_yellow; }
clr_burn_hi()  { c_red; }
clr_cache()    { c_teal; }
clr_duration() { c_lavender; }
clr_rate5h()   { c_sapphire; }
clr_rate7d()   { c_flamingo; }
clr_sep()      { c_overlay0; }
clr_dim()      { c_subtext0; }
clr_mcp_ok()   { c_green; }
clr_mcp_bad()  { c_red; }
clr_pr()       { c_periwinkle; }
clr_peak()     { c_yellow; }
clr_stash()    { c_overlay1; }
clr_op()       { c_mauve; }

# ── Separator ────────────────────────────────────────────────────────────────
sep() { clr_sep; printf " │ "; rst; }
dot() { clr_sep; printf " · "; rst; }
