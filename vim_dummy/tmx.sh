#!/usr/bin/env bash

help_text=$(cat << EOF
  tmx: Quick access to various tmux commands usually run as "tmux whatever" on
  the command line or on the tmux command line after "<tmux-prefix>:".

  Usage:
    $ tmx [options]

  Environment Variables:
    TMX_GLOBAL_APW, TMX_GLOBAL_APH: The global "active pane width/height" If
      set, selecting any pane that is part of a split will be resized to these
      numbers of rows or columns along whichever axis allows it. Useful in a
      shell rc file.

    TMX_LOCAL_APW, TMX_LOCAL_APH: Per-pane overrides of the TMX_GLOBAL_*
      counterparts. Overrides them with either a size or an "off". Less useful
      in a shell rc and more so with an "export VAR=val" in the current pane.

  Options:
    -b: Show scrollback buffer in the text reader. See -t.
    -c FIRST_WIN-LAST_WIN: Group window numbers in this range into a
      "cycleset", restricting prev/next wrapping to that group.
    -C Clear all cyclesets.
    -g TARGET: Go to pane/window TARGET, honoring cycleset boundaries.
      Pane TARGETs: u=up|d=down|l=left|r=right|j=jump-to-last.
      Window TARGETs: P=previous|N=next|J=jump-to-last.
    -G TARGET: Same as -g but ignoring cycleset boundaries.
    -H: Split current window horizontally and go to new pane. New pane width is
      first of: -z, \$TMX_LOCAL_APW, \$TMX_GLOBAL_APW, tmux default (usu. 50%).
    -k: List tmux keys in the text reader. See -t.
    -r: Reload tmux config.
    -S WIN_NUMS: Comma-sep list of windows to split horizontally (but stay in
      current). If creating simultaneously, use the numbers they *will* have.
    -t PROG: Text reader/editor to use for any text output. Which will be used
      is prioritized as follows: -t, \$TMX_READER, \$EDITOR, "less".
    -T STR: Tack onto end of text reader/editor command. Overrides smart
      scrolling.
    -U: Disable "smart scrolling" to the bottom for "scrollback"-like output. On
      by default when editor supports it (y: vim, emacs, less; n: nano, pico).
    -V: Split current window vertically and go to new pane. New pane height is
      first of: -z, \$TMX_LOCAL_APW, \$TMX_GLOBAL_APW, tmux default (usu. 50%).
    -w: Open a new tmux window and switch to it.
    -W NUM_WINS: Open NUM_WINS tmux windows but stay in current one.
    -z PANE_CREATION_SIZE: With -h/-v/-S, create pane at PANE_CREATION_SIZE rows
      or cols, depending on whether the split is horizontal or vertical.
    -E: Show environment variables used by this script and current cyclesets.
    -h: Show this help text.
EOF
)

MODE=show_help
CYCLESET_FILE="${HOME}/.tmx_cyclesets"
HONOR_CYCLESET=true

if [[ $1 =~ ^- ]]; then
  while getopts "bc:Cg:G:HkrsS:t:T:UVwW:z:Eh" opt; do
    MODE=""
    case "${opt}" in
      b) MODE=show_scrollback;;
      c) MODE=create_cycleset && NEW_CYCLESET=${OPTARG};;
      C) MODE=clear_cyclesets;;
      g) MODE=nav && NAV_TARGET=${OPTARG};;
      G) MODE=nav && NAV_TARGET=${OPTARG} && HONOR_CYCLESET=false;;
      H) MODE=split && SPLIT_TYPE=h;;
      k) MODE=list_keys;;
      r) MODE=reload_tmux;;
      S) MODE=manage_windows && SPLIT_WINDOWS=${OPTARG};;
      t) READER=${OPTARG};;
      T) SMARTSCROLL=false && READER_EXTRA=${OPTARG};;
      U) SMARTSCROLL=false;;
      w) MODE=manage_windows && NEW_WINDOWS=single;;
      W) MODE=manage_windows && NEW_WINDOWS=${OPTARG};;
      V) MODE=split && SPLIT_TYPE=v;;
      z) MODE=manage_windows && PANE_CREATION_SIZE=${OPTARG};;
      E) MODE=show_env;;
      h) MODE=show_help;;
    esac
  done
  shift $((OPTIND - 1))
fi

case $MODE in
  create_cycleset) stages=(detect_window create_cycleset);;
  clear_cyclesets) stages=(clear_cyclesets);;
  list_keys) stages=(set_reader list_keys);;
  show_scrollback) stages=(set_reader show_scrollback);;
  nav)
    if [[ $NAV_TARGET == "P" ]]; then
      stages=(detect_window prev_window)
    elif [[ $NAV_TARGET == "N" ]]; then
      stages=(detect_window next_window)
    elif [[ $NAV_TARGET == "J" ]]; then
      stages=(detect_window mru_window)
    elif [[ $NAV_TARGET =~ [udlrj] ]]; then
      stages=(pane_nav pane_size)
    fi
    ;;
  reload_tmux) stages=(reload_tmux);;
  manage_windows)
    stages=(detect_window)
    [[ ${NEW_WINDOWS} ]] && stages+=(add_windows)
    [[ ${SPLIT_WINDOWS} ]] && stages+=(split_windows pane_size)
    ;;
  split) stages=(detect_window split pane_size);;
  show_env) stages=(detect_window show_env);;
  show_help) stages=(show_help);;
esac


showrun_cmd () {
  [[ ! $2 == "false" ]] && echo "Executing: ${1} ..."
  eval $1
}

[[ ${stages[@]} =~ "show_help" ]] && do_show_help () {
  echo "${help_text}"
}

[[ ${stages[@]} =~ "show_env" ]] && do_show_env () {
  echo "EDITOR=${EDITOR}"
  echo "TMX_READER=${TMX_READER}"
  echo "TMX_GLOBAL_APW=${TMX_GLOBAL_APW}"
  echo "TMX_GLOBAL_APH=${TMX_GLOBAL_APH}"
  echo "TMX_LOCAL_APW=${TMX_LOCAL_APW}"
  echo "TMX_LOCAL_APH=${TMX_LOCAL_APH}"
  echo "current cyclesets: ${stored_cyclesets:-none}"
}


[[ ${stages[@]} =~ "detect_window" ]] && do_detect_window() {
  # Detect what window we're currently in out of how many.
  curr_win=$(tmux display-message -p "#{window_index}")
  first_win=$(tmux list-windows -F "#{window_index}" | sort -n | head -n 1)
  last_win=$(tmux list-windows -F "#{window_index}" | sort -n | tail -n 1)

  # Detect whatever we can about a current cycleset.
  if [[ -f ${CYCLESET_FILE} ]]; then
    stored_cyclesets=$(cat ${CYCLESET_FILE})
    if [[ $HONOR_CYCLESET == "true" ]]; then
      IFS=',' read -r -a cyclesets <<< $stored_cyclesets
      for set in ${cyclesets[@]}; do
        IFS="-" read -r min max <<< "${set}"
        if [[ ${curr_win} -ge $min ]] && [[ ${curr_win} -le $max ]]; then
          cycleset_min=$min
          [[ ${min} -lt ${first_win} ]] && cycleset_min=$first_win
          cycleset_max=$max
          [[ ${max} -gt ${last_win} ]] && cycleset_max=$last_win
          break
        fi
      done
    fi
  fi

  # Set up min/max vars for prev/next to use, whether we're in a cycleset or not.
  cycle_min=${cycleset_min:-${first_win}}
  cycle_max=${cycleset_max:-${last_win}}
}

[[ ${stages[@]} =~ "create_cycleset" ]] && do_create_cycleset () {
  cyclesets=()
  [[ -f ${CYCLESET_FILE} ]] && cyclesets+=($(cat ${CYCLESET_FILE}))
  cyclesets+=("${NEW_CYCLESET}")
  IFS="," stored_cyclesets="${cyclesets[*]}"
  echo "${stored_cyclesets}" > "${CYCLESET_FILE}"
  echo "Added cycleset. Current cyclesets: ${stored_cyclesets}"
}

[[ ${stages[@]} =~ "clear_cyclesets" ]] && do_clear_cyclesets () {
  if [[ -f ${CYCLESET_FILE} ]]; then
    echo "Clearing out all cyclesets."
    rm ${CYCLESET_FILE}
  else
    echo "No cyclesets found."
  fi
}

[[ ${stages[@]} =~ "set_reader" ]] && do_set_reader () {
  reader=${READER:-${TMX_READER:-${EDITOR:-less}}}
  [[ $READER_EXTRA ]] && reader="${reader} ${READER_EXTRA}"
  reader_btm=$reader
  if [[ ! $SMARTSCROLL == "false" ]]; then
    vimlike=(vi vim nvim nv nv-read)
    emacslike=(emacs)
    lesslike=("less")
    nanolike=("nano")
    [[ ${vimlike[@]} =~ $reader ]] && reader_btm="${reader} +\$"
    [[ ${emacslike[@]} =~ $reader ]] && reader_btm="${reader} --eval '(goto-char (point-max))'"
    [[ ${lesslike[@]} =~ $reader ]] && reader_btm="${reader} +G"
    [[ ${nanolike[@]} =~ $reader ]] && reader_btm="${reader} +-1"
  fi
}

[[ ${stages[@]} =~ "list_keys" ]] && do_list_keys () {
  cmd="tmux list-keys | ${reader}"
  showrun_cmd "$cmd"
}

[[ ${stages[@]} =~ "show_scrollback" ]] && do_show_scrollback () {
  cmd="tmux capture-pane -pS - | ${reader_btm}"
  showrun_cmd "$cmd"
}

[[ ${stages[@]} =~ "prev_window" ]] && do_prev_window () {
  new_win=$((curr_win - 1))
  [[ ${new_win} -lt ${cycle_min} ]] && new_win=$cycle_max
  cmd="tmux select-window -t ${new_win}"
  showrun_cmd "$cmd" false
}

[[ ${stages[@]} =~ "next_window" ]] && do_next_window() {
  new_win=$((curr_win + 1))
  [[ ${new_win} -gt ${cycle_max} ]] && new_win=$cycle_min
  cmd="tmux select-window -t ${new_win}"
  showrun_cmd "$cmd" false
}

[[ ${stages[@]} =~ "mru_window" ]] && do_mru_window() {
  cmd="tmux last-window"
  showrun_cmd "$cmd" false
}

[[ ${stages[@]} =~ "add_windows" ]] && do_add_windows () {
  cmd="tmux new-window -c '#{pane_current_path}'"

  if [[ $NEW_WINDOWS == "single" ]]; then
    eval $cmd
  else
    for i in $(seq 1 $NEW_WINDOWS); do
      echo "adding window $((last_win + i))"
      eval $cmd
      tmux select-window -t $curr_win
    done
  fi
}

# The split_windows and split stages are two different takes on window
# splitting. split is the newer one, and split_windows will probably go away or
# get integrated into split. For now they work side by side.
[[ ${stages[@]} =~ "split_windows" ]] && do_split_windows () {
  cmd="tmux split-window -h -c '#{pane_current_path}'"
  [[ -n $new_pane_width ]] && cmd="${cmd} -l ${new_pane_width}"

  if [[ ${SPLIT_WINDOWS} == "single" ]]; then
    eval $cmd
  else
    IFS=',' read -r -a win_nums <<< $SPLIT_WINDOWS
    for win_num in ${win_nums[@]}; do
      msg="splitting window ${win_num}"
      [[ -n ${new_pane_width} ]] && msg="${msg} with new pane size ${new_pane_width}"
      echo $msg

      tmux select-window -t $win_num
      [[ ! $? == 0 ]] && continue
      eval $cmd
      tmux select-pane -L
      tmux select-window -t $curr_win
    done
  fi
}

# The split_windows and split stages are two different takes on window
# splitting. split is the newer one, and split_windows will probably go away or
# get integrated into split. For now they work side by side.
[[ ${stages[@]} =~ "split" ]] && do_split () {
  cmd="tmux split-window -${SPLIT_TYPE} -c '#{pane_current_path}'"
  showrun_cmd "${cmd}" false
  target_pane_idx=$(tmux display -p "#{pane_index}")
}

[[ ${stages[@]} =~ "pane_nav" ]] && do_pane_nav () {
  case $NAV_TARGET in
    u) pane_matcher="up-of";;
    d) pane_matcher="down-of";;
    l) pane_matcher="right-of";;
    r) pane_matcher="left-of";;
    j) pane_matcher="last";;
  esac
  target_pane_idx=$(tmux display -p -t "{${pane_matcher}}" "#{pane_index}")
  cmd="tmux select-pane -t ${target_pane_idx}"
  showrun_cmd "$cmd" false
}

# Resize a recently worked-with pane. During creation of or switching to a pane,
# the function that did that should set the $target_pane_idx variable, and this
# function will use it to size the pane. As such, pane_size should come *after*
# that stage in the list of stages.
[[ ${stages[@]} =~ "pane_size" ]] && do_pane_size () {
  if [[ -n "$target_pane_idx" ]]; then
    if [[ -n "$PANE_CREATION_SIZE" ]]; then
      [[ SPLIT_TYPE == "h" ]] && new_pane_width=$PANE_CREATION_SIZE
      [[ SPLIT_TYPE == "v" ]] && new_pane_height=$PANE_CREATION_SIZE
    fi

    if [[ -z "$new_pane_width" ]]; then
      if [[ $TMX_LOCAL_APW =~ ^[0-9]+$ ]]; then
        new_pane_width=$TMX_LOCAL_APW
      elif [[ $TMX_LOCAL_APW == "off" ]]; then
        new_pane_width=""
      elif [[ $TMX_GLOBAL_APW =~ ^[0-9]+$ ]]; then
        new_pane_width=$TMX_GLOBAL_APW
      fi
    fi

    if [[ -z "$new_pane_height" ]]; then
      if [[ $TMX_LOCAL_APH =~ ^[0-9]+$ ]]; then
        new_pane_height=$TMX_LOCAL_APH
      elif [[ $TMX_LOCAL_APH == "off" ]]; then
        new_pane_height=""
      elif [[ $TMX_GLOBAL_APH =~ ^[0-9]+$ ]]; then
        new_pane_height=$TMX_GLOBAL_APH
      fi
    fi

    if [[ -n "$new_pane_width" || -n "$new_pane_height" ]]; then
      cmd="tmux resize-pane -t ${target_pane_idx}"
      [[ -n "$new_pane_width" ]] && cmd="${cmd} -x ${new_pane_width}"
      [[ -n "$new_pane_height" ]] && cmd="${cmd} -y ${new_pane_height}"
      showrun_cmd "$cmd" false
    fi
  fi
}

[[ ${stages[@]} =~ "reload_tmux" ]] && do_reload_tmux () {
  cmd="tmux source-file ~/.brettenv/tmux.conf"
  showrun_cmd "$cmd"
  echo "tmux config reloaded."
}

for stage in ${stages[@]}; do
  stage_fn="do_${stage}"
  ${stage_fn}
done
