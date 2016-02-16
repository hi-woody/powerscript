#!/bin/bash
indent_current=0
indent_last=0
stack=()

getindent(){
  echo "$1" | sed "s/\n/ /g" | awk '{ match($0, /^ */); printf("%d", RLENGTH) }' | sed 's/00/0/g'
}

push (){ 
  var="$1"; shift 1; eval "$var+=($(printf "'%s' " "$@"))"; 
}

makeindent(){  
  for((i=0;i<$1;i++)); do printf " "; done
}

stack_pop(){
  index=${#stack[@]}
  index=$((index-1))
  [[ $index == "-1" ]] && return 0
  lastitem="${stack[$index]}"
  unset stack["$index"]
  echo -e "$(makeindent $((indent_last-2)) )$lastitem"
  if ! (( (indent_last-2) == indent_current )); then 
    indent_last=$((indent_last-2))
    stack_pop
  fi
}

stack_update(){
  indent_last="$indent_current"
  indent_current=$(getindent "$1")
  #echo ">> $indent_last|$indent_current|stacksize:${#stack[@]}"
  if ((indent_current < indent_last)); then stack_pop; fi
}

transpile_all(){
  cat - | while IFS="" read line; do
    i=$(getindent "$line")
    [[ "$line" =~ "={}" ]] && echo "$(makeindent $i)declare -A ${line/=\{\}/}" && continue
    [[ "$line" =~ "=[]" ]] && echo "$(makeindent $i)declare -a ${line/=\[\]/}" && continue
    [[ "$line" =~ \$[A-Za-z_0-9] ]] && line="$(echo "$line" | sed -E 's/([ =])\$([a-zA-Z_0-9]+)/\1"$\2"/gi' )"
    echo "$line"
  done
}

transpile_for(){
  push stack "done"
  local arr="$(echo "$1" | awk '{ print $4 }' )"
  local i=$(( $(getindent "$code") + 2 ))
  code="$1; do"
  # iterate over associative array
  [[ "$code" =~ " of" ]] && [[ "$code" =~ [a-zA-Z_0-9],[a-zA-Z_0-9] ]] && {
    local key="$(echo "$code" | awk '{ print $2 }' | awk -F',' '{ print $1 }')"
    local value="$(echo "$code" | awk '{ print $2 }' | awk -F',' '{ print $2 }')"
    code="$code\n$(makeindent $i)$value=\"\${$arr[\$$key]}\""
    code="${code/,$value/}"
    code="${code/ of / in }"
    code="${code/ $arr/ \"\${!$arr\[@\]\}\"}";
  }
  # iterate over indexed array
  [[ "$code" =~ " in "[a-zA-Z_] ]] && {
    local key="$(echo "$code" | awk '{ print $2 }')"
    code="${code/ $arr/ \"\${$arr\[@\]\}\"}"
  }
  echo -e "$code" | transpile_all
}

transpile_if(){
  push stack "fi"
  code="${1/if not/if \!}"
  code="${code/if /if [[ }"
  code="${code/then/\]\]; then}"
  code="${code/ is / == }"
  echo "$code" | transpile_all
}

######################### begin-of-powscript-functions
compose() {
  result_fun=$1; shift ; f1=$1; shift ; f2=$1; shift
  eval "$result_fun() { $f1 \"\$($f2 \"\$*\")\"; }"
}
empty(){
  [[ "${#1}" == 0 ]] && return 0 || return 1
}
foreach(){ 
  eval "for i in \"\${!$1[@]}\"; do $2 \"\$i\" \"\$( echo \"\${$1[\$i]}\" )\"; done"
}
keys(){
  echo "$1"
}
last(){
  [[ ! -n $2 ]] && return 1 || eval "echo \${$1[$2]:(-1)}"
}
map(){
  set +m ; shopt -s lastpipe
  cat - | while read line; do "$@" "$line"; done
}
not(){
  if "$@"; then return 0; else return 1; fi
}

on() {
    func="$1" ; shift
    for sig ; do
        trap "$func $sig" "$sig"
    done
}

pick(){                                                                         
  [[ ! -n $2 ]] && return 1 || eval "echo \${$1[$2]}"
}
set -e


values(){
  echo "$2"  
}
######################### end-of-powscript-functions
# parse args
for arg in "$@"; do
  case "$arg" in
    --compile) 
      startfunction=compile
      ;;
    *)
      input="$arg"
      [[ ! -n $startfunction ]] && startfunction=runfile
      ;;
  esac
done

empty "$1" && {
  echo 'Usage:
    nutshell --compile <file.nutshell>
  ';
}

compile(){
  local enable=0
  echo -e "\n#\n# Nutshell functions\n#\n"
  while IFS="" read line; do 
    [[ "$line" =~ "end-of-nutshell-functions" ]] && break;
    [[ "$enable" == 1 ]] && echo "$line"
    [[ "$line" =~ "begin-of-nutshell-functions" ]] && enable=1
  done < $0 | sed '/^$/d'
  echo -e "\n#\n# Your nutshell application starts here\n#\n"
  while IFS="" read line; do 
    stack_update "$line"
    [[ "$line" =~ "for " ]] && transpile_for "$line" && continue 
    [[ "$line" == *.     ]] && transpile_dot "$line" && continue 
    [[ "$line" =~ "if "  ]] && transpile_if  "$line" && continue 
    echo "$line" | transpile_all
  done <  $input
}

runfile(){
  compile $input | bash
}

$startfunction "${0//.*\./}"
