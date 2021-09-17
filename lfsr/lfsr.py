#!/usr/bin/env python3


""" LFSR package """


class LFSR:
    def __init__(self, poly, start=1):
        self.state = self.start = start
        self.poly = poly

    def reset(self):
        self.state = self.start

    def enter_loop(self):
        for i in range(2**17):
            next(self)
        return self

    def parity(self, bb):
        b = bb
        b ^= b >> 16
        b ^= b >> 8
        b ^= b >> 4
        b ^= b >> 2
        b ^= b >> 1
        b &= 1
        return b

    def next(self):
        b = self.state & self.poly
        b = self.parity(b)
        self.state = (self.state << 1) | b
        self.state &= (1 << 17) - 1
        return self.state

    def __iter__(self):
        return self

    def cpt_for(self, value):
        self.reset()

        for cpt in range(2**17):
            if self.state == value:
                return cpt
            self.next()
        return False
"""
print(bin(1))
lfsr = LFSR(0x0001D258)
print(bin(lfsr.poly))
for _ in range(20):
    lfsr.next()
print(bin(lfsr.state))
lfsr.next()
print(bin(lfsr.state))

polys = [
    0x0001D258, 0x00017E04,
    0x0001FF6B, 0x00013F67,
    0x0001B9EE, 0x000198D1,
    0x000178C7, 0x00018A55,
    0x00015777, 0x0001D911,
    0x00015769, 0x0001991F,
    0x00012BD0, 0x0001CF73,
    0x0001365D, 0x000197F5,
    0x000194A0, 0x0001B279,
    0x00013A34, 0x0001AE41,
    0x000180D4, 0x00017891,
    0x00012E64, 0x00017C72,
    0x00019C6D, 0x00013F32,
    0x0001AE14, 0x00014E76,
    0x00013C97, 0x000130CB,
    0x00013750, 0x0001CB8D
]

periods = [959000, 957000,
           953000, 949000,
           947000, 943000,
           941000, 939000,
           937000, 929000,
           919000, 911000,
           907000, 901000,
           893000, 887000]
"""
"""
lfsr = LFSR(0x0001D258)

for _ in range(100):
    b = bin(lfsr.next())
    b =b.replace('0b', '')
    if len(b) != 17:
        for _ in range(17-len(b)):
            b = '0' + b
    print(b)
"""


"""
pos = [1]
lfsr.next()
pourcent = 0
show = False
same = 0
for i in range(2**17):
    cpt = 0
    for j in pos:
        if cpt != 0:
                if lfsr.state == j:
                    same += 1
            cpt += 1
        
    pos.append(lfsr.next())

"""


"""
pos = [1]
for i in range(2**17):
    pos.append(lfsr.next())

lfsr.reset()
same = 0

for i in pos:

    cpt = 0
    for j in pos:
        if i==j:
            if cpt != 0:
                same += 1
            cpt += 1
print(same)

#this portion is returning 4


pos = [1]
for i in range(2**17):
    pos.append(lfsr.next())

lfsr.reset()
same = 0
pourcent = 0

for i in range(len(pos)):
    if (i/len(pos) > pourcent + 0.05):
        pourcent += 0.05
        print(f"{pourcent*100}% done")

    for j in range(len(pos)):
        if pos[i]==pos[j] and i != j:
            same += 1
            print(f"the same value is {pos[i]} at index {i} and {j}")

print(same)
"""