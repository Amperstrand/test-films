# AGENTS.md — operating rules for AI agents working in THIS repo

This file is for AI agents working on this repository itself.
Humans should read [README.md](README.md) first.

## What this repo is

A standalone knowledge base for the test-films practice.
It contains documentation, templates, prompts, and sanitized examples.
It deliberately contains no coupling to any product code.

## Project references (owner directive 2026-09-20)

The anonymity law is scrapped: content in this repo may name the
projects it came from. Per-project demo prompts belong in their own
repositories, next to the code they film; this repo holds the
reusable components and sample prompts. Two rules survive:

1. Never commit secrets, credentials, tokens, or private hostnames.
2. Phrasing that travels beats phrasing that points: generic wording
   keeps a lesson usable by projects that are not the source.

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
3. Name the source project when it helps; never include secrets or private hostnames.
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
- The staged diff carries no secrets, credentials, or private hostnames.
