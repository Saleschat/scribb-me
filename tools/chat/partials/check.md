If you can run code, check the text with the bundled checker. Save it to a file (`.jsx` for UI strings inside components, `.md` otherwise), then run:
`python3 scripts/check.py --content-type <id> --freedom <strict|balanced|expressive> [--style <id>] <file>`
It prints `file:line:col:action:severity:rule:message`, the same findings scribb gives in Claude Code. Fix every `block` finding and consider the `warn` ones. If you can't run code here, say once that the automatic check didn't run, and be extra careful in the review.
