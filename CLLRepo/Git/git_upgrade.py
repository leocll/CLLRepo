#!/usr/bin/env python3
# -*- coding: utf-8 -*-

__author__ = 'leocll'

import os, sys, json
from functools import reduce

def log_git(info):
    # print(info)
    pass

# for p in sys.argv:
#     print('外带参数：%s' % p)

def basepath():
    return '/Users/leocll/SVN项目/hftapp'

def filelist4path(path, fn=lambda x:x.find('.', 0, 1)==-1):
    log_git('路径：%s' % path)
    filelist = os.listdir(path)
    filelist = list(filter(lambda x: os.path.isfile(os.path.join(path, x)) and fn(x),filelist))
    log_git('文件：%s' % filelist)
    return filelist

def dirlist4path(path, fn=lambda x:x.find('.', 0, 1)==-1):
    log_git('路径：%s' % path)
    filelist = os.listdir(path)
    dirlist = list(filter(lambda x: os.path.isdir(os.path.join(path, x)) and fn(x),filelist))
    log_git('文件夹：%s' % dirlist)
    return sorted(dirlist,key=str.lower)

def max4verdirlist(dirlist):
    vlist = list(map(lambda x: x.split('.'), dirlist))

    if vlist is None or len(vlist) == 0:
        return None
    if len(vlist) == 1:
        return '.'.join(vlist[0])

    def str2int(si):
        try:
            return int(si)
        except BaseException:
            return -1

    def value4list(alist, i):
        if not isinstance(alist, list):
            raise ValueError
        if i < len(alist):
            return str2int(alist[i])
        return -1

    index = 0

    def maxintfn(x, y):
        xv = value4list(x, index) if isinstance(x, list) else x
        yv = value4list(y, index)
        return xv if xv > yv else yv

    while (True):
        if len(vlist) == 1:
            return '.'.join(vlist[0])
        maxint = reduce(maxintfn, vlist)
        if maxint == -1:
            return '.'.join(vlist[0])
        vlist = list(filter(lambda x: value4list(x, index) != -1 and str2int(x[index]) == maxint, vlist))
        index = index + 1

def maxverdir4path(path):
    dirlist = dirlist4path(path)
    return max4verdirlist(dirlist)

def file_content_rp(path, ostr, nstr):
    if os.path.isdir(path):
        filelist = filelist4path(path, fn=lambda x:x.find('.podspec')!=-1)
        if len(filelist) == 0:
            raise ValueError('%s has no .podspec file' % path)
        else:
            path = os.path.join(path, filelist[0])

    if path.rfind('.podspec', -8) == -1:
        raise ValueError('%s is not a .podspec file' % path)

    log_git('updating %s' % path)

    try:
        with open(path, 'r') as rf:
            content = rf.read()
            content = content.replace(ostr, nstr)
            with open(path, 'w') as wf:
                wf.write(content)
    except BaseException:
        raise IOError('%s replace failed' % path)

    return True

def file_content_ap(path, nstr):
    if os.path.isdir(path):
        filelist = filelist4path(path, fn=lambda x:x.find('.podspec')!=-1)
        if len(filelist) == 0:
            raise ValueError('%s has no .podspec file' % path)
        else:
            path = os.path.join(path, filelist[0])

    if path.rfind('.podspec', -8) == -1:
        raise ValueError('%s is not a .podspec file' % path)

    log_git('updating %s' % path)

    try:
        with open(path, 'a') as wf:
            wf.write('\n%s' % nstr)
    except BaseException:
        raise IOError('%s append failed' % path)

    return True

__fn_dic__ = {'basepath':basepath,
              'filelist4path':filelist4path,
              'dirlist4path':dirlist4path,
              'maxverdir4path':maxverdir4path,
              'max4verdirlist':max4verdirlist,
              'file_content_rp':file_content_rp,
              'file_content_ap':file_content_ap
              }
__fn__ = None
__args__ = []
__kwargs__ = {}

def __handle_arges__():
    global __fn__
    for i in range(1, len(sys.argv)):
        arg = sys.argv[i]
        index = arg.find('=')
        if index == -1:
            __args__.append(arg)
        else:
            if arg.find('fn', 0, index) != -1:
                __fn__ = arg[index + 1:].strip()
                __fn__ = __fn_dic__.get(__fn__, None)
            else:
                __kwargs__[arg[0:index].strip()] = arg[index + 1:].strip()

if __name__ == '__main__':
    __handle_arges__()
    try:
        res = __fn__(*__args__, **__kwargs__) if callable(__fn__) else __fn__
        if isinstance(res, list) or isinstance(res, dict):
            res = json.dumps(res)
    except BaseException as e:
        res = 'error:%s' % str(e)
    finally:
        print(res)
