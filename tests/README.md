# koopmans-qe-utils test suite

Small ctest-driven regression suite for `merge_evc.x`, `wann2kcp.x`, and
`epsilon.x`. Designed to be portable: binary fixtures use HDF5 where
possible, and the few unformatted-Fortran files are regenerated on each
run rather than checked in.

## Running

The suite is driven by `ctest`. There are two configuration modes,
depending on whether you have a build tree available.

### In-tree (developers building from source)

```bash
cmake -B build \
    -DQE_ROOT=/path/to/q-e \
    -DQE_ENABLE_TEST=ON
cmake --build build
ctest --test-dir build --output-on-failure
```

`QE_ROOT` should point at a QE source tree whose static libraries have
been built (`build/lib/libqe_pw.a`, …). Binary paths for the three
koopmans-qe-utils executables resolve to the freshly-built targets, so
no install is needed.

### Standalone (downstream packagers, post-install)

Configure only `tests/` as a project of its own. `find_program` picks
up the installed `merge_evc.x`, `wann2kcp.x`, `epsilon.x` from `PATH`:

```bash
cmake -S tests -B tests/_build
ctest --test-dir tests/_build --output-on-failure
```

This is what conda-forge's test phase does (see `recipe.yaml`). Override
specific binaries with `-DMERGE_EVC_EXECUTABLE=/abs/path`, etc.

### Selecting cases

```bash
ctest --test-dir <build-dir> -R merge_evc_basic --output-on-failure
ctest --test-dir <build-dir> -L wann2kcp        --output-on-failure
```

Tests auto-skip (are simply not registered) when their prerequisites
are missing: `wannier90.x` off `PATH`, fixtures absent, or `ref.dat`
not yet regenerated for that case.

## Layout

```
tests/
├── CMakeLists.txt
├── README.md                (this file)
├── common/
│   ├── compare.py           Float-tolerant scalar diff
│   ├── gen_merge_evc_inputs.f90
│   └── summarize_evc.f90
├── merge_evc_basic/
│   ├── run.sh
│   └── ref.dat
├── wann2kcp_basic/
│   ├── run.sh
│   ├── README.md            What fixtures this test needs
│   ├── seedname.txt         (you provide)
│   ├── wann2kcp.in          (you provide)
│   ├── extract.sh           (you provide)
│   ├── ref.dat              (you provide)
│   └── fixtures/            (you provide – HDF5 .save/, .win, .nnkp, .upf)
└── epsilon_basic/
    ├── run.sh
    ├── README.md
    ├── epsilon.in           (you provide)
    ├── extract.sh           (you provide)
    ├── ref.dat              (you provide)
    └── fixtures/            (you provide – HDF5 .save/, .upf)
```

## Design notes

* `compare.py` is a thin replacement for QE's `testcode.py` — one labelled
  line per scalar, absolute + relative tolerances, line-by-line diff.
* `merge_evc_basic` is fully self-contained: input `.evc` files are synthesised
  by `gen_merge_evc_inputs` (Fortran helper) at test time, so machine-level
  byte layout is consistent inside a single run.
* `wann2kcp_basic` ships `.save/` as a static HDF5 fixture but regenerates
  Wannier90's `<seedname>.chk` on each run, because Wannier90 has no portable
  checkpoint format.
* `epsilon_basic` ships `.save/` as a static HDF5 fixture and runs only
  `epsilon.x` — no `pw.x` call. This isolates regressions in `epsilon.x`
  from changes in upstream QE.

## Generating a new reference

When you edit a test or add a new one:

1. Run the test once on a trusted machine — it will fail if `ref.dat` doesn't
   exist or is stale.
2. Copy the produced `actual.dat` from the test's build directory
   (`build/tests/<test_name>/actual.dat`) into the source dir as `ref.dat`.
3. Review and commit.

Adjust per-test tolerances by editing the `compare.py` call in
`tests/CMakeLists.txt` (`--atol` / `--rtol` flags).
