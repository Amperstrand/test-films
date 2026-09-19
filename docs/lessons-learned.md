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

56. **Record the lanes in one viewport; sync by construction.**
   Aligning independently recorded lanes relies on clock trust across
   machines; composition removes the degree of freedom entirely.
   Earned: a four-lane order film (client, order backend, payment rail,
   Lightning node) shot as one composite take; per-lane re-shoots
   attempted later could not have supported ordering asserts on the
   merged timeline.

## Film factory

57. **Audience layers multiply at render time, not at footage time.**
   Re-recording a scenario per audience multiplies cost and lets
   "identical" takes drift; one footage truth per scenario with N
   narration renders keeps films comparable.
   Earned: a fifteen-cell scenario matrix rendered to forty-five films
   (three audiences) with gates asserting identical event sequences
   across the audience variants of each cell.

58. **Failure-path filming disarms success helpers.**
   A standing auto-settler (installed so demos finish hands-free) paid
   obligations inside shortened failure windows, so expiry cells failed
   as "settled anyway".
   Earned: the failure group only recorded correctly with the settler's
   systemd timer paused for that group, then restored and verified.

59. **Kill the supervisor tree between environment groups.**
   An orchestrator that stops only the listener leaves the supervisor
   alive; it respawns the listener with the previous group's config, and
   the next take silently runs the wrong environment.
   Earned: a "settlement disabled" group whose invoices kept settling;
   the take had run against a respawned stale-config server.

60. **Inventory shared state directories before blaming external actors.**
   Two dev servers on one checkout with separate ports shared one state
   directory; alarms and background turns of one executed against the
   other's data.
   Earned: hours spent suspecting an innocent second instance while the
   real actor was a timer on a remote host; the state directory was the
   first thing that separated the suspects.

61. **When the log omits the event, diff the state.**
   A Lightning node at info level logs nothing for invoice settlement,
   yet settlement is visible in list calls.
   Earned: a payment lane that stayed empty while payments settled;
   a one-second poll-diff over `listinvoices` reconstructed the lane
   from real state.

62. **Slide the window; never parse a failed fetch as empty.**
   Windowed polling of a growing list must re-anchor the window each
   poll; a failed initial fetch parsed as an empty list pins the window
   to the oldest items and the watcher dies silently.
   Earned: a telemetry poller that emitted nothing for whole takes
   because its one slow boot fetch fell back to "zero items".

63. **Local settlement leaves no outbound record.**
   A node that settles its own obligation marks it settled without any
   outbound payment entry.
   Earned: "no outbound payment" was read as "nobody paid" while the
   invoice was settled locally by the node itself.

64. **Render derived units beside raw units.**
   A system reporting millisatoshi is read as satoshi by humans; the
   1000x phantom propagates into incident reports and screenshots.
   Earned: a "wrong by 1000x" invoice complaint that was a display-unit
   misread; every human surface now carries satoshi beside BTC.

65. **Budget the viewport before the first take.**
   Chrome added after layout steals pixels from the protagonist.
   Earned: a status bar under a full-height phone cropped the
   composer out of every frame of a recorded matrix; the fix was
   layout arithmetic plus one frame inspection, not re-recording
   discipline.

66. **The protocol view is the timeline drawn, not authored.**
   Mapping narration events onto live sequence arrows (one lifeline
   per participant) shows causality at speaking speed.
   Earned: a four-participant payment story followed on screen where
   the printed timeline needed study; the arrow mapping was a table
   over the same events, no new instrumentation.

67. **Voice over clean footage; captions live beside the film.**
   Burned-in text duplicates the narration, dates the footage, and
   fights the composition for attention.
   Earned: a narrated matrix re-rendered without subtitles or scene
   titles read better and aged better; subtitle files kept serving
   players that want them.

68. **Natural narration is a local model away.**
   An 82M-parameter public model synthesizes faster than real time on
   CPU; the robotic voice was a habit, not a constraint.
   Earned: switching the synthesizer changed nothing in the pipeline
   except one command and two declared settings (voice, speed).
   The GPU execution provider needs matching system CUDA libraries —
   without them it falls back to CPU silently, and CPU is enough.

69. **One visible actor per causal arrow.**
   A standing auto-settler on a wall clock makes payments appear
   causeless in the diagram — effects without senders.
   Earned: recordings where the invoice settled with no self-pay
   arrow; pausing the external settler during recording put the
   visible participant back in the causal chain.

70. **Stamp merged logs in milliseconds.**
   A diagram that sequences events a log cannot order at second
   resolution will contradict itself on camera.
   Earned: `T+ss.mmm` stamps on every merged line kept the log lane
   and the live arrows agreeing during fast settlement sequences.

71. **Namespace injected class names; never let data meet layout CSS.**
   Rendering log lines tagged by participant, a lane named "phone"
   collided with the page's `.phone` shell rule (a fixed-height bezel):
   the first row became 876 pixels tall and every later row painted
   below the clip — a full log panel that rendered as one line.
   Earned: a film matrix where every gate passed except pixel reality;
   the fix was namespacing lane classes (`l-phone`) and renaming the
   layout class, plus a footage gate that counts painted lines.

72. **Dynamic viewport units misreport inside cross-origin iframes.**
   `100dvh` in an app embedded by a composition page computed ~46 pixels
   short in headless Chromium, so the app's composer never reached the
   frame bottom and a dead band read as a cropped phone at any iframe
   height.
   Earned: layout arithmetic (sum the chrome, clip the bezel to the
   app's real extent) instead of chasing the "right" iframe size.

73. **Gate the footage, not just the artifacts around it.**
   Timeline, container, and audio gates all passed while the recorded
   pixels showed an empty log panel — the DOM held the rows, the paint
   did not.
   Earned: a per-take gate that extracts a frame and counts painted
   log lines by color signature; CSS and DOM truth diverge exactly
   where films are made.

## Adding a lesson to this file

One lesson = one mechanism = one entry: rule (imperative), mechanism
(why true), failure class that earned it (genericized).
If it changes how a doc works, update that doc in the same commit.
