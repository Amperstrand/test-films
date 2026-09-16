# 10 — Spec-quote anchoring (and drift detection)

## What

Verbatim spec quotes embedded in source-code comments, checked
mechanically against a pinned spec corpus, so that when the spec
changes, the comments (and the requirements they claim to implement)
do not silently drift.
In films, the same anchors become the senior layer's citations and
the checker's ground truth.

## Why

- **Docs that lie are worse than no docs.**
  A film's senior layer without verbatim anchors is an opinion; with
  anchors, it is checkable — and the check runs in CI next to the
  tests.
- Requirement claims live in three places (spec, code, explanation);
  quote-anchoring makes all three mechanically identical or loudly
  different.
- The technique generalizes past protocol specs: standards, RFCs,
  BIP-class documents, or a single `SPECIFICATION.md` in your own
  repo.

## The mechanism (what any implementation must provide)

This repo describes the INTERFACE; vendor or adapt a verifier that
provides it.
(When vendoring, strip origin identity — see AGENTS.md.)

### 1. The quote comment

```c
/* SPEC #2/Reader Requirements: A reader:
 *  - MUST fail parsing if the length is wrong.
 */
```

Marker grammar:

```text
<MARKER>[-<commit>][ #<id>][/<section-hint>]: <quoted text>
```

- `MARKER` — the source's comment marker (a short tag you choose).
- `-<commit>` — optional draft-spec convention: the line parses only
  when that commit prefix is enabled, letting a branch quote an
  unmerged spec change.
- `#<id>` — selects the document for multi-file sources.
- `/section-hint` — restricts matching to sections whose header
  contains the text.
  Near-identical wording across sections (Reader vs Writer
  requirements) silently matches the WRONG one without it.
- `...` inside a quote is a wildcard; a leading `...` means "must
  immediately follow the previous quote from this source in this
  file" — splitting one long requirement across several comment
  sites.
- An aside prefix (e.g., `* Note:`) lets commentary live inside the
  block without being checked.

### 2. The corpus pin

A per-repo config names each spec source and where the pinned
checkout lives:

```toml
[sources.main-spec]
format = "markdown"          # header-split documents
file = "SPECIFICATION.md"

[sources.rfc]
format = "rfc-text"          # classic RFC layout; strips page
dir = "/usr/share/doc/RFC/standard"   # furniture so page-spanning
pattern = "rfc{id}.txt.gz"            # requirements read as one
```

Two pin layers, both required:

- **Git pins** for checkouts (submodule, sibling clone, or package)
  — recorded in the manifest.
- **Hash manifests** (sha256 per file) for archives that lack a git
  identity — mailing-list threads, PDFs, exported docs.
  A corpus pinned only "by convention" is unpinned.

### 3. The check

- Normalized matching by default (whitespace runs collapse;
  wrapping differences do not matter); exact mode when bytes matter.
- Exit 0 = every quote found verbatim; exit 1 = `file:line:message`
  per failure — machine-scrapable, editor-jumpable.
- Near-match notes: when a quote fails, look for spec text that is
  merely SIMILAR and print a gcc-style `note:` pointing at it
  (wording drifted rather than vanished).
  Best-effort, deterministic, never affects pass/fail.

### 4. Coverage (the gap detector)

Annotate every line of the spec corpus with one of three statuses:

- **covered** — at least one quote's match touches this line.
- **gap** — nothing quotes this line but it is expected to be quoted
  (normative): a requirement nothing implements.
- **neutral** — prose, headers, examples; never flagged.

"Expected to be quoted" comes from either declared normative spans
(precise; generated once by an LLM or by hand for short documents)
or RFC-2119/8174 keyword detection (all-caps MUST/SHOULD/...,
case-sensitive on purpose — plain-English "must" stays quiet).

Coverage exits 1 on any gap.
Text and HTML renderings serve human review; JSON serves CI.

### 5. Tamper detection

A test rail re-verifies the corpus itself: regenerate from pins and
compare, so a corpus edited in place (accidentally or otherwise)
fails instead of silently re-authorizing drifted quotes.

## Quote packs for films

A film's senior layer cites a QUOTE PACK: the corpus quotes the
manuscript uses, built from `anchors.toml` (quote id → source +
locator) with a build script that regenerates the pack from pins.

- The manuscript cites quote ids; the checker resolves them against
  the pack; the pack rebuilds from the pins.
  Three layers, all mechanical.
- Multi-source packs are normal: the merged spec, the reference
  implementation's comments, and archived list threads — each with
  its own pin style (git / hash manifest).

## CI wiring

- `spec-quotes` job on every push: verifier over the tree + corpus;
  FAIL is a finding (quote or pin drifted) — never silence it; bump
  pins deliberately, in their own commit, with the reason.
- Coverage as a periodic job (weekly cadence fits most corpsuses);
  new gaps are backlog items, not build breakers — UNLESS the gap
  sits in a section your film claims to cover.

## Pitfalls

- Quotes that paraphrase.
  The whole value is verbatim; a paraphrase passes human review and
  fails the machine — correctly.
- Missing section-hints where two sections share wording — the
  silent-wrong-match failure the hint exists for.
- One mega-source for unrelated specs — per-source tables keep
  markers and pins honest.
- Forgetting the aside prefix and padding commentary into "quotes"
  that then fail — commentary is fine, mark it.
- Trusting keyword-based "normative" guesses on specs that do not
  follow RFC-2119 conventions — declare spans instead.

## References

- [02-audiences.md](02-audiences.md) — where the anchors land (the
  senior layer).
- [03-manuscript.md](03-manuscript.md) — the manuscript checker
  resolves quote refs through the pack.
- [09-make-and-ci.md](09-make-and-ci.md) — the CI job.
