# Upstream Tracking

This is the reconciliation ledger between
[`steveicarus/iverilog`](https://github.com/steveicarus/iverilog) and this
[`apullin/aiverilog`](https://github.com/apullin/aiverilog) fork. It records
work derived from upstream issues, work that upstream later made unnecessary,
and reviewed reports for which the fork deliberately carries no patch.

Last reconciled: 2026-11-15

- Latest upstream commit integrated at this checkpoint:
  [`e6b789157`](https://github.com/steveicarus/iverilog/commit/e6b789157).
- Latest fork change before this ledger update:
  [`cbffbf137`](https://github.com/apullin/aiverilog/commit/cbffbf137).
- `Landed` means that Aiverilog intentionally retains a fork delta.
- `Elided` means that no fork delta remains or was needed, usually because
  upstream already supplied the behavior.
- This records fork disposition, not the mutable open/closed state displayed
  by the upstream issue tracker.

## Why The History Contains Upstream Merges

The 2026 fork campaign began from common base
[`0723d9a47`](https://github.com/steveicarus/iverilog/commit/0723d9a477b602dead4d99590de0bc5e3647737f)
without first refreshing the local upstream remote. By the time the omission
was discovered, 84 fork-only non-merge commits had already been published and
linked through the fork's issues and pull requests. Upstream had meanwhile
advanced by 15 commits to
[`e5482b89b`](https://github.com/steveicarus/iverilog/commit/e5482b89b1ec36237e0c70bdb8e0c8f8acd87153).

Rewriting the published fork would have broken those review links without
improving the resulting source tree. Instead,
[Aiverilog PR #27](https://github.com/apullin/aiverilog/pull/27) merged the
upstream history after a patch-by-patch cross-check. Pure upstream still failed
22 of 25 selected fork legacy regressions, failed 12 of 16 modern regressions,
and timed out on one more; none of the 84 fork commits was patch-equivalent to
the incoming work. The combined tree then passed the complete legacy, modern,
and VPI suites. A later ordinary merge integrated upstream
[`15689210c`](https://github.com/steveicarus/iverilog/commit/15689210c137c23107c96f63ddcdfb0d72076aae).

The fork therefore uses normal upstream merges from that point forward. The
published PR graph is historical evidence, not a stack that should be rebased
or force-pushed whenever upstream advances.

The second sync on 2026-08-29 merged 105 upstream commits (`15689210c..64f13540a`)
via [`2c098f871`](https://github.com/apullin/aiverilog/commit/2c098f87177cf3f4cd18f0d9785fccca70946751)
and two follow-ups
[`616095528`](https://github.com/apullin/aiverilog/commit/616095528436836be877743ca6e03ed5819ca7f7)
and [`39032f39d`](https://github.com/apullin/aiverilog/commit/39032f39d6a153b7399e43c1aad00c48d2d8cf83).
Fork bugfix branches were retained as artifacts per policy; the merge is the
single source of truth for comparison.

The first attempt to publish the subsequent issue work accidentally made the
entire sync part of PR #68, then merged PRs #69-#71 and #73 before their checks
and review were complete. Fork `master` was repaired to retain the reviewed sync
commits above while replacing those post-sync changes with the focused commits
listed below. The old PR pages remain audit records, not authoritative patch
boundaries.

The third sync on 2026-11-13 merged 602 upstream commits (`64f13540a..985bc3f88`)
via [`a3a1367d6`](https://github.com/apullin/aiverilog/commit/a3a1367d6),
unwinding superseded fork code deltas for GH #716, #1112, #1134, #1268,
#1298/#1459, #1407, and #1411 while adapting retained fork fixes and performance
paths to upstream's owned AST pointers, unpacked-array subroutine ports, enum
FST metadata, and scalar specify/SDF pulse rearming.

The fourth sync on 2026-11-15 merged 60 upstream commits (`985bc3f88..e6b789157`)
via [`9b649516b`](https://github.com/apullin/aiverilog/commit/9b649516b),
integrating upstream out-of-block `extern` class methods ([PR #1770](https://github.com/steveicarus/iverilog/pull/1770)),
`ref`/`const ref` subroutine arguments ([PR #1772](https://github.com/steveicarus/iverilog/pull/1772) / [PR #1776](https://github.com/steveicarus/iverilog/pull/1776)),
parameterized classes ([PR #1777](https://github.com/steveicarus/iverilog/pull/1777)),
mixed concatenation target conversions ([PR #1778](https://github.com/steveicarus/iverilog/pull/1778) / [PR #1790](https://github.com/steveicarus/iverilog/pull/1790)),
and upstream merges of [PR #1740](https://github.com/steveicarus/iverilog/pull/1740) and [PR #1773](https://github.com/steveicarus/iverilog/pull/1773).

## Landed Before Fork Issue Bookkeeping

These fixes were committed directly during the original bugfix campaign. They
all link the upstream report in their commit messages, but predate the later
one-fork-issue/one-PR workflow.

| Upstream report | Fork record | Retained result |
| --- | --- | --- |
| [#1170](https://github.com/steveicarus/iverilog/issues/1170) | [`7c58db61d`](https://github.com/apullin/aiverilog/commit/7c58db61dffd1a743810820e3cbaa93367a3c8b6) | Let `tgt-sizer` skip the SystemVerilog `$unit` package scope. |
| [#1267](https://github.com/steveicarus/iverilog/issues/1267) | [`25a19d36b`](https://github.com/apullin/aiverilog/commit/25a19d36ba7244c227f3337ef645fcfa3e6f899a) | Allow `wire logic` connected to a `uwire` port to have multiple drivers. Interaction with resolved net types remains an explicit TODO in the commit. |
| [#1321](https://github.com/steveicarus/iverilog/issues/1321) | [`9217e3c0f`](https://github.com/apullin/aiverilog/commit/9217e3c0fc784761755cce596a02621487f77f60) | Accept prefix labels on `begin` and `fork` blocks (upstream also added general statement labels in [`194dc4f86`](https://github.com/steveicarus/iverilog/commit/194dc4f86)). |
| [#1276](https://github.com/steveicarus/iverilog/issues/1276) | [`dab398b83`](https://github.com/apullin/aiverilog/commit/dab398b83fc5b14f1c971fc2dbdff7e4daf9b642) | Guard only: reject an unsupported procedural continuous assignment with a concatenation l-value instead of asserting. |
| [#1119](https://github.com/steveicarus/iverilog/issues/1119) / [#1120](https://github.com/steveicarus/iverilog/issues/1120) | [`a37e1dc68`](https://github.com/apullin/aiverilog/commit/a37e1dc68ce58522cb662b92d3562a6149aa1a61) | Guard only: make the `vlog95` backend reject unsafe shared-port translation instead of asserting or emitting incorrect Verilog. |
| [#1103](https://github.com/steveicarus/iverilog/issues/1103) | [`66fd57d0d`](https://github.com/apullin/aiverilog/commit/66fd57d0d970b71aba86d6070b79f162d4e614ed) | Guard only: diagnose unsupported `join_any`/`join_none` in automatic scopes before VVP aborts. |
| [#455](https://github.com/steveicarus/iverilog/issues/455) | [`e9720bb6c`](https://github.com/apullin/aiverilog/commit/e9720bb6c4fd7ff096f87d5c4e25c9bb4af9c5c6) | Enforce ``default_nettype none`` on ANSI and split port declarations. |
| [#1038](https://github.com/steveicarus/iverilog/issues/1038) | [`be37b84fb`](https://github.com/apullin/aiverilog/commit/be37b84fbea24a0365693fb57450efadf4fd2041) | Resolve package-qualified names through `vpi_handle_by_name`. |
| [#1291](https://github.com/steveicarus/iverilog/issues/1291) | [`8633c2cec`](https://github.com/apullin/aiverilog/commit/8633c2cecadf567fcec239b66da63e1de0974d5d) | Guard only: turn an uninitialized event-pin abort into a source-located unsupported diagnostic. Root-cause elaborator reuse remains deferred. |
| [#1236](https://github.com/steveicarus/iverilog/issues/1236) | [`2a4ec9ec2`](https://github.com/apullin/aiverilog/commit/2a4ec9ec2f675504dcd723bb60d0e742139dc4d1) | Stop shrinking live `StringHeap` cells with `realloc`, which could move storage and invalidate every returned string. |
| [#1202](https://github.com/steveicarus/iverilog/issues/1202) | [`c90d96ec2`](https://github.com/apullin/aiverilog/commit/c90d96ec2f7e31f2efcfdc2f0cd0c60763b5d845), adapted in [`616095528`](https://github.com/apullin/aiverilog/commit/616095528436836be877743ca6e03ed5819ca7f7) | Drive default expressions on top-level input ports. Post-sync `LineInfo::set_line` only copies `lexical_pos` when `UINT_MAX`; the synthesized `PEIdent`'s `~0U` was clobbered, re-asserted after `set_line` (check that `early_sig_elab3` gold also tracked the new `591d2c247` phrasing). |

## Landed Through Fork Issues And Pull Requests

This is the durable public workflow used after the initial stack. A merge hash
identifies the point at which the result entered fork `master`; implementation
commits are included for batched PRs.

| Upstream report | Fork issue / PR / merge | Retained result |
| --- | --- | --- |
| [#1288](https://github.com/steveicarus/iverilog/issues/1288) | [#5](https://github.com/apullin/aiverilog/issues/5), [PR #6](https://github.com/apullin/aiverilog/pull/6), [`fa1dc4e82`](https://github.com/apullin/aiverilog/commit/fa1dc4e8260587f278954df31aa762110dcc156a) | Accept a final command-file name without a trailing newline. |
| [#1019](https://github.com/steveicarus/iverilog/issues/1019) | [#7](https://github.com/apullin/aiverilog/issues/7), [PR #8](https://github.com/apullin/aiverilog/pull/8), [`5497518c6`](https://github.com/apullin/aiverilog/commit/5497518c66a13d4d6617efa9dd526a0023e7a36e) | Add `iverilog --help` and `--version`. |
| [#1187](https://github.com/steveicarus/iverilog/issues/1187) | [#9](https://github.com/apullin/aiverilog/issues/9), [PR #10](https://github.com/apullin/aiverilog/pull/10), [`73d5c68cc`](https://github.com/apullin/aiverilog/commit/73d5c68cc5c48adf1bc03edc910b4340361be35c) | Support spaces in `-B` tool paths while preserving native MinGW invocation syntax. |
| [#1396](https://github.com/steveicarus/iverilog/issues/1396) | [#13](https://github.com/apullin/aiverilog/issues/13), [PR #14](https://github.com/apullin/aiverilog/pull/14), [`d3487c94f`](https://github.com/apullin/aiverilog/commit/d3487c94fc7425f49b80f957bfe3f748b55ebb1e) | Include source and destination types in required enum-cast diagnostics. |
| [#1000](https://github.com/steveicarus/iverilog/issues/1000) | [#15](https://github.com/apullin/aiverilog/issues/15), [PR #16](https://github.com/apullin/aiverilog/pull/16), [`1259da6f0`](https://github.com/apullin/aiverilog/commit/1259da6f0b46876318b930b78bfd3a2b4fc3fcb1) | Emit escaped Make-compatible dependency files with `-Mmake=<file>`. |
| [#1322](https://github.com/steveicarus/iverilog/issues/1322) / [#1381](https://github.com/steveicarus/iverilog/issues/1381) | [#17](https://github.com/apullin/aiverilog/issues/17), [PR #18](https://github.com/apullin/aiverilog/pull/18), [`931cb5564`](https://github.com/apullin/aiverilog/commit/931cb55646ba8819ce7b570e2b6621a4d1a8171e) | Import and harden [upstream PR #1377](https://github.com/steveicarus/iverilog/pull/1377): optional warnings for invalid dynamic unpacked-array writes. |
| [#1218](https://github.com/steveicarus/iverilog/issues/1218) | [#19](https://github.com/apullin/aiverilog/issues/19), [PR #20](https://github.com/apullin/aiverilog/pull/20), [`e8cb74996`](https://github.com/apullin/aiverilog/commit/e8cb74996706bcf5af7c9aa122c42e45daf2799b) | Preserve an undriven local net while an unpacked-array alias still refers to its nexus. |
| [PR #1405](https://github.com/steveicarus/iverilog/pull/1405) | [#21](https://github.com/apullin/aiverilog/issues/21), [PR #22](https://github.com/apullin/aiverilog/pull/22), [`593fce299`](https://github.com/apullin/aiverilog/commit/593fce299eb3ed17aa6234d680a8133a4b878ec3) | Import missing `AH_TEMPLATE` declarations so modern `autoheader` can regenerate the build files. |
| [#1220](https://github.com/steveicarus/iverilog/issues/1220) | [PR #24](https://github.com/apullin/aiverilog/pull/24), [`580b4bf81`](https://github.com/apullin/aiverilog/commit/580b4bf81ac06d67206be6a1e0926bfa3519a656), merge [`1ea7a6621`](https://github.com/apullin/aiverilog/commit/1ea7a66213b6fa0da2224c221e44164c79a5d00c) | Materialize nexuses for unconnected unpacked `uwire` ports. |
| [#276](https://github.com/steveicarus/iverilog/issues/276) / [#521](https://github.com/steveicarus/iverilog/issues/521) / [#1277](https://github.com/steveicarus/iverilog/issues/1277) | [PR #24](https://github.com/apullin/aiverilog/pull/24), then [#36](https://github.com/apullin/aiverilog/issues/36) / [PR #37](https://github.com/apullin/aiverilog/pull/37), merge [`9b3f47e1a`](https://github.com/apullin/aiverilog/commit/9b3f47e1a8004e3107f761deb436c2a722cb279d) | Canonically collapse dynamic packed-prefix indices for full selections and slices, on reads and writes. |
| [#1317](https://github.com/steveicarus/iverilog/issues/1317) | [PR #24](https://github.com/apullin/aiverilog/pull/24), [`14033b9f7`](https://github.com/apullin/aiverilog/commit/14033b9f73c1f0cd285ddbd92d5baac5dc50c6b3), merge [`1ea7a6621`](https://github.com/apullin/aiverilog/commit/1ea7a66213b6fa0da2224c221e44164c79a5d00c) | Reject conflicting procedural drivers when one process is `always_ff`. |
| [#1016](https://github.com/steveicarus/iverilog/issues/1016) | [PR #25](https://github.com/apullin/aiverilog/pull/25), [`50b564f05`](https://github.com/apullin/aiverilog/commit/50b564f057803bc8a4bb90cbb3ee7768c0710741), merge [`4a64e57c8`](https://github.com/apullin/aiverilog/commit/4a64e57c8691d17efd76405ce01636d8ad8d5c16) | Keep named sequential blocks in their enclosing loop thread unless a normal `disable` statement actually targets the scope. |
| [#638](https://github.com/steveicarus/iverilog/issues/638) | [PR #25](https://github.com/apullin/aiverilog/pull/25), [`b17b185c1`](https://github.com/apullin/aiverilog/commit/b17b185c1e7221d622202b47b32edf006cdc44c9), merge [`4a64e57c8`](https://github.com/apullin/aiverilog/commit/4a64e57c8691d17efd76405ce01636d8ad8d5c16) | Remove scanner `REJECT` paths so Flex buffers can grow for long generated tokens. |
| [#1093](https://github.com/steveicarus/iverilog/issues/1093) / [#1325](https://github.com/steveicarus/iverilog/issues/1325) | [#28](https://github.com/apullin/aiverilog/issues/28), [PR #29](https://github.com/apullin/aiverilog/pull/29), [`1eff0b171`](https://github.com/apullin/aiverilog/commit/1eff0b171b779ebfa3c17bc8dce7cd730c49a619) | Preserve per-bit variable state when only part of a coerced variable has structural drivers. |
| [#1436](https://github.com/steveicarus/iverilog/issues/1436) | [#30](https://github.com/apullin/aiverilog/issues/30), [PR #31](https://github.com/apullin/aiverilog/pull/31), [`e8271656a`](https://github.com/apullin/aiverilog/commit/e8271656ab2f0ebc4c9d2bb8380207ec375baa39) | Implement VVP multiple-match checks for `unique` and `unique0` cases. |
| [#1231](https://github.com/steveicarus/iverilog/issues/1231) | [#32](https://github.com/apullin/aiverilog/issues/32), [PR #33](https://github.com/apullin/aiverilog/pull/33), [`9d8696855`](https://github.com/apullin/aiverilog/commit/9d8696855f79d1771060d0d772837c93afb4f84c) | Diagnose an unsupported coerced unpacked inout port instead of asserting. |
| [#1183](https://github.com/steveicarus/iverilog/issues/1183) | [#34](https://github.com/apullin/aiverilog/issues/34), [PR #35](https://github.com/apullin/aiverilog/pull/35), [`003c7a8de`](https://github.com/apullin/aiverilog/commit/003c7a8dee678fdfecf3c9f0a473134689b5f02d), adapted in [`a3a1367d6`](https://github.com/apullin/aiverilog/commit/a3a1367d6) | Reject incompatible unpacked-array vs packed task output arguments while permitting matching unpacked-array task output ports from upstream PR #1450. |
| [#835](https://github.com/steveicarus/iverilog/issues/835) | [#38](https://github.com/apullin/aiverilog/issues/38), [PR #39](https://github.com/apullin/aiverilog/pull/39), [`32d53f1cd`](https://github.com/apullin/aiverilog/commit/32d53f1cd30eb51958ec0ce33a05f15ccc1879ac) | Support dynamic packed-array prefixes on packed-struct member l-values and cleanly reject unsupported member indices. |
| [#470](https://github.com/steveicarus/iverilog/issues/470) | [#40](https://github.com/apullin/aiverilog/issues/40), [PR #41](https://github.com/apullin/aiverilog/pull/41), [`73cc40a6b`](https://github.com/apullin/aiverilog/commit/73cc40a6b5431972a04f175bf6f6c2b0ee624ff5) | Support event controls on dynamic-array elements without delivering objects to vector part-select functors. |
| [#405](https://github.com/steveicarus/iverilog/issues/405) | [#42](https://github.com/apullin/aiverilog/issues/42), [PR #43](https://github.com/apullin/aiverilog/pull/43), [`28f650f3f`](https://github.com/apullin/aiverilog/commit/28f650f3fb6cd0aa44c19c93aa501b6f410f2db6) | Validate arguments even when a task or void function has an empty body. |
| [#312](https://github.com/steveicarus/iverilog/issues/312) | [#44](https://github.com/apullin/aiverilog/issues/44), [PR #45](https://github.com/apullin/aiverilog/pull/45), [`aa233e543`](https://github.com/apullin/aiverilog/commit/aa233e543bc51a652f05f5d2e8e2809d205fddd1) | Preserve the VPI variable type of continuously driven `logic` while retaining net-resolution semantics. |
| [#962](https://github.com/steveicarus/iverilog/issues/962) | [#46](https://github.com/apullin/aiverilog/issues/46), [PR #47](https://github.com/apullin/aiverilog/pull/47), [`b354b91f9`](https://github.com/apullin/aiverilog/commit/b354b91f99cfb30831358a323154ad0c2591cb8f) | Stop active and nonblocking scheduler work immediately after `$finish`, while still running final blocks. |
| [#1140](https://github.com/steveicarus/iverilog/issues/1140) | [#48](https://github.com/apullin/aiverilog/issues/48), [PR #49](https://github.com/apullin/aiverilog/pull/49), [`6bdfd2254`](https://github.com/apullin/aiverilog/commit/6bdfd225467f008a100f7f618cff1358148c83a1), superseded by upstream [`591d2c247`](https://github.com/steveicarus/iverilog/commit/591d2c2473148777bc516694e3e6f15f4c75ca20) | Fork initially rejected X/Z dimensions with SV-error/Verilog-warning split; upstream now always errors with `Dimensions must be a constant with no unknown or high-Z bits`. Master at [`2c098f871`](https://github.com/apullin/aiverilog/commit/2c098f87177cf3f4cd18f0d9785fccca70946751) unwinds the fork phrasing and adopts upstream's diagnostic; `fix/upstream-1140` retained as artifact and `br_gh1140` golds updated. |
| [#1326](https://github.com/steveicarus/iverilog/issues/1326) | [#50](https://github.com/apullin/aiverilog/issues/50), [PR #51](https://github.com/apullin/aiverilog/pull/51), [`adcf11430`](https://github.com/apullin/aiverilog/commit/adcf114309b78feb90622ad2c7e88a1752727c63) | Adopt the requested convention of starting edge-sensitive `always` listeners before ordinary time-zero `initial` processes. |
| [#1184](https://github.com/steveicarus/iverilog/issues/1184) | [#52](https://github.com/apullin/aiverilog/issues/52), [PR #53](https://github.com/apullin/aiverilog/pull/53), [`246e33cea`](https://github.com/apullin/aiverilog/commit/246e33cea2a411322bb2ec5c7af04c570a5269de), adapted in [`a3a1367d6`](https://github.com/apullin/aiverilog/commit/a3a1367d6) | Schedule multi-bit (`width > 1`) module-path transitions per bit and coalesce equal-time arrivals, while scalar (`width == 1`) module paths use upstream's pulse-rearming path ([PR #1714](https://github.com/steveicarus/iverilog/pull/1714)). |
| [#1048](https://github.com/steveicarus/iverilog/issues/1048) | [#54](https://github.com/apullin/aiverilog/issues/54), [PR #55](https://github.com/apullin/aiverilog/pull/55), [`01508e56c`](https://github.com/apullin/aiverilog/commit/01508e56cab8ff313a1054ea67b3f26e4fd49c6a) | Preserve a common enum type through conditional expressions, including X/Z selection. |
| [#678](https://github.com/steveicarus/iverilog/issues/678) | [#56](https://github.com/apullin/aiverilog/issues/56), [PR #57](https://github.com/apullin/aiverilog/pull/57), [`9d5320cff`](https://github.com/apullin/aiverilog/commit/9d5320cff75cc9fde1b2062d70c54f5b3bd3b317) | Coalesce transient event propagation from atomic blocking vector assignments. A broad prototype with roughly 40% ordinary-fanout slowdown was rejected; the landed path is narrowly selected, leaves existing J-Core timing neutral, and passed all 12 CI jobs. NBA concatenations and unpacked-array word stores remain separate follow-ups. |
| [#1466](https://github.com/steveicarus/iverilog/issues/1466) | [PR #68](https://github.com/apullin/aiverilog/pull/68), repaired as [`728323077`](https://github.com/apullin/aiverilog/commit/728323077e2c184e387db51451d3bbbe7908b58d) | Guard only: propagate packed-index calculation failure so the non-ANSI unpacked-array port case receives a source diagnostic instead of aborting in `eval_part_select_`. Full support for the legal construct remains separate work. |
| [#1441](https://github.com/steveicarus/iverilog/issues/1441) | [PR #69](https://github.com/apullin/aiverilog/pull/69), replaced by [`b459ba79e`](https://github.com/apullin/aiverilog/commit/b459ba79ebafd46120dc14415fc42dac9cb1e781) | Carry explicit one-bit packed-vector identity through the VVP format and `__vpiSignal`, including nets, variables, aliases, and net-array words. VPI no longer guesses from a signal name or a collapsed range. |
| [PR #1773](https://github.com/steveicarus/iverilog/pull/1773) | [#135](https://github.com/apullin/aiverilog/issues/135), [PR #146](https://github.com/apullin/aiverilog/pull/146), [`707e57435`](https://github.com/apullin/aiverilog/commit/707e57435) | Upstream merged PR #1773 in [`27a70c82a`](https://github.com/steveicarus/iverilog/commit/27a70c82a); fork retains `unsigned char` high-byte (`>= 0x80`) sign-extension/UB hardening and test coverage in `string_const_vec_val.v`. |
| [#1706](https://github.com/steveicarus/iverilog/issues/1706) | [#136](https://github.com/apullin/aiverilog/issues/136), [PR #147](https://github.com/apullin/aiverilog/pull/147), [`660714c85`](https://github.com/apullin/aiverilog/commit/660714c85) | Upstream merged [PR #1740](https://github.com/steveicarus/iverilog/pull/1740) in [`ce6047a2b`](https://github.com/steveicarus/iverilog/commit/ce6047a2b); fork retains `"TE"` `vlog95` expectation in `br_gh1706.json` for `vvp_reg.py`. |
| [#1511](https://github.com/steveicarus/iverilog/issues/1511) | [#137](https://github.com/apullin/aiverilog/issues/137), [PR #148](https://github.com/apullin/aiverilog/pull/148), [`36b3c7f28`](https://github.com/apullin/aiverilog/commit/36b3c7f28) | Import [upstream PR #1515](https://github.com/steveicarus/iverilog/pull/1515): let single gates with mismatched output widths reach port-width diagnostics and report mixed-width gate arrays cleanly instead of asserting. |
| [#1586](https://github.com/steveicarus/iverilog/issues/1586) | [#138](https://github.com/apullin/aiverilog/issues/138), [PR #149](https://github.com/apullin/aiverilog/pull/149), [`b15de7e2c`](https://github.com/apullin/aiverilog/commit/b15de7e2c) | Share parsed `data_type_t` via `std::shared_ptr` across comma-separated class property declarations so module-scoped class destruction does not double-free. |
| [#1547](https://github.com/steveicarus/iverilog/issues/1547) | [#139](https://github.com/apullin/aiverilog/issues/139), [PR #150](https://github.com/apullin/aiverilog/pull/150), [`1f3e76e78`](https://github.com/apullin/aiverilog/commit/1f3e76e78) | Resize wider vector expressions to the queue element width across variable and class-property `push_back`, `push_front`, and `insert` code generation. |
| [#1551](https://github.com/steveicarus/iverilog/issues/1551) | [#140](https://github.com/apullin/aiverilog/issues/140), [PR #151](https://github.com/apullin/aiverilog/pull/151), [`cd7302675`](https://github.com/apullin/aiverilog/commit/cd7302675) | Diagnose null class handle property reads and writes at runtime and exit cleanly instead of aborting or segfaulting in `vthread.cc`. |
| [#1585](https://github.com/steveicarus/iverilog/issues/1585) | [#141](https://github.com/apullin/aiverilog/issues/141), [PR #152](https://github.com/apullin/aiverilog/pull/152), [`3cc990738`](https://github.com/apullin/aiverilog/commit/3cc990738) | Resolve object-handle method roots and pre-body return signals in `resolve_call_chain_prefix_class` and `PECallFunction::test_width_chain_`. |
| [#1545](https://github.com/steveicarus/iverilog/issues/1545) | [#156](https://github.com/apullin/aiverilog/issues/156), [PR #165](https://github.com/apullin/aiverilog/pull/165), [`4d29cf28d`](https://github.com/apullin/aiverilog/commit/4d29cf28d) | Swap `(rise_exp, fall_exp)` on the control `.delay` node for active-low `tranif0`/`rtranif0` so two-delay `#(d_on, d_off)` applies turn-on on control fall and turn-off on control rise. |
| [#1544](https://github.com/steveicarus/iverilog/issues/1544) | [#157](https://github.com/apullin/aiverilog/issues/157), [PR #166](https://github.com/apullin/aiverilog/pull/166), [`9e241921c`](https://github.com/apullin/aiverilog/commit/9e241921c) | Preserve drive strengths through `vvp_fun_part_sa`, `vvp_fun_part_aa`, and `vvp_fun_part_var_sa` (`recv_vec8`) and propagate strength awareness through `IVL_LPM_PART_VP` when its source nexus is strength-aware. |
| [#1552](https://github.com/steveicarus/iverilog/issues/1552) | [#158](https://github.com/apullin/aiverilog/issues/158), [PR #171](https://github.com/apullin/aiverilog/pull/171), [`b6f28fa51`](https://github.com/apullin/aiverilog/commit/b6f28fa51) | Return `'0` (instead of `'x`) for out-of-bounds and undefined-index reads of 2-state fixed-size unpacked arrays during constant folding and at runtime (`__vpiArray::get_word` and `of_LOAD_VEC4A`). |
| [#1574](https://github.com/steveicarus/iverilog/issues/1574) | [#159](https://github.com/apullin/aiverilog/issues/159), [PR #172](https://github.com/apullin/aiverilog/pull/172), [`397868299`](https://github.com/apullin/aiverilog/commit/397868299) | Part 2 (procedural unpacked-array copy; Part 1 constant `$clog2` was already fixed upstream): expose unpacked dimension ranges to target modules and copy elements in left-to-right dimension order in `draw_array_copy` (including string arrays and subroutine ports). |
| [#1061](https://github.com/steveicarus/iverilog/issues/1061) | [#163](https://github.com/apullin/aiverilog/issues/163), [PR #170](https://github.com/apullin/aiverilog/pull/170), [`7b36e5746`](https://github.com/apullin/aiverilog/commit/7b36e5746) | Allow combining `local`/`protected` and `virtual` qualifiers in any order on class methods (including `pure virtual`), while diagnosing conflicting qualifier combinations. |
| [#278](https://github.com/steveicarus/iverilog/issues/278) | [#164](https://github.com/apullin/aiverilog/issues/164), [PR #173](https://github.com/apullin/aiverilog/pull/173), [`4336d0edb`](https://github.com/apullin/aiverilog/commit/4336d0edb) | Support `-F <cmdfile>` on the `iverilog` CLI and inside command files, resolving relative source, library, include, and nested command-file paths against `<cmdfile>`'s directory. |
| [#1611](https://github.com/steveicarus/iverilog/issues/1611) | [#174](https://github.com/apullin/aiverilog/issues/174), [PR #183](https://github.com/apullin/aiverilog/pull/183), [`2de9a481b`](https://github.com/apullin/aiverilog/commit/2de9a481b) | Evaluate non-shift compound assignment RHS operands at `max(lval_width, rval_self_width)` with combined `(lhs && rhs)` signedness, and keep shift amounts self-determined. |
| [#1560](https://github.com/steveicarus/iverilog/issues/1560) | [#175](https://github.com/apullin/aiverilog/issues/175), [PR #186](https://github.com/apullin/aiverilog/pull/186), [`28e4dffb2`](https://github.com/apullin/aiverilog/commit/28e4dffb2) | Support reading and assigning members and bit/part-selects of packed-struct and packed-vector class properties via `%set/vec4`. |
| [#1564](https://github.com/steveicarus/iverilog/issues/1564) / [#1587](https://github.com/steveicarus/iverilog/issues/1587) | [#176](https://github.com/apullin/aiverilog/issues/176), [PR #192](https://github.com/apullin/aiverilog/pull/192), [`5e7735ff0`](https://github.com/apullin/aiverilog/commit/5e7735ff0) | Support bit-select, part-select, and indexed part-select reads and writes on dynamic-array and queue elements (including `[$]` and class queue/darray property reads). |
| [#416](https://github.com/steveicarus/iverilog/issues/416) | [#180](https://github.com/apullin/aiverilog/issues/180), [PR #185](https://github.com/apullin/aiverilog/pull/185), [`91b38d3ef`](https://github.com/apullin/aiverilog/commit/91b38d3ef) | Implement IEEE 1800-2017 §20.6.1 `$typename(expr_or_type)` as a side-effect-free compile-time string constant. |
| [#536](https://github.com/steveicarus/iverilog/issues/536) | [#182](https://github.com/apullin/aiverilog/issues/182), [PR #187](https://github.com/apullin/aiverilog/pull/187), [`40f7bef08`](https://github.com/apullin/aiverilog/commit/40f7bef08) | Support unpacked array slices (`arr[i]`, `arr[hi:lo]`, `arr[base +: wid]`, `arr[base -: wid]`) in blocking, nonblocking, assignment-pattern, and continuous assignments. |
| [#1092](https://github.com/steveicarus/iverilog/issues/1092) | [#179](https://github.com/apullin/aiverilog/issues/179), [PR #190](https://github.com/apullin/aiverilog/pull/190), [`9f00167ab`](https://github.com/apullin/aiverilog/commit/9f00167ab) | Implement IEEE 1800-2017 §11.4.13 `inside` expressions (wildcard `==?`, 4-state `1'bx`, `[lo:hi]`/`[$:hi]`/`[lo:$]` ranges, unpacked arrays, queues, dynamic arrays, reals, strings, continuous assignments, and `localparam`). |
| [#1759](https://github.com/steveicarus/iverilog/issues/1759) | [#181](https://github.com/apullin/aiverilog/issues/181), [PR #193](https://github.com/apullin/aiverilog/pull/193), [`2dffae282`](https://github.com/apullin/aiverilog/commit/2dffae282) | Extend dynamic `$cast(dest_var, source_expr)` (function and task forms, plus constant functions) to enumeration targets via `%cast/enum`. |

## Elided Or Already Present

These reports were reviewed, but retaining an Aiverilog patch would duplicate
upstream or existing behavior.

| Upstream report | Disposition |
| --- | --- |
| [#670](https://github.com/steveicarus/iverilog/issues/670) | Elided. Upstream's broader type-identifier grammar work in [PR #1439](https://github.com/steveicarus/iverilog/pull/1439) includes explicit `br_gh670` coverage. The old fork patch also broadened an unrelated grammar rule. |
| [#1217](https://github.com/steveicarus/iverilog/issues/1217) / [#1224](https://github.com/steveicarus/iverilog/issues/1224) | Elided. Upstream [PR #1367](https://github.com/steveicarus/iverilog/pull/1367) fixes both with equivalent regressions; the fork's old test-only commits were dropped. |
| [#1140](https://github.com/steveicarus/iverilog/issues/1140) | Superseded. Upstream [`591d2c247`](https://github.com/steveicarus/iverilog/commit/591d2c2473148777bc516694e3e6f15f4c75ca20) now provides `br_gh1140a/b/c` with `Dimensions must be a constant ...`; fork's `br_gh1140` phrasing and `br_gh1140_v` warning were unwound in [`2c098f871`](https://github.com/apullin/aiverilog/commit/2c098f87177cf3f4cd18f0d9785fccca70946751)/[`616095528`](https://github.com/apullin/aiverilog/commit/616095528436836be877743ca6e03ed5819ca7f7); `early_sig_elab3` gold also updated. |
| [#1449](https://github.com/steveicarus/iverilog/issues/1449) | Elided. Upstream [PR #1450](https://github.com/steveicarus/iverilog/pull/1450) ([`f4e997421`](https://github.com/steveicarus/iverilog/commit/f4e997421)) implements full unpacked-array parameters, constant-function returns, and subroutine ports, including `br_gh1449`. |
| [#1298](https://github.com/steveicarus/iverilog/issues/1298) / [#1459](https://github.com/steveicarus/iverilog/issues/1459) | Superseded in [`a3a1367d6`](https://github.com/apullin/aiverilog/commit/a3a1367d6) by upstream [`630a75551`](https://github.com/steveicarus/iverilog/commit/630a75551), [`dd5104451`](https://github.com/steveicarus/iverilog/commit/dd5104451), and [PR #1685](https://github.com/steveicarus/iverilog/pull/1685), which also handle `x`/`z` string conditional blending. |
| [#716](https://github.com/steveicarus/iverilog/issues/716) | Superseded in [`a3a1367d6`](https://github.com/apullin/aiverilog/commit/a3a1367d6) by upstream [`31eef61e8`](https://github.com/steveicarus/iverilog/commit/31eef61e8), which reports both actual and expected task output types. |
| [#1112](https://github.com/steveicarus/iverilog/issues/1112) | Superseded in [`a3a1367d6`](https://github.com/apullin/aiverilog/commit/a3a1367d6) by upstream [`fcc5c7bbe`](https://github.com/steveicarus/iverilog/commit/fcc5c7bbe), which validates `$bits()` operand data types (`br_gh1112a/b/c`). |
| [#1134](https://github.com/steveicarus/iverilog/issues/1134) | Superseded in [`a3a1367d6`](https://github.com/apullin/aiverilog/commit/a3a1367d6) by upstream [PR #1531](https://github.com/steveicarus/iverilog/pull/1531) and [`576cca651`](https://github.com/steveicarus/iverilog/commit/576cca651); `br_gh1134.v` retains dynamic/OOB read checks. |
| [#1268](https://github.com/steveicarus/iverilog/issues/1268) | Superseded in [`a3a1367d6`](https://github.com/apullin/aiverilog/commit/a3a1367d6) by upstream [`55f8ca242`](https://github.com/steveicarus/iverilog/commit/55f8ca242), which allows non-`tran` gate outputs on SV variables while rejecting bidirectional `tran` gates; `br_gh1268.v` retained alongside `br_gh1268a/b/c`. |
| [#1407](https://github.com/steveicarus/iverilog/issues/1407) | Superseded in [`a3a1367d6`](https://github.com/apullin/aiverilog/commit/a3a1367d6) by upstream [PR #1532](https://github.com/steveicarus/iverilog/pull/1532) ([`49b334ec8`](https://github.com/steveicarus/iverilog/commit/49b334ec8)). |
| [#1411](https://github.com/steveicarus/iverilog/issues/1411) | Superseded in [`a3a1367d6`](https://github.com/apullin/aiverilog/commit/a3a1367d6) by upstream [PR #1412](https://github.com/steveicarus/iverilog/pull/1412) ([`5ab23063f`](https://github.com/steveicarus/iverilog/commit/5ab23063f)); `br_gh1411.v` retained. |
| [#1128](https://github.com/steveicarus/iverilog/issues/1128) | Already present. VVP accepts `exit` as a prompt synonym for `finish`. |
| [#1194](https://github.com/steveicarus/iverilog/issues/1194) | No clear missing behavior after reviewing existing extended-argument support and documentation. No fork patch. |
| [#1513](https://github.com/steveicarus/iverilog/issues/1513) | Already present in [`a3a1367d6`](https://github.com/apullin/aiverilog/commit/a3a1367d6) via upstream [PR #1514](https://github.com/steveicarus/iverilog/pull/1514) ([`5591c2dde`](https://github.com/steveicarus/iverilog/commit/5591c2dde)). Both `bufif1` and real feedback-loop reproducers pass without stack overflow. |
| [#1546](https://github.com/steveicarus/iverilog/issues/1546) | Already present in [`a3a1367d6`](https://github.com/apullin/aiverilog/commit/a3a1367d6) via upstream [`576cca651`](https://github.com/steveicarus/iverilog/commit/576cca651) and [PR #1768](https://github.com/steveicarus/iverilog/pull/1768) ([`deaad9914`](https://github.com/steveicarus/iverilog/commit/deaad9914)). Both plain and compound member writes on unpacked arrays of packed structs pass. |
| [#413](https://github.com/steveicarus/iverilog/issues/413) | Already present (`ivtest/ivltests/br_gh413.v` in `regress-vvp.list`). |
| [#1213](https://github.com/steveicarus/iverilog/issues/1213) | Already present. `module a(output uwire o1 [0:1]); endmodule` compiles and runs cleanly without `ivl_signal_nex` assertion. |
| [#1230](https://github.com/steveicarus/iverilog/issues/1230) | Already present on current `master`. |

## Reviewed And Deferred

This is not an exhaustive copy of the upstream tracker. It records reports that
were investigated enough to make a deliberate no-patch decision or to identify
the next prerequisite.

| Upstream report | Current fork disposition |
| --- | --- |
| [PR #1406](https://github.com/steveicarus/iverilog/pull/1406) | Do not import as written: its second `fopen64` probe reuses the cached negative result, and the vendored `config.guess` change should be handled upstream. |
| [#1108](https://github.com/steveicarus/iverilog/issues/1108) | Reproduced in `vlog95`; a correct fix needs a narrow inherited-context dependency fingerprint to avoid specializing every descendant module. |
| [#1206](https://github.com/steveicarus/iverilog/issues/1206) | Deferred pending a precise policy for later source definitions overriding library definitions. |
| [#907](https://github.com/steveicarus/iverilog/issues/907) | Small implementation, unresolved public API choice for suppressing `$writemem*` address comments. |
| [#923](https://github.com/steveicarus/iverilog/issues/923) | Prototype dropped: a default warning changed many existing regression outputs for little value. Revisit only with an opt-in warning class or policy decision. |
| [#1233](https://github.com/steveicarus/iverilog/issues/1233) | `$readmem*` files are runtime inputs and cannot be made accurate compiler `-M` dependencies without a separate facility. |
| [#1284](https://github.com/steveicarus/iverilog/issues/1284) | Better `input reg` diagnostics depend on several language-generation cases; not a safe message-only edit. |
| [#1139](https://github.com/steveicarus/iverilog/issues/1139) | Undefined-package diagnostics are entangled with lexer/parser handling of type identifiers and packages. |
| [#1442](https://github.com/steveicarus/iverilog/issues/1442) | Still unsupported. Passing string parameters through an override cannot bind the source parameter, and concatenated string overrides still reach an unimplemented typed-expression path. PRs #70 and #73 only captured those failures and were removed from `master`; a real fix needs string-valued parameter expressions to elaborate in the override scope. |
| [#560](https://github.com/steveicarus/iverilog/issues/560) | Deep `tranif1` strength/storage semantics; not accepted as a quick patch. |
| [#449](https://github.com/steveicarus/iverilog/issues/449) | `$finish(2)` accounting needs a cross-platform definition of process and dump-thread resource reporting. |
| [#284](https://github.com/steveicarus/iverilog/issues/284) | Large numeric module attributes require a target-API representation decision beyond native `long`. |
| [#1543](https://github.com/steveicarus/iverilog/issues/1543) / [#1561](https://github.com/steveicarus/iverilog/issues/1561) | Fixed-size unpacked-array class properties currently have incomplete target/runtime representation (`vvp_cobject` only indexes object-handle arrays, and `tgt-vvp` emits scalar property metadata for vector/real/string unpacked arrays). Needs coordinated `ivl_target`, `tgt-vvp`, and `vvp_cobject` support. |
| [#1705](https://github.com/steveicarus/iverilog/issues/1705) | Whole-container nonblocking assignments to queues and dynamic arrays require a dedicated `%assign/obj` NBA scheduler path with container deep-copy semantics; reporter noted an upstream patch in progress. |
| [#1196](https://github.com/steveicarus/iverilog/issues/1196) | Deferred ([#189](https://github.com/apullin/aiverilog/issues/189) / [PR #191](https://github.com/apullin/aiverilog/pull/191)): existing upstream regression `ivtest/ivltests/signed_a.v:21` (`b[120] = 1'b1; // This should be stripped!`) explicitly requires 32-bit index stripping on `&A<>`. |

## Fork Work Not Derived From Upstream Issues

Upstream reconciliation must also preserve fork-native work that has no issue
number to match:

- The sanitizer-driven correctness audit between
  [`593fce299...ba3413374`](https://github.com/apullin/aiverilog/compare/593fce299eb3ed17aa6234d680a8133a4b878ec3...ba34133749a128f8cdd790dfc3bba191a4f92235)
  hardens command-file ingestion, VPI formatting and scanning, vector
  conversions, arithmetic, and unsupported parser paths.
- [PR #23](https://github.com/apullin/aiverilog/pull/23) is the profile-first
  performance campaign, including benchmark oracles and the optimized build
  harness.
- [PR #26](https://github.com/apullin/aiverilog/pull/26) adds the separately
  measured constant nonblocking-assignment fusion left after PR #23, followed
  by the August–September 2026 VVP/elaborator performance series through
  [PR #133](https://github.com/apullin/aiverilog/pull/133).
- Post-sync correctness audit fixes in November 2026:
  [#142](https://github.com/apullin/aiverilog/issues/142) / [PR #145](https://github.com/apullin/aiverilog/pull/145) ([`a7af0903b`](https://github.com/apullin/aiverilog/commit/a7af0903b), `ICARUS_VPI_CONST` function-type UBSan fix in `ivl`),
  [#143](https://github.com/apullin/aiverilog/issues/143) / [PR #153](https://github.com/apullin/aiverilog/pull/153) ([`c35c1d647`](https://github.com/apullin/aiverilog/commit/c35c1d647), unpacked-array of packed-array of packed-struct l-value index stripping),
  [#144](https://github.com/apullin/aiverilog/issues/144) / [PR #154](https://github.com/apullin/aiverilog/pull/154) ([`3bf4ccb85`](https://github.com/apullin/aiverilog/commit/3bf4ccb85), dynamic-array `new[N](init)` elementary variable assertion and 6-bit offset truncation fix),
  [#160](https://github.com/apullin/aiverilog/issues/160) / [PR #167](https://github.com/apullin/aiverilog/pull/167) ([`ee0d5e679`](https://github.com/apullin/aiverilog/commit/ee0d5e679), constant `string.getc()` 64-bit index segfault, byte width, raw parameter string unescaping, and `<ctype.h>` `unsigned char` UB),
  [#161](https://github.com/apullin/aiverilog/issues/161) / [PR #168](https://github.com/apullin/aiverilog/pull/168) ([`8814bf273`](https://github.com/apullin/aiverilog/commit/8814bf273), out-of-bounds read on allocated-but-empty queue dereferencing `queue[0]`),
  [#162](https://github.com/apullin/aiverilog/issues/162) / [PR #169](https://github.com/apullin/aiverilog/pull/169) ([`370a4f863`](https://github.com/apullin/aiverilog/commit/370a4f863), pre/post `++`/`--` expressions in constant functions and unpacked-array words in `tgt-vvp`),
  [#177](https://github.com/apullin/aiverilog/issues/177) / [PR #184](https://github.com/apullin/aiverilog/pull/184) ([`05aa22fb8`](https://github.com/apullin/aiverilog/commit/05aa22fb8), signed comparison in queue/darray `sort()`, `rsort()`, `min()`, and `max()`), and
  [#178](https://github.com/apullin/aiverilog/issues/178) / [PR #188](https://github.com/apullin/aiverilog/pull/188) ([`dfb7bc429`](https://github.com/apullin/aiverilog/commit/dfb7bc429), compile-time and runtime diagnostics for negative or X/Z `new[n]` dynamic-array sizes).
- Differential, sanitizer, and mutational fuzzing campaign fixes in November 2026
  (31 upstream-copyable fork issues and PRs across Waves 1–4):
  [#195](https://github.com/apullin/aiverilog/issues/195) / [PR #199](https://github.com/apullin/aiverilog/pull/199) ([`9f10a4849`](https://github.com/apullin/aiverilog/commit/9f10a4849), >64-bit `vvp_vector2_t` `div_mod` MSB mask overflow),
  [#196](https://github.com/apullin/aiverilog/issues/196) / [PR #200](https://github.com/apullin/aiverilog/pull/200) ([`319b94620`](https://github.com/apullin/aiverilog/commit/319b94620), `delete[]` vs `free()` in `compile_darray_port`),
  [#197](https://github.com/apullin/aiverilog/issues/197) / [PR #201](https://github.com/apullin/aiverilog/pull/201) ([`c76b27300`](https://github.com/apullin/aiverilog/commit/c76b27300), non-power-of-two signed 2-state `bit` class properties `sb<N>`),
  [#198](https://github.com/apullin/aiverilog/issues/198) / [PR #202](https://github.com/apullin/aiverilog/pull/202) ([`25061fe67`](https://github.com/apullin/aiverilog/commit/25061fe67), avoid duplicate `CLASS` scope/method emission in `NetScope`),
  [#203](https://github.com/apullin/aiverilog/issues/203) / [PR #215](https://github.com/apullin/aiverilog/pull/215) ([`705f8e6dc`](https://github.com/apullin/aiverilog/commit/705f8e6dc), VPI `&PV<>`/`&APV<>` `vpiObjTypeVal`, OOB bounds, 2-state `'0` padding, and shift UB),
  [#204](https://github.com/apullin/aiverilog/issues/204) / [PR #216](https://github.com/apullin/aiverilog/pull/216) ([`aee795767`](https://github.com/apullin/aiverilog/commit/aee795767), `'0` on OOB/undefined selects of 2-state packed vectors),
  [#205](https://github.com/apullin/aiverilog/issues/205) / [PR #217](https://github.com/apullin/aiverilog/pull/217) ([`04979c1c7`](https://github.com/apullin/aiverilog/commit/04979c1c7), `tgt-blif` aliased output ports, wide XOR/XNOR reductions, and shift UB),
  [#206](https://github.com/apullin/aiverilog/issues/206) / [PR #218](https://github.com/apullin/aiverilog/pull/218) ([`10e2cca8b`](https://github.com/apullin/aiverilog/commit/10e2cca8b), bit/part-selects and width check on timing-check delayed signals),
  [#207](https://github.com/apullin/aiverilog/issues/207) / [PR #219](https://github.com/apullin/aiverilog/pull/219) ([`5a5482db2`](https://github.com/apullin/aiverilog/commit/5a5482db2), `NetESelect::expr_type` element base type for queues and darrays),
  [#208](https://github.com/apullin/aiverilog/issues/208) / [PR #220](https://github.com/apullin/aiverilog/pull/220) ([`53ad36e54`](https://github.com/apullin/aiverilog/commit/53ad36e54), constant-function uninitialized compound assigns and 2-state `NaN`/`X` casts),
  [#209](https://github.com/apullin/aiverilog/issues/209) / [PR #221](https://github.com/apullin/aiverilog/pull/221) ([`13d50609c`](https://github.com/apullin/aiverilog/commit/13d50609c), `+:`/`-:` part-select l-values on packed struct/union members),
  [#210](https://github.com/apullin/aiverilog/issues/210) / [PR #222](https://github.com/apullin/aiverilog/pull/222) ([`9ca9b3e49`](https://github.com/apullin/aiverilog/commit/9ca9b3e49), signed shift UB in `tgt-vlog95`/`sys_time` and null `userdata` guard in `sys_convert`),
  [#211](https://github.com/apullin/aiverilog/issues/211) / [PR #223](https://github.com/apullin/aiverilog/pull/223) ([`f67280906`](https://github.com/apullin/aiverilog/commit/f67280906), 32-bit word-count overflow in `vvp_vector4_t` and signed range overflow in `vvp`),
  [#212](https://github.com/apullin/aiverilog/issues/212) / [PR #224](https://github.com/apullin/aiverilog/pull/224) ([`3bfd23c60`](https://github.com/apullin/aiverilog/commit/3bfd23c60), `specify` path error-recovery segfault, scope unwinding, and UDP guards),
  [#213](https://github.com/apullin/aiverilog/issues/213) / [PR #225](https://github.com/apullin/aiverilog/pull/225) ([`242f808bc`](https://github.com/apullin/aiverilog/commit/242f808bc), cfunc struct/union reads, class prop methods/slices, locator iterators, and object arrays),
  [#214](https://github.com/apullin/aiverilog/issues/214) / [PR #226](https://github.com/apullin/aiverilog/pull/226) ([`2ee1052df`](https://github.com/apullin/aiverilog/commit/2ee1052df), oversized dimensions, `darray` allocations, cfunc recursion, and error recovery),
  [#227](https://github.com/apullin/aiverilog/issues/227) / [PR #231](https://github.com/apullin/aiverilog/pull/231) ([`7f8d84e8d`](https://github.com/apullin/aiverilog/commit/7f8d84e8d), element type equivalence check in dynamic-array and queue assignments),
  [#228](https://github.com/apullin/aiverilog/issues/228) / [PR #232](https://github.com/apullin/aiverilog/pull/232) ([`844cdad91`](https://github.com/apullin/aiverilog/commit/844cdad91), `$readmemh` shift UB, `vthread` flags/words init, and `vector4_from_text` bounds),
  [#229](https://github.com/apullin/aiverilog/issues/229) / [PR #233](https://github.com/apullin/aiverilog/pull/233) ([`9414f1e7c`](https://github.com/apullin/aiverilog/commit/9414f1e7c), out-of-range port part-select diagnostic and null concatenated subport guard),
  [#230](https://github.com/apullin/aiverilog/issues/230) / [PR #234](https://github.com/apullin/aiverilog/pull/234) ([`ca6a7b0a0`](https://github.com/apullin/aiverilog/commit/ca6a7b0a0), parser error recovery for constructors, `for`-loops, functions, classes, and `modport`s),
  [#236](https://github.com/apullin/aiverilog/issues/236) / [PR #246](https://github.com/apullin/aiverilog/pull/246) ([`302bc4f3c`](https://github.com/apullin/aiverilog/commit/302bc4f3c), exact type/sign/width/bit comparison for parameterized class value parameters),
  [#237](https://github.com/apullin/aiverilog/issues/237) / [PR #247](https://github.com/apullin/aiverilog/pull/247) ([`ee229dd4d`](https://github.com/apullin/aiverilog/commit/ee229dd4d), class properties, slices, and queue/darray elements in arbitrary l-value concatenation positions),
  [#238](https://github.com/apullin/aiverilog/issues/238) / [PR #252](https://github.com/apullin/aiverilog/pull/252) ([`b8c5708eb`](https://github.com/apullin/aiverilog/commit/b8c5708eb), elaborate named packages before `$unit` and preserve scoped type `lexical_pos`),
  [#239](https://github.com/apullin/aiverilog/issues/239) / [PR #253](https://github.com/apullin/aiverilog/pull/253) ([`8ef46ff1b`](https://github.com/apullin/aiverilog/commit/8ef46ff1b), enforce `const`/`const ref` across class properties, mutating container methods, `$cast`, `extern`s, and virtual overrides),
  [#240](https://github.com/apullin/aiverilog/issues/240) / [PR #248](https://github.com/apullin/aiverilog/pull/248) ([`4bc9faa62`](https://github.com/apullin/aiverilog/commit/4bc9faa62), non-string VPI `vpi_put_value` formats on `string` variables and empty `%u`/`%z` targets),
  [#241](https://github.com/apullin/aiverilog/issues/241) / [PR #249](https://github.com/apullin/aiverilog/pull/249) ([`499416283`](https://github.com/apullin/aiverilog/commit/499416283), undefined-index l-value select on non-zero-based packed arrays and post-error synth guards),
  [#242](https://github.com/apullin/aiverilog/issues/242) / [PR #250](https://github.com/apullin/aiverilog/pull/250) ([`9303c9b5f`](https://github.com/apullin/aiverilog/commit/9303c9b5f), clamp non-zero `ivl`/`ivlpp` exit codes to avoid modulo-256 `0` exit on 256 errors),
  [#243](https://github.com/apullin/aiverilog/issues/243) / [PR #254](https://github.com/apullin/aiverilog/pull/254) ([`ba51837e9`](https://github.com/apullin/aiverilog/commit/ba51837e9), `` `line `` `INT_MAX` saturating line counter and nested/untyped class diagnostics),
  [#244](https://github.com/apullin/aiverilog/issues/244) / [PR #255](https://github.com/apullin/aiverilog/pull/255) ([`cbffbf137`](https://github.com/apullin/aiverilog/commit/cbffbf137), `tgt-stub` type parameters and `tgt-blif` non-vector constant, multi-packed-dim, and `part_vp` fixes),
  [#245](https://github.com/apullin/aiverilog/issues/245) / [PR #256](https://github.com/apullin/aiverilog/pull/256) ([`58af0ec80`](https://github.com/apullin/aiverilog/commit/58af0ec80), `tgt-vhdl` 1-bit `[0:0]` resize OOB read, signed shift UB, nested `generate` loop, and `tgt-pcb` multi-word guard), and
  [#251](https://github.com/apullin/aiverilog/issues/251) / [PR #257](https://github.com/apullin/aiverilog/pull/257) ([`e749ca7db`](https://github.com/apullin/aiverilog/commit/e749ca7db), constant-function `string` variables/returns and built-in string methods).

These changes should be compared semantically against incoming upstream work;
the absence of a matching upstream issue number is not evidence that they can
be discarded.

## Pull Request Boundaries

Keep upstream-compatible work easy to inspect and easy to exchange:

- If a fix maps one-to-one, or nearly one-to-one, to an upstream issue or
  commit, land it as its own minimal fork PR. Preserve original authorship and
  identify the upstream source when importing an existing patch.
- Combine reports only when they demonstrably share one cause and one code
  path, and splitting the implementation would be artificial.
- Keep fork organization, harness work, broad cleanups, and structural
  refactors out of those fix PRs. Such work belongs in a separate, explicitly
  scoped major PR with its own validation and review story.

This separation keeps small fixes candidates for upstream exchange even when
the larger Aiverilog organization or architecture intentionally diverges.

## Reconciliation Procedure

For new upstream-derived work:

1. Fetch upstream before reproducing the report, and test against the current
   combined `master`.
2. Create a fork issue only after the report is reproduced and a bounded fix is
   accepted.
3. Put both upstream and fork issue URLs in the implementation commit; keep one
   logical issue per commit unless two warnings share one cause and code path.
4. Require a focused regression, complete local suites, and the fork's full CI
   matrix before merging.
5. Add or update the corresponding row here only after the fork PR merges.

For a new upstream sync:

1. Inventory every incoming upstream commit and compare overlapping paths with
   retained fork deltas in this ledger.
2. Run focused fork regressions against pure upstream when an incoming change
   might supersede a row.
3. Keep useful regressions even if upstream independently supplies an
   equivalent implementation.
4. Merge upstream normally. Do not rewrite published fork history except for an
   explicitly authorized repair; preserve the old tip and document the rewrite.
5. Run complete functional suites and performance output oracles, then update
   the integrated upstream hash and any newly elided rows above.
