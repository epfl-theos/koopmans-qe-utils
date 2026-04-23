# epsilon_basic

Integration test for `epsilon.x`.

> **Status: template / not yet wired up.** Only `run.sh` and this README
> are checked in. The fixtures, `epsilon.in`, `extract.sh`, and `ref.dat`
> below have not yet been produced, so the test is auto-skipped by
> `tests/CMakeLists.txt` (the `EXISTS … fixtures` / `ref.dat` guard) until
> they are added. The layout below describes what a finished test should
> contain.

## Layout

```
epsilon_basic/
├── run.sh              (already here)
├── README.md           (this file)
├── epsilon.in          ← &inputpp + &energy_grid namelists
├── extract.sh          ← parses eps*.dat (or epsilon.out) → actual.dat
├── ref.dat             ← reference scalars
└── fixtures/
    ├── epsilon.in                      (copied alongside the .save/)
    ├── <pseudo>.upf
    └── <prefix>.save/                  (from pw.x scf+nscf, HDF5 only)
        ├── charge-density.hdf5
        ├── data-file-schema.xml
        ├── wfc*.hdf5
        └── ...
```

## Constraints

* Build QE with `-DQE_ENABLE_HDF5=ON` when producing the fixture `.save/`.
* The `.save/` must be from an **nscf** run with enough empty bands — epsilon.x
  needs unoccupied states for optical transitions.
* Keep it small (a few atoms, ≤ 4 k-points, handful of empty bands).

## What `extract.sh` should produce

Pick a few deterministic scalars out of epsilon.x's output for regression.
Example (for `calculation='eps'`, which writes `epsr.dat`/`epsi.dat`):

```bash
#!/bin/bash
awk 'NR==10 { print "eps_r_w10", $2, $3, $4 }' epsr.dat
awk 'NR==10 { print "eps_i_w10", $2, $3, $4 }' epsi.dat
grep -E "^ *Fermi energy" epsilon.out | awk '{ print "ef", $4 }'
```

The format must be `<label> <number> [<number>...]` per line — see
`tests/common/compare.py`.

## Generating `ref.dat`

Run once on a trusted machine, then copy `actual.dat` → `ref.dat`.
