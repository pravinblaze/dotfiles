#!/usr/bin/env bash
set -euo pipefail

usage() {
  echo "Usage: $0 <column-definition>" >&2
  echo "Example: $0 4224" >&2
  exit 1
}

if [ $# -ne 1 ]; then
  usage
fi

layout="$1"

if [[ ! "$layout" =~ ^[0-9]+$ ]]; then
  echo "Column definition must be a string of digits." >&2
  exit 1
fi

if [[ "$layout" =~ 0 ]]; then
  echo "Columns must be at least one pane; zeros are not allowed." >&2
  exit 1
fi

if ! tmux display-message -p "#{session_name}" >/dev/null 2>&1; then
  echo "This script must be run inside an active tmux session." >&2
  exit 1
fi

window_id="$(tmux new-window -d -P -F "#{window_id}")"

column_count=${#layout}

for ((i = 1; i < column_count; i++)); do
  tmux split-window -h -t "$window_id"
done

tmux select-layout -t "$window_id" even-horizontal

mapfile -t column_panes < <(
  tmux list-panes -t "$window_id" -F "#{pane_index} #{pane_id}" |
    sort -n -k1 |
    awk '{print $2}'
)

for ((i = 0; i < column_count; i++)); do
  pane_count=${layout:i:1}
  pane_id="${column_panes[$i]}"

  if ((pane_count <= 1)); then
    continue
  fi

  remaining=$pane_count
  target="$pane_id"

  while ((remaining > 1)); do
    target="$(tmux split-window -v -t "$target" -P -F "#{pane_id}")"
    ((remaining--))
  done
done

window_height="$(tmux display-message -p -t "$window_id" "#{window_height}")"

if [[ ! "$window_height" =~ ^[0-9]+$ ]]; then
  echo "Unable to determine tmux window height." >&2
  tmux kill-window -t "$window_id"
  exit 1
fi

mapfile -t pane_geometry < <(
  tmux list-panes -t "$window_id" -F "#{pane_id} #{pane_left} #{pane_top}" |
    sort -k2,2n -k3,3n
)

declare -A panes_by_left=()
declare -a column_lefts=()

for entry in "${pane_geometry[@]}"; do
  read -r pane_id pane_left pane_top <<<"$entry"
  if [[ -z "${panes_by_left[$pane_left]+x}" ]]; then
    panes_by_left[$pane_left]="$pane_id"
    column_lefts+=("$pane_left")
  else
    panes_by_left[$pane_left]+=" $pane_id"
  fi
done

if ((${#column_lefts[@]} != column_count)); then
  echo "Warning: expected $column_count columns but found ${#column_lefts[@]}." >&2
fi

for ((i = 0; i < ${#column_lefts[@]}; i++)); do
  pane_left="${column_lefts[$i]}"
  panes_string="${panes_by_left[$pane_left]}"
  read -r -a panes_in_column <<<"$panes_string"
  pane_count=${#panes_in_column[@]}

  if ((i < column_count)); then
    column_expected=${layout:i:1}
  else
    column_expected=0
  fi

  if ((column_expected != pane_count)); then
    echo "Warning: column $((i + 1)) expected $column_expected panes but found $pane_count." >&2
  fi

  if ((pane_count <= 1)); then
    continue
  fi

  content_height=$((window_height - (pane_count - 1)))
  if ((content_height <= 0)); then
    echo "Warning: window too short to evenly split column $((i + 1))." >&2
    continue
  fi

  pane_height=$((content_height / pane_count))
  if ((pane_height == 0)); then
    echo "Warning: window too short to evenly split column $((i + 1))." >&2
    continue
  fi

  remainder=$((content_height - pane_height * pane_count))

  for ((j = 0; j < pane_count - 1; j++)); do
    pane_id="${panes_in_column[$j]}"
    size=$pane_height
    if ((remainder > 0)); then
      ((size++))
      ((remainder--))
    fi
    tmux resize-pane -t "$pane_id" -y "$size"
  done
done

tmux select-window -t "$window_id"
