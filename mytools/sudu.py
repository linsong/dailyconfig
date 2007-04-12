#! /usr/bin/python 
import copy
from sets import Set

g_row_index = None

# not work correctly
#def permutations(L):
    #if len(L) == 1:
        #yield [L[0]]
    #elif len(L) >= 2:
        #(a, b) = (L[0:1], L[1:])
        #for p in permutations(b):
            #for i in range(len(p)+1):
                #yield b[:i] + a + b[i:]

def perms(list):
   if list == []:
     return [ [] ]
   return [ [list[i]] + p
     for i in range(len(list))
     if i == list.index(list[i])
     for p in perms(list[:i]+list[i+1:]) ]

def check_data_validity(init_data, row_index):
    for j in range(len(init_data[row_index])):
        column = [init_data[i][j] for i in range(len(init_data))
                  if init_data[i][j]!=0]
        if len(Set(column))!=len(column):
            return False

    base_i = (row_index/3)*3
    for base_j in range(0, len(init_data[row_index]), 3):
        #check data within a square
        square_data = []
        for i in range(3):
            for j in range(3):
                if init_data[base_i+i][base_j+j]!=0:
                    square_data.append(init_data[base_i+i][base_j+j])
        if len(Set(square_data))!=len(square_data):
            #print "square check failed"
            return False
    return True

def merge_data(fill_data, init_data, row_index):
    if row_index >= len(init_data):
        return True

    row = init_data[row_index]
    j = 0
    for i in range(len(row)):
        if row[i] != 0:
            continue
        else:
            row[i] = fill_data[j]
            j += 1
    assert j==len(fill_data)

    return check_data_validity(init_data, row_index)

def do_row(init_data, row_index):
    global g_row_index
    if row_index != g_row_index:
        #print "process row: %s"%row_index
        g_row_index = row_index

    if row_index >= len(init_data):
        return True

    orig_row = copy.deepcopy(init_data[row_index])
    expected_row = [1, 2, 3, 4, 5, 6, 7, 8, 9]
    expected_set = Set(expected_row)
    orig_set = Set([i for i in orig_row if i!=0 ])
    diff_set = expected_set.difference(orig_set)
    if len(diff_set)==0:
        print "current row is filled"
        return True
    plist = [p for p in perms(list(diff_set))]
    for p in plist:
        init_data[row_index] = copy.deepcopy(orig_row)
        if merge_data(p, init_data, row_index):
            if do_row(init_data, row_index+1):
                return True
            else:
                continue
        else:
            continue
    init_data[row_index] = copy.deepcopy(orig_row)
    return False

def start(init_data):
    print "="*50
    if do_row(init_data, 0):
        for i in range(len(init_data)):
            print "  %d:" % (i+1), init_data[i]
    else:
        print "Can not find the answer. :("
        print init_data

if __name__=="__main__":
    init_data = [ [] for i in range(9) ]
    init_data[0] = [0, 4, 1 ,2, 0, 0, 0, 0, 0]
    init_data[1] = [9, 0, 8, 0, 0, 5, 2, 0, 1]
    init_data[2] = [2, 3, 0, 0, 0, 1, 4, 7, 0]
    init_data[3] = [6, 0, 4, 8, 7, 0, 0, 9, 0]
    init_data[4] = [0, 5, 0, 0, 0, 0, 0, 0, 0]
    init_data[5] = [0, 0, 9, 5, 0, 0, 0, 3, 0]
    init_data[6] = [0, 0, 0, 0, 0, 0, 9, 2, 0]
    init_data[7] = [0, 9, 0, 0, 0, 4, 0, 0, 3]
    init_data[8] = [0, 0, 2, 0, 0, 9, 0, 4, 0]

    init_data1 = [ [] for i in range(9) ]
    init_data1[0] = [7, 0, 0, 2, 0, 0, 0, 0, 0]
    init_data1[1] = [0, 0, 9, 0, 7, 0, 0, 0, 3]
    init_data1[2] = [3, 5, 0, 9, 1, 0, 0, 7, 0]
    init_data1[3] = [0, 4, 0, 0, 2, 0, 9, 0, 0]
    init_data1[4] = [8, 0, 2, 0, 9, 0, 3, 0, 5]
    init_data1[5] = [0, 0, 3, 0, 4, 0, 0, 6, 0]
    init_data1[6] = [0, 1, 0, 0, 6, 2, 0, 3, 9]
    init_data1[7] = [2, 0, 0, 0, 5, 0, 6, 0, 0]
    init_data1[8] = [0, 0, 0, 0, 0, 9, 0, 0, 4]

    init_data2 = [ [] for i in range(9) ]
    init_data2[0] = [4, 0, 0, 0, 0, 8, 1, 7, 0]
    init_data2[1] = [1, 0, 0, 0, 3, 0, 0, 0, 0]
    init_data2[2] = [0, 0, 6, 9, 0, 0, 0, 3, 0]
    init_data2[3] = [6, 0, 0, 5, 9, 2, 0, 0, 0]
    init_data2[4] = [7, 2, 0, 8, 0, 3, 0, 0, 0]
    init_data2[5] = [0, 3, 5, 0, 0, 0, 2, 8, 0]
    init_data2[6] = [2, 0, 0, 1, 8, 0, 0, 6, 0]
    init_data2[7] = [0, 8, 0, 0, 7, 6, 0, 0, 0]
    init_data2[8] = [0, 6, 9, 0, 5, 0, 0, 1, 0]

    start(init_data);
    start(init_data1);
    start(init_data2);

