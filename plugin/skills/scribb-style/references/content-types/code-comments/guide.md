# Code comments

*Content type: what kind of writing. Conventions here apply whatever the style.*

This content type covers the comments in code: doc comments on functions, types, modules and packages (Javadoc, KDoc, TSDoc and JSDoc, Go doc comments, Python docstrings, rustdoc), and inline comments. Its reader is a developer reading the code, or reading the docs generated from it in a hover, an index or a reference site. They want to know what a thing does and how to use it without reading its body.

Good libraries in every language get this right, and their comments are short. The best doc comment is one sentence that says what the code does, plus the few facts the signature can't show.

Default freedom: **balanced**.

## How scribb picks this content type
scribb splits every file into prose, UI text and comments, and checks each kind of block as its own content type. Comments and docstrings in any source file are code comments, and so are the comments inside code fences in Markdown. The file's extension only tells scribb which comment syntax to look for.

The hooks check only the comments a change touched, so editing a file never means rewriting the comments already in it. Turn this content type off with `code_comments: off` in any scope (user, project or local).

## The rules every language shares
- **Lead with a summary sentence.** It must make sense on its own, because tools show it alone in hovers and indexes. Write it as a verb phrase about what the code does: "Returns the workspace a user belongs to."
- **Say what and why, not how.** The body shows how. A comment that narrates the steps goes out of date the next time someone edits the code.
- **Don't repeat the code.** No restating the name ("GetUser gets the user"), the signature, or the types the language already declares.
- **Document parameters, return values and errors only when they add something:** a unit, a range, what `null` means, when it throws. Skip the tag if all it would say is the parameter's name.
- **Link instead of explaining again.** Point at the related type or function with the language's link syntax.
- **Inline comments explain a why the code can't show:** a workaround, a constraint, a surprising choice. Never comment what a line obviously does.
- **No history.** "Updated to use the cache", "previously returned null" and "fixed the bug" belong in the commit message and the pull request, not the code.
- **No notes to the reviewer or the person who asked for the change.** "As requested" and "I added this" don't help the next reader.
- **Delete commented-out code.** Version control keeps it.
- **Match the conventions the file already uses:** its tag style, its docstring layout, its tone. Consistency within a codebase beats any one guide.

## Each ecosystem's own conventions

### Go
- Start the comment with the name of the thing: "Parse returns…", "Client is…". Write full sentences that end with a period.
- Put the package comment in `doc.go`, starting "Package name…".
- Link with `[Name]` or `[pkg.Name]`. Indent code examples with a tab.
- Mark deprecation with a paragraph that starts `Deprecated:` and says what to use instead.

### TypeScript and JavaScript
- Use TSDoc or JSDoc block comments (`/** … */`) on exported functions, classes and types.
- Add `@param`, `@returns` and `@throws` only when they say something the types don't. In TypeScript, never repeat the types in the comment.
- Link with `{@link Name}`. Put a runnable example under `@example` when usage isn't obvious.
- Use `@deprecated` with what to use instead.

### Java and Kotlin
- The first sentence of a Javadoc or KDoc comment is the summary. Tools cut it at the first period, so make it complete.
- Then `@param`, `@return` and `@throws` (KDoc: `@param`, `@return`, `@throws`), each as a short phrase with no ending period, unless it's more than one sentence.
- Link with `{@link Name}` and `@see` in Javadoc, and `[Name]` in KDoc. Use `{@code value}` for code in a sentence.
- Write about the method, not to the reader: "Returns the label", not "This method returns the label".

### Python
- Follow PEP 257. A one-line docstring fits on one line with its quotes. A longer one starts with a summary line, then a blank line, then the details.
- Use the layout the repo already uses for arguments and return values (Google style `Args:` and `Returns:`, or NumPy style sections). Don't mix them.
- Don't restate type hints in the docstring.
- Put examples in doctest form (`>>>`) when they help.

### Rust
- The first line is a summary. Then the details, then sections such as `# Examples`, `# Errors`, `# Panics` and `# Safety` when they apply.
- Use intra-doc links: `[Name]`, `[crate::path::Name]`.
- Every public function that can fail or panic says when, in `# Errors` or `# Panics`.

### Other languages
Follow the language's own documentation tool (Doxygen for C and C++, XML doc comments for C#, YARD for Ruby, DocC for Swift) with the same shared rules.

## Example

Before:

```ts
/**
 * This function is used to get the user. It takes a userId string
 * parameter and returns a Promise of User. Updated to use the new cache.
 */
```

After:

```ts
/** Returns the user, from the cache when it's fresh. Throws {@link NotFound} if none exists. */
```

## What the checker covers
`ScribbCodeComments.*` rules: HistoryInComments, ReviewerNotes, RestatesSignature. The base rules apply to comments too. The reviewer covers everything else on this page, including whether a comment repeats the code.
