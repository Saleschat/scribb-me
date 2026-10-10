# Developing scribb.me

How scribb.me is laid out, where it keeps things, and how to build and test it. To improve the built-in packs, see [CONTRIBUTING.md](CONTRIBUTING.md).

## Where things live

| Scope | Path | Committed |
|---|---|---|
| Built-in | the plugin's `packs/` (`base/`, `content-types/`, `styles/`) | — |
| User | `~/.config/scribb/` (settings, memories, your own styles, formats and rules) | no |
| Project | `.scribb/` (settings, memories, `vocab.txt`, team styles, formats and rules) | yes |
| Local | `.scribb/local/` | no (it ignores itself) |
| Machine state | `~/.cache/scribb/` (session settings, retry counts, the hook log) | no |

- Product names that keep their own casing go in `vocab.txt` (user, project or local scope), one per line.
- Captured corrections stay in `.scribb/local/inbox/` on your machine. scribb sends no telemetry.
- `/scribb:style doctor` shows the environment and the last hook runs.

## Repository layout

| Path | What it is |
|---|---|
| `plugin/` | The plugin: skills, agents, hooks, helper scripts and packs |
| `plugin/packs/` | Built-in base, content types and styles ([pack format](docs/pack-format.md)) |
| `tools/build-chat.py`, `tools/chat/` | Build the chat bundles: guides and the built-in checker copied into each chat-capable skill |
| `evals/rules/` | A bad/good test pair for every checker rule |
| `evals/quality/` | With/without-scribb quality evals (`claude plugin eval`) |
| `tests/` | Hook and helper tests, and the chat checker's parity tests against Vale |
| `docs/open-items/` | The design, one file per decision or open question |

## Build and test

```
brew install vale shellcheck     # Vale is optional for users, needed for the parity tests
claude --plugin-dir plugin       # try the plugin locally
python3 tools/build-chat.py      # rebuild the chat bundles after editing packs
evals/rules/run.sh               # every checker rule fires on bad text and stays quiet on good text
python3 tests/chat/parity.py     # the built-in checker gives the same findings as Vale
tests/hooks/run.sh               # hook and helper tests
shellcheck -x plugin/scripts/* plugin/hooks/scribb-hook plugin/lib/*.sh
evals/quality/run.sh             # quality evals; uses your Claude credentials and costs money
```

CI runs everything except the quality evals on every pull request. Scripts must run on bash 3.2 (the macOS default) and must not depend on `jq`. The built-in checker uses only the Python standard library.

## Licence

MIT. Built-in packs are our own writing; [plugin/NOTICE.md](plugin/NOTICE.md) credits the style guides and rule sets they drew on.
