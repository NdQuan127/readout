# Readout

Readout is a Phoenix LiveView app for turning followed sources into concise AI summaries, focused tags, and a daily digest.

## Run Locally

Set a Gemini API key if you want to test real summaries:

```bash
export GEMINI_API_KEY="..."
```

Then set up and start the app:

```bash
mix setup
mix phx.server
```

Visit [`localhost:4000`](http://localhost:4000), then open [`localhost:4000/digest`](http://localhost:4000/digest) to use the signed-in digest.
