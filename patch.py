#!/usr/bin/env python
# -*- coding: utf-8 -*-
import os
import sys
import commands

def patch(key, reverse=False):
    src_dir = os.path.join('..', 'src', key.replace('.diff', ''))
    diff_file = os.path.join('..', '..', '..', 'patch', key)
    if reverse:
        param = '-R'
    else:
        param = ''
    #print 'cd %s && patch -p0 %s < %s' % (src_dir, param, diff_file)
    return os.system('cd %s && patch -p0 %s < %s' % (src_dir, param, diff_file))

def find_diff():
    s, r = commands.getstatusoutput('find ./ | grep diff | sort')
    return r.split(os.linesep)

if __name__ == "__main__":
    reverve = sys.argv[1]
    diff_list = find_diff()
    if reverve == '-P':
        for e in diff_list:
            patch(e, False)
    elif reverve == '-R':
        for e in diff_list:
            patch(e, True)
    else:
        print(diff_list)
