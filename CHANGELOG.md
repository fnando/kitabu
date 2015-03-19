# Changelog

## Unreleased

- Support fonts directory
- Allow having any element as the chapter title (e.g. h1). Previously you could only use h2.

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
- Add support for .erb files; helpers can be defined within the `Kitabu::Helpers` module.
- Add support for media format stylesheets (print, pdf, html, epub).
