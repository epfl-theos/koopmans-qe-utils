#!/usr/bin/env python3
"""Float-tolerant scalar-output comparison used by the koopmans-qe-utils
test suite.

Each input file is a text file where every non-blank, non-comment line has
the form::

    <label> <number> [<number> ...]

Blank lines and lines starting with ``#`` are ignored. Actual and reference
files must have the same number of data lines, matching labels in the same
order, and matching number counts per label.

Floats are compared with ``math.isclose`` using configurable absolute and
relative tolerances. The script exits 0 on success and 1 on the first mismatch
(after reporting every failure).
"""
import argparse
import math
import sys


def parse(path):
    entries = []
    with open(path) as f:
        for lineno, raw in enumerate(f, 1):
            line = raw.split("#", 1)[0].strip()
            if not line:
                continue
            parts = line.split()
            label = parts[0]
            try:
                vals = [float(x) for x in parts[1:]]
            except ValueError as e:
                sys.exit(f"{path}:{lineno}: could not parse number ({e})")
            entries.append((lineno, label, vals))
    return entries


def main():
    p = argparse.ArgumentParser()
    p.add_argument("actual")
    p.add_argument("reference")
    p.add_argument("--atol", type=float, default=1e-6)
    p.add_argument("--rtol", type=float, default=1e-4)
    args = p.parse_args()

    actual = parse(args.actual)
    reference = parse(args.reference)

    if len(actual) != len(reference):
        sys.exit(
            f"data-line count differs: actual={len(actual)} reference={len(reference)}"
        )

    failures = []
    for (aln, al, av), (bln, bl, bv) in zip(actual, reference):
        if al != bl:
            failures.append(
                f"label mismatch at actual:{aln}/reference:{bln}: {al!r} vs {bl!r}"
            )
            continue
        if len(av) != len(bv):
            failures.append(
                f"{al}: number count differs ({len(av)} vs {len(bv)})"
            )
            continue
        for i, (x, y) in enumerate(zip(av, bv)):
            if not math.isclose(x, y, rel_tol=args.rtol, abs_tol=args.atol):
                failures.append(
                    f"{al}[{i}]: actual={x:.12g} reference={y:.12g} "
                    f"(|diff|={abs(x - y):.3g})"
                )

    if failures:
        print("\n".join(failures))
        sys.exit(1)
    print("OK")


if __name__ == "__main__":
    main()
