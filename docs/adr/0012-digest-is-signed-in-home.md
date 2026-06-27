# Digest is the signed-in home

Readout has moved from a prototype harness to a product surface centered on the daily Digest, so `/digest` is now the signed-in home and login fallback. The old `/demo` LiveView was retired instead of redirected because it mixed manual pipeline testing with product navigation; Source ingestion, Content scraping, and Summary generation remain domain capabilities covered by context and worker tests rather than a user-facing demo page.
