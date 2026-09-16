# Lessons learned — the master list

Every entry: the rule, the mechanism, and the failure class that
earned it.
Sources are genericized per the anonymity law (AGENTS.md).

## Manuscript and audiences

1. **Write the shallow layer first, finalize it last.**
   You cannot produce a correct ELI5 of a mechanism you do not
   understand; incomprehension surfaces at the shallow layer.
   The earned case: approvals granted on assumed comprehension went
   wrong; requiring the requester to explain back at ELI5 level
   (own words, zero jargon) before consequential actions converted
   assumption into verification.
2. **Layered summaries must be standalone.**
   "See section X" language breaks progressive disclosure; the
   pointer becomes structured evidence below the answer.
   A reader who stops at any layer still holds a correct
   understanding.
3. **Evidence entries carry concrete results, not paths.**
   `kind: cell` (a matrix result), `kind: source` (file:line cite),
   `kind: lineage` (build/test arm) — each with its locator.
   A bare path is a promise the reader cannot cash.
4. **Retract claims everywhere they live, same session.**
   A correction landed in an open-questions section while the ELI5
   and junior summaries still carried the retracted sentence a day
   later — caught only in a pre-publication grep.
   Before publishing any copy: grep it for every known-retracted
   claim.
5. **Keep refuted text visible, struck through, with the why.**
   Silent edits destroy auditability; `replaces:` pointers keep the
   record honest.
6. **S0 first; one deviation per scenario.**
   The happy-path film is the baseline every other film is defined
   against; two deviations in one page is two films stapled together.
7. **Generated diagrams beat hand-drawn ones.**
   A sequence diagram generated from the merged timeline cannot
   disagree with the run.
   Hand-drawn diagrams drift silently with every code change.
8. **Prove the space, don't sample it.**
   `tolerate(x); tolerate(y)` is not `tolerate(x|y)*`: two sequential
   one-shot tolerances passed days of loaded-box testing and died on
   the first quiet-box back-to-back delivery.
   Enumerate the interleaving alphabet exhaustively; film the
   enumeration.

## Sync (narration and timelines)

9. **Narrate decisions and their inputs, not messages.**
   Wire-level logs are bookkeeping soup; the decision is what a
   reader (junior, senior, or LLM) needs at each branch.
   A line that does not answer "why this branch" gets cut.
10. **Keep the event vocabulary closed (~10–13 events).**
    Vocabulary sprawl is a state-machine change wearing a logging
    patch; review it as one.
11. **Ship a legacy parser.**
    Map pre-narration log lines onto the same event set so all
    banked historical evidence becomes timeline input retroactively.
12. **Merge on comparable clocks; anchor before you trust order.**
    Cross-host sub-second ordering is advisory unless lanes were
    anchored by an exchange at run start.
13. **Multi-wait log assertions consume chronologically.**
    Frameworks keep a monotonic cursor per log; a line written before
    the cursor position can never match.
    Sequence waits in log order or use one late catch-all.
14. **Attribute log output by mtime and process table, not content.**
    A stale shared log path read as live evidence cost a triage
    round; `stat` the artifact first.
15. **One gate at a time on shared paths.**
    Gate logs and temp dirs are overwritten per run; concurrent
    sessions destroy each other's evidence.
16. **A reap at bound B proves only "slower than B".**
    Timeout exit codes under load or under-sized bounds are
    artifacts, not verdicts.
    Verdict columns come from the test runner's own reported line.
17. **Drivers read their own artifacts.**
    Grep a per-pid runlog, never a shared symlink another run is
    rewriting.
18. **Regime incomplementarity.**
    A slow loaded box scrambles timing; a quiet fast box delivers
    adjacent orderings; neither regime's coverage contains the
    other's.
    Interleaving-sensitive "tested" claims need both regimes.
19. **Keep the healthy-run detector on.**
    A missing narration site was caught only because the healthy-run
    detector flagged a false NO_CONVERGENCE — the layer debugging
    itself.
20. **Believes-columns are the split-brain lens.**
    Step tables carrying "what each participant believes" turn
    two-views-diverge bugs into a readable row.

## Footage and storage

21. **Prune static videos.**
    Most calm-UI videos are visually identical frame to frame;
    scale to 160x90, diff consecutive frames, delete below
    threshold — storage and attention both survive.
22. **Optional dependencies never disrupt reporting.**
    Missing ffmpeg ⇒ assume static and move on; a missing optional
    tool must not fail the test report.
23. **Save everything; truncate only the display.**
    Display-side truncation (`| head` on the capture) destroyed the
    settle verdict while the money moved fine.
    Capture to file first; format at print.
24. **Bank failing-run evidence before anything else.**
    The next gate destroys the logs; the decode window closes at the
    next cleanup.
25. **Ephemeral machines carry their own exfiltration.**
    An independent watcher fires on any exit (including kill -9) and
    ships the run dirs immediately; "read it out later" on a
    reapable box is a data-loss plan.
26. **Retention windows, not instant deletion.**
    Keep a 24h review window so failures stay steppable-through;
    degrade on disk floors.
27. **Artifact storage is metered.**
    An unpaid storage overage froze org Actions while every policy
    page read "enabled" — org retention ≤7 days, per-workflow
    `retention-days` low, publish-not-store for keepers.
28. **Budget artifacts like spend.**
    Runs/month × videos-kept/run × average size, checked against the
    free tier BEFORE enabling capture-by-default.
29. **Every published file entry carries an explicit MIME type.**
    Content-addressed URLs have no extensions; without `mime` every
    dashboard classifies footage as octet-stream and renders nothing.
30. **Publishing is an environment capability, not a decision.**
    A `can_publish` flag per environment: ephemeral cloud labs
    publish; local and physical environments (real SSIDs, MACs, IPs,
    keys) never do.
31. **Cap report embeds.**
    Base64 inflates by a third; oversized embedded video stops the
    report from loading — cap and link the rest.
32. **Pair screenshots with machine state.**
    The state-machine value at capture time lets checkers validate
    what the eye sees and dashboards group correctly.
33. **Re-run-safe drivers wipe what they own.**
    A clone into an existing tree fails instantly and masquerades as
    a network error.
34. **Never edit a runner script while an instance is running.**
    Incremental shell readers die mid-file.

## Voice

35. **Prefilter before transcribing.**
    A voice-activity gate on long recordings is the difference
    between minutes and hours of GPU time for identical output.
36. **Emit gradepacks, not one file.**
    Accurate (verbatim, timestamps) for evidence; llm-ready
    (normalized) for model consumption; consumers differ.
37. **Batch jobs are queues with completion markers.**
    In-memory loops re-transcribe everything after a restart.
38. **Cache by content hash plus model tier.**
    The same audio must never pay twice.
39. **Declare the model tier and voice settings in the manifest.**
    A transcript's accuracy claims and a voice-over's
    regenerability depend on them.
40. **Per-scene voice clips, never one long take.**
    Re-cutting a scene stays independent of every other scene.
41. **Speak state during hands-busy procedures.**
    OS speech on the runner's state transitions converts a 3-minute
    stare into an eyes-free procedure; narration events make it
    nearly free.

## Cutting, overlays, dashboards

42. **The cut list is generated from the timeline.**
    Hand-edited reels drift from runs; the scene list is text, in
    the run directory, regenerable in CI.
43. **Label time-compression and synthetic scenes.**
    Films that hide cuts lose the trust that makes them evidence.
44. **Question-anchored segmentation for dialogue sources.**
    Anchor scenes to the questions being worked; rebalance
    interleaved fragments to the nearest preceding anchor.
45. **Every chart and diagram carries its generator.**
    A chart that cannot be regenerated is a decoration.
46. **Structured index events, blobs in blob storage.**
    Messages/indexes stay small and machine-readable (counts, file
    list with mime + sha256); evidence blobs live content-addressed,
    mirrored ≥2.
    Blobs inside index events break every consumer.

## Make, CI, and gates

47. **Make is a menu; the registry is truth.**
    Thin stubs over the real runner, mapping in a registry file CI
    also reads — two sources of truth for "what ran" is how rigs
    rot.
48. **Timeouts wrap binaries, never shell functions.**
    The wrapped function "fails" instantly and silently — twice
    earned.
49. **Wedged tests fail, they do not hang.**
    Per-test timeout plugins plus a run wall clock with a terminal
    marker convert silent CI hangs into red builds.
50. **Expected-fail phases check the failure signature.**
    And an expected-fail that PASSES dies loudly — behavior changed.
51. **Flake retries are a ledger.**
    Retry once on a named signature; persisted-after-retry is real.
52. **Write the GATE-READY card before expensive runs.**
    changed / hypothesis / unit proof / if wrong / preflight —
    a card you cannot fill honestly means the run is not ready.
53. **Drift-manifest lifted modules.**
    Pin origin path + revision per lifted file; a CI job fails on
    divergence; humans reconcile deliberately.
54. **Spec-quote gates fail loudly.**
    Quote or pin drift is a finding; silence it and the anchors
    become decoration.
    Bump pins deliberately, in their own commit, with the reason.
55. **Corpus tamper detection.**
    Rebuild the quote pack from pins and compare; an in-place-edited
    corpus must fail instead of re-authorizing drifted quotes.

## Browser-recorded product films (overlay, pacing, narration post pass)

Lessons 56–64 come from a round of phone-viewport product films
recorded straight out of a browser test runner: on-screen card
chrome, a live companion device view, synthesized voice-over, and an
ffmpeg post pass.

56. **Fixed overlays are click-through or they eat the driver.**
    A fixed-position companion view with default pointer events sits
    above the UI under test; the automation driver retries clicks
    under it for the whole action budget (a visibly jittering
    recording) and then fails on a control that is present.
    `pointer-events: none` on every display-only overlay.
57. **Companion overlays: at least a fifth of the frame width, placed
    where the point of interest is not, arriving when the narration
    starts.**
    Below roughly 20 percent of frame width a companion readout stops
    reading; the overlay lives in the calm region of the shot (study
    a frame, find it); an element that exists from frame zero is
    furniture, while one that boots at the narrated moment is a
    character.
58. **Transient character, persistent record.**
    A second view that matters for one scene (a device's own display)
    arrives at the event, runs while the scene lives, and fades; a
    compact strip persists afterwards as the standing record.
    One permanent overlay trying to be both occludes or decays.
59. **Every surface of the same fact reads the same live source.**
    A companion view derives its numbers from the same feed or DOM
    the primary surface renders — never from a parallel simulation.
    Two sources drift apart on camera, and drift on camera is a lie
    with a graph on it.
60. **Card pacing is computed from reading speed, not guessed.**
    Words divided by a words-per-second rate plus entry slack, with a
    floor of about three seconds; fixed guesses produced cards that
    vanished before a human finished the first line.
61. **The runner emits the narration timeline; the post pass consumes
    it.**
    Every on-screen card records its window and its spoken line at
    runtime into a JSON timeline; narration sync becomes data
    plumbing instead of manual measurement.
    Hand-synced voice drifts a little per re-cut until it is wrong
    everywhere.
62. **Rate-fit each synthesized line to its window.**
    Synthesize, measure the take, time-stretch it (clamped, about
    1.45x at most) into the card's window, pad when short, and anchor
    the timeline to the recording's start with a small offset — the
    recording begins before the first page loads.
63. **Mix delayed segments over a silent bed with
    `duration=longest`; re-encode browser video into the delivery
    container.**
    An `amix` built with `duration=first` ends the whole track at the
    first (short) segment — a film that goes silent after its opening
    line; and browser-recorded VP8 cannot be stream-copied into MP4,
    so the final render re-encodes video.
64. **Read the verdict line, not the artifact line.**
    Post-run artifact reports (a file path plus a duration) can
    describe the previous take while the current run failed at load;
    gate on the runner's own pass/fail line.

65. **Bridge system waits with live cards, never dead air.**
    A card that holds until its predicate passes (settlement confirmed,
    sync observed) turns the film's slowest real seconds into narration
    surface instead of a frozen frame the viewer scrub past.
66. **Record where the CPU is; synthesize where the voice is.**
    The capture wants the beefy quiet box; the OS speech synthesizer and
    the post pass live on the presenter's workstation — the
    runner-emitted timeline is what lets the two halves meet later
    without either machine knowing about the other.

## Adding a lesson to this file

One lesson = one mechanism = one entry: rule (imperative), mechanism
(why true), failure class that earned it (genericized).
If it changes how a doc works, update that doc in the same commit.
