# Provision a Linux narration backend (Ansible)

## What

A playbook and role that turn a fresh Linux host into a film voice-over host.
It installs `ffmpeg`, `espeak-ng`, a Python virtualenv with `kokoro-onnx`, the
pinned Kokoro-82M model and voice pack, and the narration tools from this
repository.

The result is a `kokoro-tts` command on `PATH`, so `tools/narrate-film.sh`
finds a voice on Linux, where the macOS `say` facility does not exist.

## Why

The voice step in `tools/narrate-film.sh` started as the macOS OS voice.
An OS voice is not portable, and a film series must regenerate identically on
every host that records.
Kokoro-82M is offline, CPU-capable, and Apache-2.0, so it runs on a plain build
box with no GPU and no per-character cost.
Encoding the install as a playbook makes a new film host reproducible: the same
model bytes, the same tool versions, verified by checksum.
See [docs/05-voice.md](../docs/05-voice.md) for the voice contract this serves.

## How

Requirements: Ansible on the controller, a Debian-family target with SSH and
`sudo`.

```sh
cp ansible/inventory.example.ini ansible/inventory.ini   # edit film_hosts
ansible-playbook -i ansible/inventory.ini ansible/playbook-film-voice.yml
```

Run from the repository root: the role installs the tools from `./tools`, so it
never keeps a second copy that can drift.
Add `--ask-become-pass` when the target has no passwordless sudo.

Verify by synthesizing one line, or by giving `narrate-film.sh` a timeline:

```sh
echo "Staging packages." | kokoro-tts --out /tmp/line.wav && ffprobe /tmp/line.wav
TTS_ENGINE=kokoro narrate-film.sh clip.webm timeline.json clip.mp4 af_heart
```

## What it installs

| Path | What |
|---|---|
| `/opt/film-voice/venv` | virtualenv with `kokoro-onnx`, `onnxruntime`, `soundfile` |
| `/opt/film-voice/models/kokoro-v1.0.onnx` | the model (sha256-pinned) |
| `/opt/film-voice/models/voices-v1.0.bin` | the voice pack (sha256-pinned) |
| `/usr/local/bin/kokoro-tts` | venv-aware wrapper for `tools/kokoro-tts.py` |
| `/usr/local/bin/narrate-film.sh` | the film narration tool |

The defaults in `roles/film_voice_linux/defaults/main.yml` carry the pinned
model URLs and their sha256, the install prefix, and the default voice.

## Pitfalls

- Do not commit the model or voice pack.
  The role fetches them and checks the sha256 on every run; a checked-in copy
  drifts silently and bloats the repository.
- Bump a pin deliberately (`url` plus `sha256` together) and regenerate the
  affected films: a changed model changes the voice.
- Keep one voice per audience level for the whole series
  ([docs/05-voice.md](../docs/05-voice.md)); a mixed series re-orients the
  viewer on every film.
- The wrapper exists because the venv interpreter, not the system `python3`,
  holds the packages.
  Running `tools/kokoro-tts.py` directly needs `kokoro-onnx` on that
  interpreter.

## References

- [tools/kokoro-tts.py](../tools/kokoro-tts.py) — the synthesis CLI.
- [tools/narrate-film.sh](../tools/narrate-film.sh) — the post pass that
  consumes the synthesized lines.
- [docs/05-voice.md](../docs/05-voice.md) — the voice pipeline and its rules.
