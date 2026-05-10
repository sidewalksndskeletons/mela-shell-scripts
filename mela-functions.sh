#!/bin/sh

mela-fram() {
  before=$(awk '/MemAvailable/ {print $2}' /proc/meminfo)
  sync >/dev/null 2>&1
  echo 3 | doas tee /proc/sys/vm/drop_caches >/dev/null 2>&1
  echo 1 | doas tee /proc/sys/vm/compact_memory >/dev/null 2>&1
  doas swapoff -a >/dev/null 2>&1 || true
  doas swapon -a >/dev/null 2>&1 || true
  end_time=$(( $(date +%s) + 3 ))
  while [ "$(date +%s)" -lt "$end_time" ]; do
    echo 3 | doas tee /proc/sys/vm/drop_caches >/dev/null 2>&1
    sleep 1
  done
  after=$(awk '/MemAvailable/ {print $2}' /proc/meminfo)
  freed=$((after - before))
  [ "$freed" -le 0 ] && freed=0
  printf "%.2f GiB RAM cleared\n" "$(awk "BEGIN {print $freed/1024/1024}")"
}

mela-extract() {
  for archive in "$@"; do
    if [ -f "$archive" ]; then
      case "$archive" in
        *.tar.bz2)   tar xvjf "$archive" ;;
        *.tar.gz)    tar xvzf "$archive" ;;
        *.bz2)       bunzip2 "$archive" ;;
        *.rar)       rar x "$archive" ;;
        *.gz)        gunzip "$archive" ;;
        *.tar)       tar xvf "$archive" ;;
        *.tbz2)      tar xvjf "$archive" ;;
        *.tgz)       tar xvzf "$archive" ;;
        *.zip)       unzip "$archive" ;;
        *.Z)         uncompress "$archive" ;;
        *.7z)        7z x "$archive" ;;
        *)           echo "don't know how to extract '$archive'..." ;;
      esac
    else
      echo "'$archive' is not a valid file!"
    fi
  done
}

mela-whatsmyip() {
  internal=""
  external=""

  if command -v ip >/dev/null 2>&1; then
    internal=$(ip route get 8.8.8.8 2>/dev/null | awk '/src/ {for(i=1;i<=NF;i++) if($i=="src"){print $(i+1); exit}}')
    [ -z "$internal" ] && internal=$(ip -4 -o addr show scope global 2>/dev/null | awk '{print $4}' | cut -d/ -f1 | head -n1)
  else
    internal=$(hostname -I 2>/dev/null | awk '{print $1}')
    [ -z "$internal" ] && internal=$(ifconfig 2>/dev/null | awk '/inet / && $2!="127.0.0.1" {print $2; exit}')
  fi

  [ -n "$internal" ] && printf "Internal IP: %s\n" "$internal" || printf "Internal IP: (not found)\n"

  if command -v curl >/dev/null 2>&1; then
    external=$(curl -s4 --max-time 5 https://ifconfig.me 2>/dev/null)
    [ -z "$external" ] && external=$(curl -s4 --max-time 5 https://icanhazip.com 2>/dev/null)
    [ -z "$external" ] && external=$(curl -s4 --max-time 5 https://api.ipify.org 2>/dev/null)
  elif command -v wget >/dev/null 2>&1; then
    external=$(wget -qO- --timeout=5 --tries=1 https://ifconfig.me 2>/dev/null)
    [ -z "$external" ] && external=$(wget -qO- --timeout=5 --tries=1 https://icanhazip.com 2>/dev/null)
  fi

  [ -n "$external" ] && printf "External IP: %s\n" "$external" || printf "External IP: (lookup failed)\n"
}

mela-wvram() {
  watch -n1 'awk "{printf \"%.1f MB\n\", \$1/1024/1024}" /sys/class/drm/card*/device/mem_info_vram_used'
}

alias mt='wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle'

mela-vol() {
  wpctl set-volume @DEFAULT_AUDIO_SINK@ "$1%"
  echo "Volume is now $1%"
}

mela-micvol() {
  wpctl set-volume @DEFAULT_AUDIO_SOURCE@ "$1%"
  echo "Microphone volume is now $1%"
}

mela-chsink() {
  VIRTUAL_ID=$(wpctl status | grep "effect_input.virtual-surround" | grep -o '[0-9]*\.' | tr -d '.' | head -1)
  ANALOG_ID=$(wpctl status | grep "712 Analog Stereo" | head -1 | grep -o '[0-9]*\.' | tr -d '.' | head -1)

  CURRENT_STARRED=$(wpctl status | grep -A 15 "Sinks:" | grep '\*')

  if echo "$CURRENT_STARRED" | grep -q "712 Analog"; then
    wpctl set-default "$VIRTUAL_ID"
    echo "Switched to Virtual Surround (HeSuVi)"
  else
    wpctl set-default "$ANALOG_ID"
    echo "Switched to 712 Analog Stereo"
  fi
}
