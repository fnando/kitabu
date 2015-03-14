# Changelog

## v2.0.0

- Remove support for different markdown processors; now using Redcarpet.
- Remove support for other file types like textile and html.
- Remove support for pygments.rb highlighter; now using Rouge.
- Add support for .erb files; helpers can be defined within the `Kitabu::Helpers` module.
- Add support for media format stylesheets (print, pdf, html, epub).
