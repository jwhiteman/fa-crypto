# Untemper y = y ^ ((y << T) & C)

These are the constants:
T = 15
C = 0xEFC60000

Let's rewrite the equation:
R = X ⊕ ((X << T) & C)

Let's solve for X. Both sides have X, but one is bitshifted and AND'd with C
which may give us some room to get at least a few bits:

X = R ⊕ ((X << T) & C)

Let's say we got out 0X3BEBCAFE out of this particular tempering function.
So R, then is 0x3BEBCAFE.

What do we know?

We'll we've got some X, left shifted by 15 bits:

UUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUU000000000000000    X << 15

U can stand for unknown bit.

That's AND'd with C

So we've got something like:


UUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUU 000000000000000    X << 15
               11101111110001100 000000000000000    C
                 111011111010111 100101011111110    R:0x3BEBCAFE

If we & the first two lines together, and ⊕ against R, we should get some of
the bits of X. Unfortunately, we don't know X, but we know that the first
15 bits of (X << 15) are - they are 0. We also know C in its entirety.
0 AND'd with anything is zero. So let's let I stand for the bits of (X << 15) & C
that we can figure out:

UUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUU000000000000000    X << 15
               11101111110001100000000000000000    C
                              00000000000000000    I
                 111011111010111100101011111110    R:0x3BEBCAFE


So we've got 17 bits of I figured out. If we xor that against the first 17
bits of R, we can get the corresponding bits of X back. Let's do that:

00000000000000000 ⊕ 11100101011111110 = 11100101011111110
...which is just the left-hand side back, which isn't surprising.
So those are the first 17 bits of X.

But now we get to update some of those U bits!

                 1001010111111 10
UUUUUUUUUUUUUUU111001010111111 10000000000000000    X << 15
               111011111100011 00000000000000000    C
                               00000000000000000    I
                 1110111110101 11100101011111110    R:0x3BEBCAFE

And this allows us to update I (which is just the AND'ing of (X << 15) & C:

UUUUUUUUUUUUUUU111001010111111 10000000000000000    X << 15
               111011111100011 00000000000000000    C
               111001010100011 00000000000000000    I
                 1110111110101 11100101011111110    R:0x3BEBCAFE

And this allows us to xor more bits of R against I:

0b001110111110101 ⊕ 111001010100011 = 0b110111101010110

Which are more of our U bits!
   111101010110 11
110111101010110 111001010111111 10
110111101010110 111001010111111 10000000000000000    X << 15
                111011111100011 00000000000000000    C
                111001010100011 00000000000000000    I
                001110111110101 11100101011111110    R:0x3BEBCAFE

Therefore,

0b110111101010110 111001010111111 10000000000000000
or
(0b11011110101011011100101011111110000000000000000 >> 15)

gives us back 0xDEADCAFE, X.


```
def _untemper(result, shift_by, magic)
  mask  = (2 ** shift_by) - 1
  iters = (32 / shift_by.to_f).ceil

  solved_bits = result
  acc = 0

  iters.times.each do |n|
    shift_by_n  = shift_by * n
    magicn      = (magic >> shift_by_n) & mask & solved_bits
    intermed    = magicn & solved_bits
    solved_bits = ((result >> shift_by_n) & mask) ^ intermed

    acc = acc + (solved_bits << shift_by_n)
  end

  acc
end
```
