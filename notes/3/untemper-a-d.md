Alright: so we've got y = y ^ (y >> U), where U is 11.
Let's call the leftmost y "r", to make things easier:

r = x ^ (x >> U)

let's say r is R:0xDEB6_1F47

so we've got:

UUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUU : X
           UUUUUUUUUUUUUUUUUUUUU : I:X >> 11
11011110101101100001111101000111 : R:0xDEB6_1F47

Right off the bat, we know the top 11 bits, because I is effectively
00000000000UUUUUUUUUUUUUUUUUUUUU

So now we have

11011110101 UUUUUUUUUUUUUUUUUUUUU : X
            UUUUUUUUUUUUUUUUUUUUU : I:X >> 11
11011110101 101100001111101000111 : R:0xDEB6_1F47

But this means we also have the top 11 bits of I:
                        
11011110101 01101110010 UUUUUUUUUU : X
            11011110101 UUUUUUUUUU : I:X >> 11
11011110101 10110000111 1101000111 : R:0xDEB6_1F47

XOR'ing R and I would then give us the next 11 U bits:

0b11011110101 ^ 0b10110000111 = 0b01101110010; which also means
we have the next 11 bits of I:

11011110101 01101110010 UUUUUUUUUU : X
            11011110101 0110111001 : I:X >> 11
11011110101 10110000111 1101000111 : R:0xDEB6_1F47

and so on.

We can simplify this by taking

0xDEB6_1F47 ^ (0xDEB6_1F47 >> 11) ^ (0xDEB6_1F47 >> 22)


If we start with R = 0xDEAD_FD55, and L is 18, then:
0xDEAD_FD55 ^ (0xDEAD_FD55 >> 18)