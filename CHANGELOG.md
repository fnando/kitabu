# Changelog

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
