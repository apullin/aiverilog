# WTRACE experiment

WTRACE is a clean-room experiment in design-specific waveform capture. It is
not an implementation of WaveZip, whose source and file format are not public.
The useful idea being tested is narrower: most synchronous debugging asks for
the settled state at clock boundaries, not every event and delta cycle.

The organization is deliberately DWARF-like. A static table describes scopes,
signals, widths, ranges, and the clock. The dynamic stream refers to that table
by compact integer IDs and records only values that differ at the next clock
boundary. Values containing only zeroes and ones use one bit per HDL bit;
values containing X or Z switch to two-bit packing. Integer fields use varints,
and 64 KiB chunks use Icarus's bundled LZ4 implementation. Blocks that do not
shrink are stored raw.

## Build and use

From this directory, against the surrounding Icarus build tree:

```sh
make
```

Load the VPI module and call the two experimental system tasks:

```systemverilog
initial begin
  $wtracefile("run.wtr");          // Optional; defaults to wave.wtr.
  $wtracevars(clk, dut);           // Scope is recursive.
end
```

If the scope argument is omitted, WTRACE captures the scope containing the
task call. Both clock transitions are sampled. Each sample runs in a
read-only synchronization callback, after same-timestep nonblocking updates
have settled. The clock itself is included even when it is outside the chosen
scope.

Compile the design normally, then load `wtrace_vpi.vpi` when running `vvp`:

```sh
vvp -M/path/to/contrib/wtrace -mwtrace_vpi design.vvp
python3 wtrace_decode.py run.wtr -o run.vcd
```

Run the end-to-end test with `make test`.

`make benchmark` runs a small synthetic comparison against no tracing, FST,
and VCD. It is intended to expose regressions, not to claim equivalent
semantics: WTRACE deliberately omits activity between clock boundaries.

## Semantics and current limits

WTRACE preserves the initial checkpoint and settled values at clock
transitions. A signal that glitches and returns between two edges is
intentionally absent from the dynamic stream. This makes the result useful for
cycle-oriented RTL debugging, but it is not a replacement for an event-level
VCD/FST trace.

This first prototype supports one one-bit clock, recursively discovered nets,
registers, integral SystemVerilog variables, memory words, and four-state
values. It does not yet represent multiple/asynchronous clocks, real or string
values, named events, strength, force/release history, transient glitches,
delta-cycle ordering, or nondeterministic VPI/DPI side effects. Scope selection
and callback setup are intentionally explicit; no compiler instrumentation or
Icarus core changes are required.

## Version 1 stream

The file starts with `WTRC`, version, codec, and timing bytes. Its logical
payload is split into independently decompressible LZ4 blocks and contains:

1. A topologically ordered scope table (`parent`, kind, name).
2. A signal table (`scope`, kind, flags, width, ranges, name). Signal IDs are
   table indexes.
3. Frame records containing a time delta and sorted `(signal-ID delta,
   packed-value)` pairs.
4. A zero byte end marker.

Each physical block has little-endian stored and raw sizes followed by its LZ4
payload; the high bit of the stored size marks an uncompressed block. A zero
size pair terminates the container. In a frame, the low bit of the encoded
signal-ID delta selects one-bit binary or two-bit four-state packing.

The decoder validates bounds, ordering, record tags, and stream termination.
The format is experimental and should not yet be treated as stable.
