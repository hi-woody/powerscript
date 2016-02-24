<img alt="" src=".tools/pow.png" width="12%" style="width:12%"/>
\![Build Status](https://travis-ci.org/coderofsalvation/powscript.svg?branch=master)
  write shellscript in a powful way!

## Usage

    $ wget "https://raw.githubusercontent.com/coderofsalvation/powscript/master/powscript" -O /usr/local/bin/powscript && chmod 755 /usr/local/bin/powscript
    $ powscript myscript.pow                        # run directly
    $ powscript --compile myscript.pow > myscript   # output bashscript

## Example

    #!/usr/bin/env powscript
    
    usage()
      echo "yapp <number>"
      
    switch $1
      case [0-9]*
        echo "arg 1 is a number"
      case *
        if empty $1
          help=$(usage myapp)
          echo "Usage: $help" && exit

## Features

* memorizable syntax: more human-like, less robotic { ! [[ @ ]] || ~ and so on
* safetynets: automatic quoting, halt on error
* comfort: easy arrays, functional programming, named variables instead of positionals
* written in bash 4, 'zero'-dependency solution
* hasslefree: no installation or compilation using 3rd party software

## Reference

<table style="width:100%">
  <tr>
    <th>What</th>
    <th>Powscript</th>
    <th>Bash output</th>
  </tr>

  <tr>
    <td><b>functions</b></td>
    <td>
      <pre>
        <code>
foo( a, b )
  echo "doing foo"

foo one two
        </code>
      </pre>
    </td>
    <td>
      <pre>
        <code>
foo(){
  local a="$1"
  local b="$2"
  echo a="$a" b="$b"
}

foo one two
        </code>
      </pre>
    </td>
  </tr>

  <tr>
    <td><b>switch statement</b></td>
    <td>
      <pre>
        <code>
switch $foo
  case [0-9]*
    echo "bar"
  case *
    echo "foo"
        </code>
      </pre>
    </td>
    <td>
      <pre>
        <code>
case $foo in
  [0-9]*)
    echo "bar"
    ;;
  *)
    echo "foo"
    ;;
esac
        </code>
      </pre>
    </td>
  </tr>

  <tr>
    <td><b>easy if statements</b></td>
    <td>
      <pre>
        <code>
if $i is "foo"
  echo "foo" 
else
  echo "bar"

if not $j is "foo" and $x is "bar"
  if $j is "foo" or $j is "xfoo"
    if $j > $y and $j != $y or $j >= $y
      echo "foo"

        </code>
      </pre>
    </td>
    <td>
      <pre>
        <code>
if [[ "$i" == "foo" ]]; then
  echo "foo" 
else
  echo "bar"
fi

if [[ ! "$j" == "foo" && "$x" == "bar" ]]; then
  if [[ "$j" == "foo" || "$j" == "xfoo" ]]; then
    if [[ "$j" -gt "$y" && "$j" -ne "$y" || "$j" -ge "$y" ]]; then
      echo "foo"
    fi
  fi
fi
        </code>
      </pre>
    </td>
  </tr>

  <tr>
    <td><b>associative array</b></td>
    <td>
      <pre>
        <code>
foo={}
foo["bar"]="a value"

for k,v in foo
  echo k=$k
  echo v=$v
  
echo $foo["bar"]
        </code>
      </pre>
    </td>
    <td>
      <pre>
        <code>
declare -A foo
foo["bar"]="a value"

for k in "${!foo[@]}"; do
  v="${foo[$k]}"
  echo k="$k"
  echo v="$v"
done

echo "${foo["bar"]}"
        </code>
      </pre>
    </td>
  </tr>

  <tr>
    <td><b>indexed array</b></td>
    <td>
      <pre>
        <code>
bla=[]
bla[0]="foo"
bla+="push value"

for i in bla
  echo bla=$i

echo $bla[0]
        </code>
      </pre>
    </td>
    <td>
      <pre>
        <code>
declare -a bla
bla[0]="foo"
bla+=("push value")

for i in "${bla[@]}"; do
  echo bla="$i"
done

echo "${bla[0]}"
        </code>
      </pre>
    </td>
  </tr>

  <tr>
    <td><b>regex</b></td>
    <td>
      <pre>
        <code>
if $f match ^([f]oo)
  echo "foo found!"  
        </code>
      </pre>
    </td>
    <td>
      <pre>
        <code>
# extended pattern matching 
# (google 'extglob' for more

if [[ "$f" =~ ^([f]oo) ]]; then
  echo "foo found!"  
fi
        </code>
      </pre>
    </td>
  </tr>

  <tr>
    <td><b>require module</b></td>
    <td>
      <pre>
        <code>
# include bash- or powscript 
# at compiletime (=portable)
require 'mymodule.pow' 

# include remote bashscript 
# at runtime
source foo.bash 
        </code>
      </pre>
    </td>
    <td>
      <pre>
        <code>
        </code>
      </pre>
    </td>
  </tr>
  
  <tr>
    <td><b>empty / isset checks</b></td>
    <td>
      <pre>
        <code>
bar()
  if isset $1
    echo "no argument given"
  if not empty $1
    echo "string given"

foo "$@"    
        </code>
      </pre>
    </td>
    <td>
      <pre>
        <code>
foo(){
  if [[ "${#1}" == 0 ]]; then
    echo "no argument given"
  fi
  if [[ ! "${#1}" == 0 ]]; then
    echo "string given"
  fi
}

foo "$@"        
        </code>
      </pre>
    </td>
  </tr>
  
  <tr>
    <td><b>pipemap unwraps a pipe</b></td>
    <td>
      <pre>
        <code>
myfunc()
  echo "value=$1"

echo -e "foo\nbar\n" | pipemap myfunc

# outputs: 'value=foo' and 'value=bar'
        </code>
      </pre>
    </td>
    <td>
      <pre>
        <code>

        </code>
      </pre>
    </td>
  </tr>
  
  <tr>
    <td><b>FP: curry</b></td>
    <td>
      <pre>
        <code>
myfunc()
  echo "1=$1 2=$2"

curry curriedfunc abc
echo -e "foo\nbar\n" | pipemap curriedfunc

# outputs: '1=abc 2=foo' and '1=abc 2=bar'
        </code>
      </pre>
    </td>
    <td>
      <pre>
        <code>

        </code>
      </pre>
    </td>
  </tr>
  
  <tr>
    <td><b>easy math</b></td>
    <td>
      <pre>
        <code>
math '9 / 2'
math '9 / 2' 4
# outputs: '4' and '4.5000'
# NOTE: the second requires bc 
# to be installed for floatingpoint math
        </code>
      </pre>
    </td>
    <td>
      <pre>
        <code>

        </code>
      </pre>
    </td>
  </tr>
  
  <tr>
    <td><b>FP: array values, keys</b></td>
    <td>
      <pre>
        <code>
foo={}
foo["one"]="foo"
foo["two"]="bar"
map foo keys   # prints key per line
map foo values # prints value per line

        </code>
      </pre>
    </td>
    <td>
      <pre>
        <code>

        </code>
      </pre>
    </td>
  </tr>
  
  <tr>
    <td><b>FP: map</b></td>
    <td>
      <pre>
        <code>
printitem()
  echo "key=$1 value=$2"  

foo={}
foo["one"]="foo"
foo["two"]="bar"
map foo printitem
        </code>
      </pre>
    </td>
    <td>
      <pre>
        <code>

        </code>
      </pre>
    </td>
  </tr>
  
  <tr>
    <td><b>FP: pick</b></td>
    <td>
      <pre>
        <code>
foo={}
bar={}
foo["one"]="foo"
bar["foo"]="123"
map foo values | unpipe pick bar
# outputs: '123'
        </code>
      </pre>
    </td>
    <td>
      <pre>
        <code>

        </code>
      </pre>
    </td>
  </tr>

  <tr>
    <td><b>FP: compose</b></td>
    <td>
      <pre>
        <code>
funcA()
  echo "($1)"

funcB()
  echo "|$1|"

compose decorate_string funcA funcB
decorate_string "foo"

# outputs: '(|foo|)'
        </code>
      </pre>
    </td>
    <td>
      <pre>
        <code>

        </code>
      </pre>
    </td>
  </tr>

</table>

## Modules 

Create 1 portable bashscript.

####  /myapp.pow

    require 'mod/mymod.pow'
    require 'mod/foo.bash'

    mymodfunc
    bar

#### /mod/mymod.pow

    mymodfunc()
      echo "hi im a powscript module!"

#### /mod/foo.bash

    function bar(){
      echo "hi im a bash module"
    }

Then run `powscript --compile myapp.pow > all-in-one.bash`

## Todo

* `on`
* `first`
* `last`
* `filter`
* `curry`

## Wiki

* [Developer info / Contributions](https://github.com/coderofsalvation/powscript/wiki/Contributing)
* [Similar projects](https://github.com/coderofsalvation/powscript/wiki/Similar-projects)
