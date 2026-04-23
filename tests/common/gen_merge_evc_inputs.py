#!/usr/bin/env python3
"""Generate deterministic input files for merge_evc.x tests.

Produces two unformatted Fortran wavefunction files in the format
merge_evc.x expects::

    [int32 npw, int32 nbnd]             # Fortran record 1
    [complex(8) evc(npw)]                # Fortran record k, for k=1..nbnd

Values are filled from a closed-form expression so content is identical
on every run. Unformatted-Fortran record markers are 4-byte little-endian
int32 on both ends of each record — the standard gfortran / ifort / NVHPC
default on every platform conda-forge targets (x86_64 Linux, osx-arm64,
osx-64). Windows is skipped at the recipe level.

Usage::

    gen_merge_evc_inputs.py <file1> <file2> <npw> <nbnd1> <nbnd2>
"""
import struct
import sys


def write_record(fh, payload: bytes) -> None:
    """Write one unformatted Fortran record: 4-byte LE length + data + length."""
    header = struct.pack("<i", len(payload))
    fh.write(header)
    fh.write(payload)
    fh.write(header)


def write_file(path: str, npw: int, nbnd: int, formula) -> None:
    with open(path, "wb") as fh:
        write_record(fh, struct.pack("<ii", npw, nbnd))
        for j in range(1, nbnd + 1):
            buf = bytearray()
            for i in range(1, npw + 1):
                re, im = formula(i, j)
                buf += struct.pack("<dd", re, im)
            write_record(fh, bytes(buf))


def main():
    if len(sys.argv) != 6:
        print(
            "usage: gen_merge_evc_inputs.py <file1> <file2> <npw> <nbnd1> <nbnd2>",
            file=sys.stderr,
        )
        sys.exit(1)

    f1 = sys.argv[1]
    f2 = sys.argv[2]
    npw = int(sys.argv[3])
    nbnd1 = int(sys.argv[4])
    nbnd2 = int(sys.argv[5])

    write_file(
        f1, npw, nbnd1,
        lambda i, j: ((i + 10 * j) / npw, (i - j) / (2 * npw)),
    )
    write_file(
        f2, npw, nbnd2,
        lambda i, j: ((2 * i + j) / npw, (-i + 5 * j) / (3 * npw)),
    )


if __name__ == "__main__":
    main()
