# 006 — Base layer sources and licensing

Status: decided; v0.1 packs written in our own words, sources credited in plugin/NOTICE.md

Rule: only sources with an open license that allows redistribution can be shipped or cited as seeds. Anything else is something a user can learn a style from in their own user or project scope. It is never committed to this repo.

## Base layer
- **Prose guidance (for agents):** blader/humanizer pattern list (MIT), built from Wikipedia's "Signs of AI writing" page (CC BY-SA 4.0). Keep any quoted Wikipedia text in a separate CC BY-SA data file. Add the a16z crypto "habits of AI writing" post (22 Aug 2026), cited and reworded in our own words, never quoted.
- **Deterministic rules (for hooks):** krishnasunkam/vale-ai-tells, JMill/deslop and jdkato/voices (all MIT), plus the "not X, but Y" regexes from sam-paech/slop-score.
- **Severity weighting:** sam-paech/slop-forensics and berenslab/llm-excess-vocab (MIT).
- **Evals only, never shipped:** HF liamdugan/raid (MIT), yaful/MAGE (Apache-2.0), Hello-SimpleAI/HC3 (CC BY-SA).

## Content-type pack seeds
- **tech-docs:**
  - Google developer docs style guide (CC BY 4.0), with errata-ai/Google Vale rules (MIT).
  - PostHog handbook style guides (MIT; the text lives under `/contents/` in PostHog/posthog.com). Rewrite generic rules from that text yourself: avoid trivializers (`simply`, `just`, `easily`…), avoid hedging, address the reader as "you", sentence-case headings, Oxford comma, descriptive link text, inclusive language, a product-name glossary rule, bold rather than quotes for UI elements. Don't copy the repo's `.vale/` files; they sit outside `/contents/` and aren't openly licensed.
  - Red Hat and GitLab Vale rules (MIT code).
- **ux-microcopy:**
  - Grafana Writers' Toolkit UX writing guide (grafana/writers-toolkit, Apache-2.0).
  - PatternFly UX writing guidelines (patternfly/patternfly-org, MIT).
  - shadcn/ui examples and blocks (shadcn-ui/ui, MIT). It has no writing guide, but it does have standard microcopy for each component. See 008.

## Still to verify
- Source and license of the Vale hub "ai-tells" package.
- Text licenses for the Red Hat and GitLab guides, before quoting either of them.

## Verified 2026-10-07
- The Vale hub package "ai-tells" is **tbhb/vale-ai-tells** (MIT, 134 rules). krishnasunkam/vale-ai-tells (MIT, 17 rules) is a different package, listed as "AiTells". JMill/deslop and jdkato/voices are MIT.
- The Red Hat supplementary style guide and GitLab's docs (including its style guide and probably its `doc/.vale/` rules) are **CC BY-SA 4.0**. Their text isn't used. The vale-at-red-hat repo is MIT.
- PostHog: only `/contents/` is MIT; the root `STYLEGUIDE.md` is not.
- Google developer docs style guide: CC BY 4.0, credited in `plugin/NOTICE.md`.
- No Wikipedia text is quoted anywhere, so no CC BY-SA data file is needed yet.
- Still open: the URL of the a16z crypto post (`plugin/packs/base/pack.yaml` has a TODO).
