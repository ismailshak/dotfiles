#!/usr/bin/env bash

input=$(cat)

# Colors
reset='\033[0m'
blue='\033[34m'
yellow='\033[33m'
red='\033[31m'
dim='\033[2m'
sep='\033[90m | \033[0m'

# Parse JSON
branch_dir=$(jq -r '.workspace.current_dir // ""' <<<"$input")
model=$(jq -r '.model.display_name // ""' <<<"$input")
used_pct=$(jq -r '.context_window.used_percentage // ""' <<<"$input")
total_in=$(jq -r '.context_window.total_input_tokens // 0' <<<"$input")
total_out=$(jq -r '.context_window.total_output_tokens // 0' <<<"$input")
cost_raw=$(jq -r '.cost.total_cost_usd // ""' <<<"$input")

# Git branch
if [ -n "$branch_dir" ]; then
  branch=$(git -C "$branch_dir" --no-optional-locks rev-parse --abbrev-ref HEAD 2>/dev/null)
  [ -n "$branch" ] && branch_part="${blue} ${reset}${dim}${branch}${reset}"
fi

# Model
if [ -n "$model" ]; then
  model_part="${blue}󰅩 ${reset}${dim}${model}${reset}"
fi

# Context window
if [ -n "$used_pct" ]; then
  pct_int=$(printf '%.0f' "$used_pct")

  pies=("󰪞" "󰪟" "󰪠" "󰪡" "󰪢" "󰪣" "󰪤" "󰪥")

  if ((pct_int <= 12)); then
    idx=0
  elif ((pct_int <= 25)); then
    idx=1
  elif ((pct_int <= 37)); then
    idx=2
  elif ((pct_int <= 50)); then
    idx=3
  elif ((pct_int <= 62)); then
    idx=4
  elif ((pct_int <= 75)); then
    idx=5
  elif ((pct_int <= 87)); then
    idx=6
  else
    idx=7
  fi

  if ((pct_int > 87)); then
    pie_color=$red
  elif ((pct_int > 50)); then
    pie_color=$yellow
  else
    pie_color=$blue
  fi

  total_tokens=$((total_in + total_out))
  if ((total_tokens >= 1000)); then
    tokens_fmt=$(awk -v t="$total_tokens" 'BEGIN { printf "%.2fk", t/1000 }')
  else
    tokens_fmt="$total_tokens"
  fi

  tokens_part="${pie_color}${pies[$idx]}${reset}${dim} ${tokens_fmt}${reset}"
fi

# Cost
if [ -n "$cost_raw" ]; then
  cost_part=$(printf "${dim}\$%.4f${reset}" "$cost_raw")
fi

output=""
for part in "$branch_part" "$model_part" "$tokens_part" "$cost_part"; do
  if [ -n "$part" ]; then
    [ -n "$output" ] && output+="$sep"
    output+="$part"
  fi
done

printf "%b\n" "$output"
