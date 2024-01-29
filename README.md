# kitabu

[![Tests](https://github.com/fnando/kitabu/workflows/ruby-tests/badge.svg)](https://github.com/fnando/kitabu)
[![Gem](https://img.shields.io/gem/v/kitabu.svg)](https://rubygems.org/gems/kitabu)
[![Gem](https://img.shields.io/gem/dt/kitabu.svg)](https://rubygems.org/gems/kitabu)
[![MIT License](https://img.shields.io/:License-MIT-blue.svg)](https://tldrlegal.com/license/mit-license)

Kitabu is a framework for creating e-books from Markdown using Ruby. Using
Prince PDF generator, you'll be able to get high quality PDFs. Also supports
EPUB, Mobi, and HTML generation.

While Prince is too expensive (495USD for a single user license), the free
version available at <http://www.princexml.com/download> generates a PDF with a
small logo on the first page, which is removed when sent to a printer; you can
use it locally for viewing the results immediately. When you're done writing
your e-book, you can use [DocRaptor](http://docraptor.com), which have plans
starting at \$15/mo.

## Features

- Write using Markdown
- Book layout support
- Syntax highlight
- Generate HTML, PDF, e-Pub (version 3.3), and Mobi
- Table of Contents automatically generated from chapter titles

## Installation

To install Kitabu, you'll need a working Ruby 3.2+ installation. If you're cool
with it, just run the following command to install it.

    gem install kitabu

After installing Kitabu, run the following command to check your external
dependencies.

    $ kitabu check

    Prince XML: Converts HTML files into PDF files.
    Installed.

    Calibre's ebook-convert: Converts ePub e-books into .mobi files.
    Installed.

There are no hard requirements here; just make sure you cleared the correct
dependency based on the formats you want to export to.

## Usage

To create a new e-book, just run

    $ kitabu new mybook

This command creates a directory `mybook` with the following structure:

```
.
├── Gemfile
├── Gemfile.lock
├── Guardfile
├── assets
│   ├── fonts
│   ├── images
│   │   ├── cover.png
│   │   ├── kitabu.svg
│   │   ├── markdown.svg
│   │   └── up.svg
│   ├── scripts
│   └── styles
│       ├── epub.css
│       ├── html.css
│       ├── pdf.css
│       ├── print.css
│       └── support
│           ├── kitabu.css
│           ├── normalize.css
│           ├── notes.css
│           └── toc.css
├── config
│   ├── helpers.rb
│   ├── kitabu.yml
│   └── locales
│       └── en.yml
├── templates
│   ├── epub
│   │   ├── cover.erb
│   │   ├── page.erb
│   │   └── toc.erb
│   └── html
│       └── layout.erb
└── text
    ├── 01_Getting_Started.md
    ├── 02_Creating_Chapters.md
    ├── 03_Syntax_Highlighting.md.erb
    ├── 04_Dynamic_Content.md.erb
    ├── 05_Exporting_Files.md
    └── 06_Changelog.md

13 directories, 28 files
```

The `config/kitabu.yml` file holds some information about your book; so you'll
always change it.

The generated structure is actually a good example. So make sure you try it!

![Kitabu - Sample Book](https://github.com/fnando/kitabu/raw/main/attachments/cover.png)

There's a generated sample available on the
[attachments directory](https://github.com/fnando/kitabu/tree/main/attachments)
• [PDF](https://github.com/fnando/kitabu/raw/main/attachments/kitabu.pdf) /
[EPUB](https://github.com/fnando/kitabu/raw/main/attachments/kitabu.epub) /
[MOBI](https://github.com/fnando/kitabu/raw/main/attachments/kitabu.mobi) /
[HTML](https://github.com/fnando/kitabu/raw/main/attachments/browser-version.png).

Now it's time to write your e-book. All your book content will be placed on the
text directory. Kitabu requires you to separate your book into chapters. A
chapter is nothing but a directory that holds lots of text files. The e-book
will be generated using every folder/file alphabetically. So be sure to use a
sequential numbering as the name. Here's a sample:

    * text
      * 01_Introduction
        * 01_introduction.md
      * 02_What_is_Ruby_on_Rails
        * 01_MVC.md
        * 02_DRY.md
        * 03_Convention_Over_Configuration.md
      * 03_Installing_Ruby_on_Rails
        * 01_Installing.md
        * 02_Mac_OS_X_instructions.md
        * 03_Windows_instructions.md
        * 04_Ubuntu_Linux_instructions.md

If you prefer, you can add a chapter per file:

    * text
      * 01_Introduction.md
      * 02_What_is_Ruby_on_Rails.md
      * 03_Installing_Ruby_on_Rails.md

You'll want to see your progress eventually; it's time for you to generate the
book PDF. Just run the command `kitabu export` and your book will be created on
the `output` directory.

Kitabu can generate a Table of Contents (TOC) based on your h2-h6 tags. The h1
tag is discarded because it's meant to be the book title.

To print the TOC, you need to print a variable called `toc`, using the eRb tag.

    <%= toc %>

#### Frontmatter

Markdown files (and their `.md.erb` counterparts) support frontmatter, a section
that can inject variables to the page. Notice that the contents inside the `---`
delimiters must be valid YAML annotation and only basic types can be used
(booleans, numbers, strings, nils and hashes/arrays with these same types).

Right now there's only one special value called `section`, which defines the
class section when generating files. This allows you to have files inside your
`text` directory that doesn't necessarily should have styling like regular
chapters. For instance, this is how you can define a changelog section:

```markdown
---
section: changelog
---

## Changelog

### Jan 26, 2024

- Initial release
```

> [!NOTE]
>
> Notice that `section` will be retrieved from the first file, even if you have
> multiple files defining a section with a directory.

This meta data will be inject on your template using the variable `meta`. If you
have other variables, you could print them as `<%= meta["varname"] %>`.

### Using ERB

You can also have `.md.erb` files. You can mix Markdown and HTML, like the
following:

    ## This the chapter title

    <%= image_tag "myimage.png" %>

The above content must be placed in a `.md.erb` file. The generated content will
be something like this:

```html
<img src="images/myimage.png" />
```

You book's helpers can be added to `config/helpers.rb`, as this file is loaded
automatically by kitabu.

You can see available helpers on
<https://github.com/fnando/kitabu/blob/main/lib/kitabu/helpers.rb>.

### Syntax Highlighting

To highlight code, use fenced code blocks.

    ``` ruby
    class User < ActiveRecord::Base
      validates_presence_of :login, :password, :email
      validates_uniqueness_of :login, :email
    end
    ```

You can even provide options:

    ```php?start_line=1&line_numbers=1
    echo "Hello World";
    ```

- We use [Redcarpet](https://rubygems.org/gems/redcarpet) for Markdown
  processing.
- We use [Rouge](https://rubygems.org/gems/rouge) for syntax highlighting.

The following Redcarpet options are enabled:

- `autolink`
- `fenced_code_blocks`
- `footnotes`
- `hard_wrap`
- `highlight`
- `no_intra_emphasis`
- `safe_links_only`
- `space_after_headers`
- `strikethrough`
- `superscript`
- `tables`

### Hooks

There are a few hooks that allows manipulating the content. You can use
`before_render` and `after_render` to process the Markdown content. You can add
such hooks to your `config/helpers.rb` file.

```ruby
Kitabu::Markdown.add_hook(:before_render) do |content|
  # manipulate content and return it.
  content
end

Kitabu::Markdown.add_hook(:after_render) do |content|
  # manipulate content and return it.
  content
end
```

### Using custom fonts

You can use custom fonts on your ebooks. Just add them to the `fonts` directory
(you can create this directory on your book's root directory if it doesn't
exist).

Then, on `assets/styles/support/fonts.css` you can add the `@font-face`
declaration.

```css
@font-face {
  font-family: "Open Sans Condensed Bold";
  src: url("../../fonts/OpenSans-CondBold.ttf");
}
```

Finally, to use this font, do something like this:

```css
.chapter > h2 {
  font-family: "Open Sans Condensed Bold";
}
```

Instead of doing the above manually, you can also use Prince's `--scanfonts`
option.

```console
$ prince --scanfonts assets/fonts/* > assets/styles/support/fonts.css
```

Just remember to replace the generated path to be something like `../../fonts`
instead.

> [!TIP]
>
> In most cases, it's easier to redefine `sans-serif`, `serif` and `monospace`
> fonts. To know more about how to do this, read Prince's
> [Redefining the generic font families](https://www.princexml.com/doc/styling/#redefining-the-generic-font-families)
> documentation.

If you're unsure if fonts are actually being used on PDF files, use the
environment variable `PRINCEOPT` to disable system fonts.

```console
$ PRINCEOPT='--no-system-fonts --debug --log output/prince.log' kitabu export --only pdf
=> e-book couldn't be exported

$ tail -n10 output/prince.log
Sat Jan 27 18:39:10 2024: debug: font request: Caslon, serif
Sat Jan 27 18:39:10 2024: warning: Ensure fonts are available on the system or load them via a @font-face rule.
Sat Jan 27 18:39:10 2024: warning: For more information see:
Sat Jan 27 18:39:10 2024: warning: https://www.princexml.com/doc/help-install/#missing-glyphs-or-fonts
Sat Jan 27 18:39:10 2024: internal error: Unable to find any available fonts.
Sat Jan 27 18:39:10 2024: finished: failure
Sat Jan 27 18:39:10 2024: ---- end
```

### Configuring Markdown

Kitabu uses [Redcarpet](https://github.com/vmg/redcarpet) as the Markdown
engine. You can override the default processor by setting
`Kitabu::Markdown.processor`. This can be done by adding something like the
following to `config/helpers.rb`:

```ruby
Kitabu::Markdown.processor = Redcarpet::Markdown.new(
  Kitabu::Markdown::Renderer.new(hard_wrap: false, safe_links_only: true),
  tables: true,
  footnotes: true,
  space_after_headers: true,
  superscript: true,
  highlight: true,
  strikethrough: true,
  autolink: true,
  fenced_code_blocks: true,
  no_intra_emphasis: true
)
```

The above options are Kitabu's defaults.

### Exporting PDFs using DocRaptor

If you're not planning to buy PrinceXML, consider using
[DocRaptor](http://docraptor.com). Here's how you can easily do it:

```bash
curl -H "Content-Type:application/json" -d'{"user_credentials":"YOUR_CREDENTIALS_HERE", "doc":{"name":"kitabu.pdf", "document_type":"pdf", "test":"false", "document_url":"https://example.com/output/kitabu.pdf.html"}}' http://docraptor.com/docs > kitabu.pdf
```

## References

- Markdown: <http://daringfireball.net/projects/markdown/syntax>
- Markdown PHP: <https://michelf.ca/projects/php-markdown/extra/>
- Some PrinceXML tips by the creator himself: <https://css4.pub>

## Legal Notes

- PrinceXML: [license](http://www.princexml.com/license/)

## Maintainer

- [Nando Vieira](https://github.com/fnando)

## Contributors

- https://github.com/fnando/kitabu/contributors

## Contributing

For more details about how to contribute, please read
https://github.com/fnando/kitabu/blob/main/CONTRIBUTING.md.

## License

The gem is available as open source under the terms of the
[MIT License](https://opensource.org/licenses/MIT). A copy of the license can be
found at https://github.com/fnando/kitabu/blob/main/LICENSE.md.

## Code of Conduct

Everyone interacting in the kitabu project's codebases, issue trackers, chat
rooms and mailing lists is expected to follow the
[code of conduct](https://github.com/fnando/kitabu/blob/main/CODE_OF_CONDUCT.md).
