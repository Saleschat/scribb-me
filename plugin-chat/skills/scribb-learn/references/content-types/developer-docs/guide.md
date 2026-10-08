# Developer docs

*Example content type: what kind of writing. Conventions here apply whatever the style.*

This content type covers documentation for developers who write code against the product: API reference, SDK and library reference, CLI reference, integration guides, concepts that explain how the system behaves, and troubleshooting for error codes. The reader knows code. They come to look something up or to wire something together, and they leave as soon as it works.

Product docs (`product-docs`) cover the same product for people who use it. That includes help articles, getting-started guides and the repo's README. If a page is mostly UI paths and outcomes, it's product docs. If it's mostly parameters, requests and return values, it's developer docs.

Default freedom: **strict**.

## How scribb picks this content type
Docs layouts vary, so this pack has no default file paths. scribb uses it when:
- the request or the page is clearly reference or integration material (endpoints, parameters, commands, SDK methods),
- the page's frontmatter says `scribb-content-type: developer-docs`, or
- the repo maps its folders with `paths_developer_docs` (`/scribb:setup` offers to do this).

## Structure
- Pick a format first: API reference, CLI reference, integration guide, concept or troubleshooting (see `formats/`). Don't mix a tutorial into a reference page.
- Open with one sentence that says what the page documents.
- Reference pages are complete and consistent. Every entry has the same fields in the same order.
- Integration guides list prerequisites (accounts, keys, versions) before the first step, and end with a way to verify that the integration works.

## Code samples
- Every endpoint, command and method gets at least one example that runs as written. Use placeholder values that read as placeholders, such as `YOUR_API_KEY`.
- Tag every code block with its language. Show the output in a separate block, labelled as output.
- Keep samples minimal: only what the example needs. No unrelated setup.
- If the product has several SDKs, show the same example in each, in the same order on every page.

## Parameters and fields
- Use a table or a definition list with the same columns throughout: name, type, required or default, description.
- Write the description as a phrase that says what the value does, not what it is called again: "Seconds before the token expires", not "The expiry".
- Give allowed values and limits: ranges, maximum lengths, formats such as ISO 8601.

## Errors
- List errors with the code, the message exactly as returned, the cause and the fix.
- Start with the error a reader is most likely to hit.

## Versions and deprecation
- Say which version a behaviour or field applies to.
- A deprecated item says when it goes away and what replaces it.

## Headings, voice and words
- Sentence case for headings. Reference headings are the name of the thing (`POST /v1/keys/{id}/revoke`). Guide headings start with a verb.
- Address the reader as "you". Use the imperative for steps, and present tense: "Returns a token", not "will return".
- No trivializers: simply, just, easily, obviously, of course, straightforward.
- No "please". Spell out Latin abbreviations. No exclamation marks.
- One term for one concept, across every page and SDK. Use the names the code uses.

## Links
- Link text names the target: "see [Authentication](auth.md)".
- Link each parameter type to its definition the first time it appears on a page.

## Example
Before:
> Simply call the revoke endpoint and the key will be easily revoked!

After:
> `POST /v1/keys/{id}/revoke` revokes a key immediately. Requests that use the key afterwards return `401 invalid_api_key`.

## What the checker covers
`ScribbDevDocs.*` rules: Trivializers, Please, LinkText, HeadingCase, Exclamation, LatinAbbrev. The reviewer covers everything else on this page, including complete reference entries and runnable samples.
