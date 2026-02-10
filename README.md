# Homebrew Tap for VoiceFormula Tools

## Install

```bash
brew tap r-ms/tools
brew install vf-transcribe
```

## Tools

### vf-transcribe

Offline speech-to-text transcription using VAD + GigaAM.

```bash
vf-transcribe audio.opus -f srt
vf-transcribe recording.wav -f text -o output.txt
vf-transcribe interview.mp3 -f json
```

On first run, models (~200MB) are downloaded to `~/.vf-transcribe/models/`.
