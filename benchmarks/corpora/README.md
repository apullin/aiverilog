# External Design Corpora

Real-design benchmark workloads reference pinned checkouts staged
OUTSIDE this repository, under `$AIVERILOG_BENCH_CORPUS`
(default `~/personal/benchmark-corpora`). Workloads whose corpus is
not staged are skipped unless explicitly selected with `--workload`.

Every corpus is pinned by commit and content hashes; the runner also
hashes the sources and data inputs into each report, and
`compare.py` refuses to compare runs whose hashes differ.

## picorv32

- Upstream: https://github.com/YosysHQ/picorv32
- Pinned commit: `87c89ac` ("clean Makefile")
- Stage: `git clone https://github.com/YosysHQ/picorv32
  $AIVERILOG_BENCH_CORPUS/picorv32 && git -C
  $AIVERILOG_BENCH_CORPUS/picorv32 checkout 87c89ac`
- Firmware: build `firmware/firmware.hex` with a riscv32-capable GCC
  (rv32im/ilp32 and rv32imc/ilp32 multilibs), e.g.
  `make firmware/firmware.hex TOOLCHAIN_PREFIX=<prefix>-`.
  The gold oracle corresponds to this exact image:
  - `firmware/firmware.hex` sha256
    `c237213a426cf774571bcaf6f83004d9082491c2edd5f1f19ed79982e2762464`
    (built with riscv32-xilinx-elf GCC 13.4.0, COMPRESSED_ISA=C,
    default Makefile flags)
  - `picorv32.v` sha256
    `0836050971b3c6cdd28ac3b1e5719a67fb645161912bef1e472e63995ceb0622`
  - `testbench.v` sha256
    `eb32235dabffc2e2c4f6bb631066d96048a0bf80dc0cb57186fd1f7e9e572be4`
- Workload: `picorv32` — the standard testbench running the ISA test
  firmware to "ALL TESTS PASSED" (489,765 clock cycles). Compiled with
  `-DCOMPRESSED_ISA` from the corpus directory so embedded source
  paths (and therefore the gold file) are staging-independent.
- Output is deterministic; the gold was generated with one validated
  build and byte-verified against a second, independently compiled
  build (gcc 15 -O2 and clang 21 ThinLTO+PGO).
