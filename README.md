# Readout

Readout is a Phoenix LiveView prototype for turning followed sources into concise AI summaries and focused tags.

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

Visit [`localhost:4000`](http://localhost:4000), or open [`localhost:4000/demo`](http://localhost:4000/demo) to try the current vertical slice.
