#!/bin/bash

_filePath=$0
_fn=$1
_path=$2
_lib=$3

_filename="${_filePath##*/}"
_projectname="${_path##*/}"

cd "$_path"

if [[ $_fn == "git_pull" ]]; then
    # echo "execute git pull"
    git pull origin master
elif [[ $_fn == "git_add" ]]; then
    # echo "execute git add"
    git add .
    # echo "add错误：$_error"
elif [[ $_fn == "git_commit" ]]; then
    # echo "execute git commit"
    _text="$_projectname update"
    if [[ "$_lib" ]]; then
    _text="$_lib update"
    fi
    git commit -m $_text
elif [[ $_fn == "git_push" ]]; then
    # echo "execute git push $_projectname"
    git push -u origin master
elif [[ $_fn == "git_all" ]]; then
     git pull origin master
     git add .
     _text="update"
     if [[ "$_lib" ]]; then
         _text="$_lib update"
     fi
     git commit -m $_text
     git push -u origin master
else
    echo "${_filename}未找到${_fn}对应的方法"
fi










