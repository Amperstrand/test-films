# AGENTS.md — operating rules for AI agents working in THIS repo

This file is for AI agents working on this repository itself.
Humans should read [README.md](README.md) first.

## What this repo is

A standalone knowledge base for the test-films practice.
It contains documentation, templates, prompts, and sanitized examples.
It deliberately contains no coupling to any product code.

## The anonymity law (binding)

This repository NEVER mentions the names of other projects —
especially private ones.
Every lesson here was earned somewhere else and lifted in.

When adding or editing content:

1. No project names, package names, or repository identifiers from any
   source project.
2. No GitHub org names, org URLs, or `owner/repo` strings.
3. No internal hostnames, IP addresses, domains, or account numbers.
4. No commit SHAs, issue numbers, or PR numbers from source projects.
5. Refer to systems generically: "a router test rig", "the signer
   service", "a two-party protocol", "the transcription worker".
6. Public, upstream, open-source tool names are fine (Playwright,
  ffmpeg, faster-whisper, Perfetto, mermaid, pytest). Public open
  protocols are fine when referenced by their public spec names.
7. Before committing, grep the diff for every name on the local
   blacklist (see "Sanitization check" below).

When vendoring a tool (a spec-quote verifier, a publisher script,
a segmentation module):

- Strip its origin identity from code, docs, and metadata.
- Rename imports and CLI entry points to neutral names.
- Parameterize anything project-specific (domains, account IDs,
  database names, credentials) into placeholders.
- Add the vendored copy's provenance to your session notes, never to
  this repo.

## Sanitization check (run before every commit)

Maintain a local, non-committed blacklist file (for example
`~/.test-films-blacklist`, one pattern per line — build it from the
directory listing of your source workspace plus org and domain names).

```bash
git diff --cached | grep -iEf ~/.test-films-blacklist && echo "LEAK: fix before committing" && exit 1
```

Exit non-zero on any hit.
A leak into a private repo is bad; a leak that later crosses into a
public surface is an incident.

## Content conventions

Follow the house style, inherited from the knowledge bases this repo
was distilled from:

- **Semantic line breaks**: one sentence per line in Markdown source.
  Diffs stay readable; merges stay easy.
- **Structure for pattern docs**: What / Why / How / Pitfalls /
  References.
- **Structure for prompts**: ROLE / OBJECTIVE / PROCESS / OUTPUT
  FORMAT / QUALITY BAR.
- **Tables** for structured data. **Numbered lists** for sequences.
  **Bullets** for unordered sets.
- **Code blocks** always carry a language tag.
- **Relative links** for internal navigation; never absolute paths,
  never external URLs where a relative path works.
- **Active voice, present tense.** "The runner captures the video" —
  not "the video will be captured".

### Forbidden words

comprehensive, robust, powerful, leverage, utilize, delve, dive deep,
seamlessly, in order to, it's worth noting, it should be noted,
please note, simply, just (as filler)

### Forbidden patterns

- Emojis.
- "TODO", "stub", "placeholder", "coming soon" — every file is fully
  written, including examples.
- Marketing language ("amazing", "industry-leading", "best-in-class").
- AI filler intros ("In today's rapidly evolving landscape...").
- Unverifiable claims. Every lesson states what was observed, not what
  is assumed.

## How to add a lesson

1. One lesson = one mechanism = one numbered entry in
   [docs/lessons-learned.md](docs/lessons-learned.md).
2. Each entry carries: the rule (imperative), the mechanism (why it is
   true), and the failure that earned it (genericized).
3. Sanitize per the anonymity law.
4. If the lesson changes how a doc works, update that doc in the same
   commit.

## How to add a template or prompt

1. Templates are copy-paste starters: parameterized, no hardcoded
   values, `<<PLACEHOLDER>>` marks the blanks.
2. Prompts follow the ROLE/OBJECTIVE/PROCESS/OUTPUT FORMAT/QUALITY BAR
   structure and are tested against a real target before merging.
3. Add the entry row to the README's repository map in the same
   commit.

## Git discipline

- Small, atomic commits; imperative subject lines.
- Never commit run outputs, recordings, or generated artifacts
  (`.gitignore` covers them).
- The sanitization check gates every commit.
