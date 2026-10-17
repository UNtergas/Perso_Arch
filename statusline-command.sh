#!/bin/bash
input=$(cat)

# Parse the whole status payload in one pass (no jq on this host).
parsed=$(printf '%s' "$input" | python3 -c '
import sys, json
try: d = json.load(sys.stdin)
except Exception: d = {}
def s(x): return "" if x is None else str(x)
g = lambda o,*k: (o if isinstance(o,dict) else {})
cwd     = (d.get("workspace") or {}).get("current_dir") or d.get("cwd") or ""
model   = (d.get("model") or {}).get("display_name") or ""
effort  = (d.get("effort") or {}).get("level") or ""
cost    = (d.get("cost") or {}).get("total_cost_usd")
added   = (d.get("cost") or {}).get("total_lines_added")
removed = (d.get("cost") or {}).get("total_lines_removed")
ctx     = (d.get("context_window") or {}).get("used_percentage")
five    = ((d.get("rate_limits") or {}).get("five_hour") or {}).get("used_percentage")
seven   = ((d.get("rate_limits") or {}).get("seven_day") or {}).get("used_percentage")
print(cwd); print(model); print(effort)
print("" if cost is None else "%.2f" % cost)
print(s(added)); print(s(removed))
print(s(ctx)); print(s(five)); print(s(seven))
' 2>/dev/null)

{ read -r cwd; read -r model; read -r effort; read -r cost; read -r added; read -r removed; read -r ctx; read -r five; read -r seven; } <<EOF2
$parsed
EOF2

# Fallback if python3 is unavailable.
[ -z "$cwd" ] && cwd=$(printf '%s' "$input" | sed -n 's/.*"current_dir"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p')
[ -z "$cwd" ] && cwd="$PWD"

# af-magic palette (+ extra roles)
DASH="\033[38;5;237m"; PATH_C="\033[38;5;32m"
GIT_PAREN="\033[38;5;75m"; GIT_BRANCH="\033[38;5;78m"; GIT_DIRTY="\033[38;5;214m"
PROMPT_C="\033[38;5;105m"; USER_C="\033[38;5;237m"
MODEL_C="\033[38;5;141m"; EFFORT_C="\033[38;5;180m"; COST_C="\033[38;5;108m"; LABEL_C="\033[38;5;244m"
RESET="\033[0m"

# Color a percentage: <50 green, 50-79 orange, >=80 red.
pct_color() { case 1 in
  $(( $1 >= 80 )) ) printf '\033[38;5;196m';;
  $(( $1 >= 50 )) ) printf '\033[38;5;214m';;
  *) printf '\033[38;5;108m';;
esac; }

# git branch + dirty state (read-only)
git_info=""
if git -C "$cwd" --no-optional-locks rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  branch=$(git -C "$cwd" --no-optional-locks symbolic-ref --short HEAD 2>/dev/null \
        || git -C "$cwd" --no-optional-locks rev-parse --short HEAD 2>/dev/null)
  if [ -n "$branch" ]; then
    dirty=""
    [ -n "$(git -C "$cwd" --no-optional-locks status --porcelain 2>/dev/null)" ] && dirty="${GIT_DIRTY}*"
    git_info=" ${GIT_PAREN}(${GIT_BRANCH}${branch}${dirty}${RESET}${GIT_PAREN})${RESET}"
  fi
fi

# $HOME -> ~ (literal, no re-expansion)
if [ "${cwd#$HOME}" != "$cwd" ]; then display_path="~${cwd#$HOME}"; else display_path="$cwd"; fi

cols=$(tput cols 2>/dev/null || echo 80)
dashes=$(printf '%*s' "$cols" '' | tr ' ' '-')

# Segments (each omitted if its field is empty)
model_seg=""; [ -n "$model" ] && model_seg=" ${MODEL_C}${model}${RESET}"

info_seg=""
[ -n "$effort" ]  && info_seg="${info_seg}  ${LABEL_C}eff:${RESET}${EFFORT_C}${effort}${RESET}"
[ -n "$ctx" ]     && info_seg="${info_seg}  ${LABEL_C}ctx:${RESET}$(pct_color "$ctx")${ctx}%${RESET}"
[ -n "$five" ]    && info_seg="${info_seg}  ${LABEL_C}5h:${RESET}$(pct_color "$five")${five}%${RESET}"
[ -n "$seven" ]   && info_seg="${info_seg}  ${LABEL_C}7d:${RESET}$(pct_color "$seven")${seven}%${RESET}"
[ -n "$cost" ]    && info_seg="${info_seg}  ${COST_C}\$${cost}${RESET}"
[ -n "$added$removed" ] && info_seg="${info_seg} ${COST_C}+${added:-0}/-${removed:-0}${RESET}"

# Line 1: separator. Line 2: path + git. Line 3: prompt + model + effort/usage.
printf "${DASH}%s${RESET}\n${PATH_C}%s${RESET}%b\n${PROMPT_C}»${RESET}%b%b\n" \
  "$dashes" "$display_path" "$git_info" "$model_seg" "$info_seg"
