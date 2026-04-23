# wann2kcp_basic

Integration test for `wann2kcp.x` on a 2-atom Si system adapted from the
koopmans tutorial 2 (01-koopmans-dscf, initialization → wannierize step).

## Layout

```
wann2kcp_basic/
├── run.sh              driver invoked by ctest
├── README.md           (this file)
├── wann2kcp.in         &inputpp namelist
├── ref.dat             reference scalars (regenerate — see below)
└── fixtures/
    ├── wannier90.win / .amn / .mmn / .eig / .nnkp
    └── TMP/
        └── kc.save/     HDF5 pw.x scf+nscf output
```

`wannier90.nnkp` is the output of `wannier90.x -pp`. We ship it because
`wann2kcp.x` reads it internally (via its pw2wannier90 code path). It is
plain text and machine-portable.

The Wannier90 seedname (`wannier90`) is hardcoded in `run.sh` and must
match both the `seedname = '…'` value in `wann2kcp.in` and the basename
of the `wannier90.*` fixture files. Change all three together if you
ever need to rename.

The Wannier90 checkpoint (`wannier90.chk`) is NOT shipped — it's regenerated
at test time by running `wannier90.x wannier90` against the `.amn`/`.mmn`/`.eig`/
`.win` fixtures. The `.save/` is HDF5, so it is portable cross-machine.

The scalar comparison is done by the shared `tests/common/summarize_evc.py`
helper, run against every `evcw*.dat` that `wann2kcp.x` produces — each
label is prefixed by the filename so both blocks land in `actual.dat`
alongside each other.

## Runtime requirement

`wannier90.x` must be on `PATH` (comes from the `wannier90` conda-forge
package; any other install works). If it isn't, CMake skips this test.

## Regenerating `ref.dat`

The checked-in `ref.dat` is populated. Regenerate it only when the test or
the upstream code is intentionally changed:

1. `ctest --test-dir build -R wann2kcp_basic --output-on-failure` — should
   pass against the current `ref.dat`; if intentional changes have made it
   stale, the diff lands in `build/tests/wann2kcp_basic/actual.dat`.
2. Copy `build/tests/wann2kcp_basic/actual.dat` → `tests/wann2kcp_basic/ref.dat`.
3. Review the diff and commit.

Adjust tolerances in the `compare.py` invocation in `tests/CMakeLists.txt`
(`--atol` / `--rtol`) if runs across machines drift more than the defaults
allow.
