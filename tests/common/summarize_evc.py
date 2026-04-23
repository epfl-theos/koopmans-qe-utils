#!/usr/bin/env python3
"""Read an unformatted Fortran wavefunction file in the format merge_evc.x
uses and print a deterministic scalar summary, suitable for piping into
tests/common/compare.py — one labelled line per quantity::

    npw <integer>
    nbnd <integer>
    norm <real>         # sqrt(sum |evc|^2) over all bands
    sum_re <real>
    sum_im <real>

Format assumptions match gfortran / ifort / NVHPC defaults: 4-byte
little-endian int32 record markers at both ends of each record.

Usage::

    summarize_evc.py <file>
"""
import math
import struct
import sys


def read_record(fh) -> bytes:
    """Read one Fortran unformatted record and return its payload."""
    head = fh.read(4)
    if len(head) < 4:
        raise EOFError("truncated record header")
    (length,) = struct.unpack("<i", head)
    payload = fh.read(length)
    if len(payload) != length:
        raise EOFError(f"truncated record body ({len(payload)} of {length} bytes)")
    tail = fh.read(4)
    if len(tail) < 4:
        raise EOFError("truncated record trailer")
    (trailing,) = struct.unpack("<i", tail)
    if trailing != length:
        raise ValueError(
            f"record length mismatch: head={length} tail={trailing}"
        )
    return payload


def main():
    if len(sys.argv) != 2:
        print("usage: summarize_evc.py <file>", file=sys.stderr)
        sys.exit(1)

    with open(sys.argv[1], "rb") as fh:
        header = read_record(fh)
        npw, nbnd = struct.unpack("<ii", header)

        norm_sq = 0.0
        sum_re = 0.0
        sum_im = 0.0
        for _ in range(nbnd):
            data = read_record(fh)
            if len(data) != 16 * npw:
                raise ValueError(
                    f"band record size {len(data)} != expected {16 * npw}"
                )
            for i in range(npw):
                re, im = struct.unpack_from("<dd", data, i * 16)
                norm_sq += re * re + im * im
                sum_re += re
                sum_im += im

    print(f"npw    {npw}")
    print(f"nbnd   {nbnd}")
    print(f"norm   {math.sqrt(norm_sq):.16e}")
    print(f"sum_re {sum_re:.16e}")
    print(f"sum_im {sum_im:.16e}")


if __name__ == "__main__":
    main()
