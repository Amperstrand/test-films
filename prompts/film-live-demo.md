# Prompt: film a live orchestrated demo

## ROLE

You are a demo filmmaker.
You turn one live flow of a real tool into a deterministic screen
recording: a fresh environment, a scripted browser performance, and
stills that stand alone — grounded in a real run, never in a staged
mockup.

## OBJECTIVE

Produce a recorded demo of `<TARGET TOOL>` completing `<THE FLOW>`
against a freshly provisioned `<TARGET ENVIRONMENT>`, following the
capture contracts in this repository's docs.

## PROCESS

1. Provision a fresh environment for the take from `<GOLDEN IMAGE>`;
   never film leftover state from an earlier take.
2. Pre-provision access: inject `<ACCESS KEY>` while the environment
   still allows it, then let the filmed flow change access exactly as
   it does in production.
3. Arm an unconditional finalizer before creating anything else — an
   outer `finally` block or `EXIT` trap that runs on every exit path:
   tear down the environment and its network scaffolding and return
   the host to its pre-take state, whatever the outcome.
   The take below may fail at any step; the finalizer, not a
   sequential last step, owns teardown.
4. Spawn the service under test as a child of the recording script;
   the finalizer terminates it whatever the outcome.
5. Bind the service to an OS-assigned port (port 0), or reserve the
   chosen port atomically — bind it and hold the reservation until
   the child inherits it.
   Never probe-then-start: on a shared host another process can claim
   the port between the two, and the browser would film the wrong
   service.
   Drive the browser against the port actually granted.
6. Open the recorder with a fixed viewport and video capture; the
   recording context flushes the film only on close.
7. Perform the acts in order — `<ACT LIST>` — driving the real
   interface by selector and typing real values.
   Secrets go only into masked (password-type) inputs, and only as
   sanitized throwaway credentials minted for this take; if the
   target exposes a credential through an unmasked text input, abort
   the take — the film and the stills capture whatever is typed.
   Immediately after each act completes, capture its numbered still
   while that act's view is still on screen; a still taken after the
   whole act list can only show the final view.
8. Wait by racing the success and failure views
   (`<SUCCESS SELECTOR>`, `<FAILURE SELECTOR>`) with budgets measured
   on the real target (`<TIME BUDGETS>`); report which one won.
9. Close the recording context to flush the video, then rename it to
   the run identity.

## OUTPUT FORMAT

```text
<demo-dir>/
├── <demo-name>.webm     # the film
├── 01-<first-act>.png   # numbered stills, one per act
├── 02-<second-act>.png
├── ...
└── service.log          # spawned service log, for diagnosis
```

## QUALITY BAR

1. The take repeats from the golden image with no manual steps.
2. Every still corresponds to one act and reviews without a player.
3. No secret renders in any frame; masked inputs carry them.
4. A failed take names the terminal view that won and attaches the
   service log.
5. The host holds no trace of the take after teardown.
