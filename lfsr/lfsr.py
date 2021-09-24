#!/usr/bin/env python3


""" LFSR package """


class LFSR:
    def __init__(self, poly, start=1):
        self.state = self.start = start
        self.poly = poly

    def reset(self):
        self.state = self.start

    def enter_loop(self):
        for i in range(2 ** 17):
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

        for cpt in range(2 ** 17):
            if self.state == value:
                return cpt
            self.next()
        return False
