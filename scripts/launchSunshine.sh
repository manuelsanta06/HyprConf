#!/usr/bin/env bash
set -euo pipefail

if hyprctl monitors -j | grep -Eq '"name"[[:space:]]*:[[:space:]]*"PROYECTOR"'; then
  echo "PROYECTOR already existe and wont be removed."
  creado=false
else
  hyprctl output create headless PROYECTOR
  creado=true
fi

cleanup(){
  if [[ "$creado" == true ]]; then
    hyprctl output remove PROYECTOR || true
  fi
}

trap cleanup EXIT

hyprctl eval 'hl.monitor({
  output = "PROYECTOR",
  mode = "1920x1080@60",
  position = "auto-up",
  scale = 1
})'

sunshine
