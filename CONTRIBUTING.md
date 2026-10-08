# Contributing to scribb.me

scribb gets better when people who use it send back what they learn: a rule that fires on good writing, a habit it misses, a guide that's wrong for your kind of docs. This page explains how a change to the built-in packs gets made, tested and merged.

Your local setup is separate. `/scribb:remember`, `/scribb:learn` and `.scribb/` change what scribb does for you and your team. A change here changes what everyone installs.

## Ways to help

| You noticed | Do this |
|---|---|
| A rule flagged writing that was fine | Open a [false positive](https://github.com/Saleschat/scribb-me/issues/new?template=false-positive.yml) issue, or run `/scribb:report` |
| An AI habit or convention scribb missed | Open a [missed pattern](https://github.com/Saleschat/scribb-me/issues/new?template=missed-pattern.yml) issue |
| A kind of writing scribb doesn't cover | Open a [new content type](https://github.com/Saleschat/scribb-me/issues/new?template=new-content-type.yml) issue |
| A preference your team keeps fixing that every team would want | Run `/scribb:contribute`, which turns a local memory or rule into a pull request |
| A bug in a hook, skill or script | Open a [bug](https://github.com/Saleschat/scribb-me/issues/new?template=bug.yml) issue |

## Where a change belongs

Read [How scribb thinks about writing](README.md#how-scribb-thinks-about-writing) first. In short:

- **Base** (`plugin/packs/base/`): habits that mark machine-written text in any kind of writing. Only add a rule here if it's wrong everywhere.
- **Content type** (`plugin/packs/content-types/<id>/`): conventions every good writer of that kind follows.
- **Format** (`formats/` inside a content type): the structure of one task, such as a README or a release note.
- **Style** (`plugin/packs/styles/<id>/`): taste that good writers disagree on.

The test: would two excellent writers disagree about this rule? If both would follow it, it goes in a content type (or base). If it's a matter of taste, it's a style, and it probably belongs in your own scope rather than in the built-in packs.

The pack format is in [docs/pack-format.md](docs/pack-format.md). Every built-in pack is marked as a worked example of its layer, so copy the closest one.

## Changing a checker rule

Checker rules are [Vale](https://vale.sh) YAML files in a pack's `checks/vale/<ValeStyle>/`.

1. Write or edit the rule. Use the `level` that matches its layer: `error` for base, `warning` for content types, `suggestion` for styles.
2. Add or update its test pair in `checks/vale/tests/`: `<Rule>.bad.md` must trigger it and `<Rule>.good.md` must not. Put the text that was wrongly flagged (for a false positive) in the good file.
3. Run the tests:
   ```
   evals/rules/run.sh
   ```
   This also runs every base rule over all pack text and good examples, and fails if any fire.

Prefer rules that rarely fire on good writing. A rule that flags ordinary human writing does more harm than a missed habit, because the reviewer catches the fuzzy cases anyway.

## Changing guidance

`guide.md`, `summary.md`, `sample.md` and formats are what Claude reads when it writes and reviews. The rule tests can't tell whether a guide change makes the writing better, so:

1. Run the quality evals before and after your change, on the cases it affects:
   ```
   evals/quality/run.sh --case readme-for-cli
   ```
   Each case runs with and without scribb. It uses your Claude credentials and costs money, roughly $0.50–1 per case at the default 2 runs per arm.
2. Put both summary tables in the pull request.
3. If no case covers what you changed, add one: a realistic prompt in `evals/quality/<case>/prompt.md` and graders in `graders/`. Prefer `regex` graders on the produced file; keep `llm` graders to a short list of clear failures. See the existing cases.

## Adding a content type

Open an issue first, so the scope gets agreed before you write a pack. Then:

- Copy `plugin/packs/content-types/product-docs/` and set `id`, `label`, `tagline` (say who it's for), `freedom`, `paths` (or `[]` if the files have no reliable location), `match_order` and `review_threshold`.
- Write `guide.md`, `summary.md`, a `sample.md` (the shared reference text styles rewrite) and at least two formats.
- Add checker rules only where they're high precision, each with a test pair.
- Add at least one quality eval case.

No code changes are needed: scribb finds content types from their packs.

## Licensing

The repository is MIT. Everything in the packs must be our own writing.

- You may draw on openly licensed style guides as inspiration, and credit them in `plugin/NOTICE.md` and the pack's `sources:`. Write the rules in your own words; don't copy text or rule files.
- Don't use text from share-alike guides (CC BY-SA), such as the Red Hat supplementary style guide or the GitLab docs, even reworded closely.
- Never include customer content, private product names or text from your own company's internal docs. Examples should be invented.
- Built-in styles are named by their traits ("Direct developer docs"), never after a real person or publication, and learned only from openly licensed material or with the writer's permission.

## Development setup

```
brew install vale shellcheck      # or see vale.sh for other systems
claude --plugin-dir plugin        # try your changes in a session
evals/rules/run.sh                # rule tests
tests/hooks/run.sh                # hook and script tests
shellcheck -x plugin/bin/* plugin/hooks/scribb-hook plugin/lib/*.sh
```

Scripts must run on bash 3.2 (the macOS default) and must not depend on `jq`.

## Pull requests

- One change per pull request: a rule, a guide section or a new content type.
- Bump the pack's `version` in `pack.yaml` (semver: patch for fixes, minor for new rules or sections).
- CI runs shellcheck, `claude plugin validate`, the rule tests and the hook tests. The quality evals don't run automatically, because they cost money; maintainers can run them from the Actions tab.
- Fill in the pull request template, including the before and after examples.
