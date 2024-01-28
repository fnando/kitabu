# Changelog

## unreleased

- Add `before_markdown_render` and `after_markdown_render` hooks, allowing
  content manipulation.
- Add link anchor on each title.
- Improve epub final file (better table of contents, less epubcheck errors, CSS
  localization, and more).
- Add support for frontmatter on `.md` and `.md.erb` files.

## v3.1.0

- Add support for
  [Github's alert syntax](https://github.com/orgs/community/discussions/16925).
  Kitabu's implementation supports any arbitrary name, so you can use anything
  (e.g. `[!ALERT]`).

## v3.0.3

- Fix Rouge options keys; symbols are required.

## v3.0.2

- Fix `styles` directory copying.

## v3.0.1

- Add accessor methods `Kitabu::Markdown.default_renderer_options` and
  `Kitabu::Markdown.default_markdown_options`.
- Set Redcarpet's `hard_wrap` to `false`.

## v3.0.0

- Drop Sass support; the `styles` directory will now be copied to the `output`
  directory when exporting files.
- Drop support for `html2text`; the output wasn't that good.
- Drop support for notifier; this gem is no longer maintained.
- Use calibre to generate mobi files; kindlegen has been deprecated.
- Make it run with modern Ruby.

## v2.1.0

- Lock Rouge version to ~>2.0.

## v2.0.4

- Support fonts directory
- Allow having any element as the chapter title (e.g. h1). Previously you could
  only use h2.
- Bug fix: unknown Rouge lexer was raising an error.

## v2.0.3

- Bug fix: footnote label wasn't updated with current count

## v2.0.2

- Bug fix: generate valid HTML markup

## v2.0.1

- Improve footnote generation

## v2.0.0

- Remove support for different markdown processors; now using Redcarpet.
- Remove support for other file types like textile and html.
- Remove support for pygments.rb highlighter; now using Rouge.
- Add support for .erb files; helpers can be defined within the
  `Kitabu::Helpers` module.
- Add support for media format stylesheets (print, pdf, html, epub).
