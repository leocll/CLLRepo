#!/bin/bash

_filePath=$0
_fn=$1
_path=$2
_lib=$3

_filename="${_filePath##*/}"
_projectname="${_path##*/}"

cd "$_path"

# 开启异常
set -e

# 执行command
excu_command(){
#    _text="参数个数：${$#}，参数0：${0}，参数1：${1}，参数2：${2}"
#    if [[ "$3" ]]; then
#        echo "${_text}，参数3存在${3}"
#    fi
#    echo "${_text}"
#    exit 1
    _text="执行$1"
    if [[ "$2" ]]; then
        _text=$2
    fi
    if ! $1; then
        echo "error:${_text}失败"
        exit 1
    else
        echo "success:${_text}成功"
    fi
}

if [[ $_fn == "git_pull" ]]; then
    _fn="git pull origin master"

elif [[ $_fn == "git_add" ]]; then
    _fn="git add ."

elif [[ $_fn == "git_commit" ]]; then
    _text="更新${_projectname}"
    if [[ "$_lib" ]]; then
        _text="更新${_lib}"
    fi
    _fn="git commit -m \"$_text\""

elif [[ $_fn == "git_push" ]]; then
    _fn="git push -u origin master"

elif [[ $_fn == "git_all" ]]; then
    _fn="git pull origin master"
    excu_command "$_fn"

    _fn="git add ."
    excu_command "$_fn"

    _text="更新${_projectname}"
    if [[ "$_lib" ]]; then
        _text="更新${_lib}"
    fi
    _fn="git commit -m \"$_text\""
    excu_command "$_fn"

    _fn="git push -u origin master"
    excu_command "$_fn" "同步"
    exit 1
else
    echo "error:${_filename}未找到${_fn}对应的方法"
    exit 1
fi

excu_command "$_fn"

# 测试
# if [[ $_fn == "test_ls" ]]; then
#     _fn="ls"
#     excu_command $_fn "执行列表"
#     # excu_command $_fn
# elif [[ $_fn == "test_rm" ]]; then
#     _fn="rm ffadfasfas.text"
#     excu_command "$_fn" "执行删除"
#     # excu_command $_fn
# else
#     echo "error:${_filename}未找到${_fn}对应的命令"
#     exit 1
# fi

# if [[ $_fn == "git_pull" ]]; then
#    if ! git pull origin master; then exit 1; fi
# #    git pull origin master
# elif [[ $_fn == "git_add" ]]; then
#    if ! git add .; then exit 1; fi
# #    git add .
# elif [[ $_fn == "git_commit" ]]; then
#    _text="$_projectname update"
#    if [[ "$_lib" ]]; then
#    _text="$_lib update"
#    fi
#    if ! git commit -m $_text; then exit 1; fi
# #    git commit -m $_text
# elif [[ $_fn == "git_push" ]]; then
#    if ! git push -u origin master; then exit 1; fi
# #    git push -u origin master
# elif [[ $_fn == "git_all" ]]; then
#     git pull origin master
#     git add .
#     _text="update"
#     if [[ "$_lib" ]]; then
#         _text="$_lib update"
#     fi
#     git commit -m $_text
#     git push -u origin master
# else
#    echo "${_filename}未找到${_fn}对应的方法"
# fi










