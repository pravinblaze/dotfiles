#!/usr/bin/env bash
set -euo pipefail

TD_MODE=false
LAUNCH_CODEX=true

while [ "$#" -gt 0 ]; do
  case "$1" in
    -td)
      TD_MODE=true
      shift
      ;;
    -nc)
      LAUNCH_CODEX=false
      shift
      ;;
    --)
      shift
      break
      ;;
    *)
      break
      ;;
  esac
done

PATH_ARG="${1:-.}"
WINDOW_NAME_DEFAULT="$(basename "$(realpath "$PATH_ARG")")"

case "${TIDE_WINDOW_NAME:-}" in
  "")
    WINDOW_NAME="$WINDOW_NAME_DEFAULT"
    ;;
  none)
    WINDOW_NAME=""
    ;;
  *)
    WINDOW_NAME="$TIDE_WINDOW_NAME"
    ;;
esac

USE_WINDOW_NAME=true
if [ -z "$WINDOW_NAME" ]; then
  USE_WINDOW_NAME=false
fi

# Capture the width of the client we're launching from so pane math stays stable.
if [ -n "${TMUX-}" ]; then
  WW="$(tmux display-message -p "#{window_width}")"
else
  WW="$(tput cols 2>/dev/null || printf '80')"
fi

WH=0
if $TD_MODE; then
  if [ -n "${TMUX-}" ]; then
    WH="$(tmux display-message -p "#{window_height}")"
  else
    WH="$(tput lines 2>/dev/null || printf '24')"
  fi
fi

MAIN=$(( WW * 70 / 100 ))
if [ "$MAIN" -lt 1 ]; then
  MAIN=1
fi

SESSION_ID=""
if [ -n "${TMUX-}" ]; then
  # Already inside tmux → create a new window and build layout
  if $USE_WINDOW_NAME; then
    WIN_ID="$(tmux new-window -P -F "#{window_id}" -n "$WINDOW_NAME" -c "$PATH_ARG")"
  else
    WIN_ID="$(tmux new-window -P -F "#{window_id}" -c "$PATH_ARG")"
  fi
else
  # Outside tmux → create a fresh session detached, grab its identifiers, build layout, THEN attach
  if $USE_WINDOW_NAME; then
    SESSION_INFO="$(tmux new-session -d -P -F "#{session_id} #{window_id}" -c "$PATH_ARG" -n "$WINDOW_NAME")"
  else
    SESSION_INFO="$(tmux new-session -d -P -F "#{session_id} #{window_id}" -c "$PATH_ARG")"
  fi
  SESSION_ID="${SESSION_INFO%% *}"
  WIN_ID="${SESSION_INFO##* }"
fi

# --- Build layout on the targeted window ---
# Split: left editor, right stack (top: codex unless -nc, bottom: shell; -td adds a .todo.txt pane at the bottom)
tmux split-window  -h -t "$WIN_ID" -c "$PATH_ARG"                 # creates right pane (index 1)
tmux split-window  -v -t "$WIN_ID".1 -c "$PATH_ARG"               # split the right pane into 1 (top) & 2 (bottom)
if $TD_MODE; then
  tmux split-window  -v -t "$WIN_ID".2 -c "$PATH_ARG"             # additional bottom pane (index 3) for .todo.txt
fi

# Make left the main pane and size it ~70%
tmux select-pane   -t "$WIN_ID".0
tmux select-layout -t "$WIN_ID" main-vertical
tmux resize-pane   -t "$WIN_ID".0 -x "$MAIN"
if $TD_MODE; then
  TOP=$(( WH * 40 / 100 ))
  MID=$(( WH * 40 / 100 ))
  if [ "$TOP" -lt 1 ]; then
    TOP=1
  fi
  if [ "$MID" -lt 1 ]; then
    MID=1
  fi
  BOTTOM=$(( WH - TOP - MID ))
  while [ "$BOTTOM" -lt 1 ]; do
    if [ "$MID" -gt 1 ]; then
      MID=$(( MID - 1 ))
    elif [ "$TOP" -gt 1 ]; then
      TOP=$(( TOP - 1 ))
    else
      break
    fi
    BOTTOM=$(( WH - TOP - MID ))
  done
  if [ "$BOTTOM" -lt 1 ]; then
    BOTTOM=1
  fi
  tmux resize-pane -t "$WIN_ID".1 -y "$TOP"
  tmux resize-pane -t "$WIN_ID".2 -y "$MID"
fi

# Launch apps
tmux send-keys     -t "$WIN_ID".0 'nvim' C-m
tmux send-keys     -t "$WIN_ID".0 Space t
if $LAUNCH_CODEX; then
  tmux send-keys   -t "$WIN_ID".1 'codex' C-m 2>/dev/null || true
fi
if $TD_MODE; then
  tmux send-keys   -t "$WIN_ID".3 'nvim .todo.txt' C-m
fi

# Focus the editor by default
tmux select-pane   -t "$WIN_ID".0

# If we started outside tmux, attach *after* setup
if [ -z "${TMUX-}" ]; then
  tmux attach -t "$SESSION_ID"
fi
