# kitabu

[![Build Status](https://travis-ci.org/fnando/kitabu.svg)](https://travis-ci.org/fnando/kitabu)

While Prince is too expensive (495USD for a single user license), the free version available at <http://www.princexml.com/download> generates a PDF with a small logo on the first page, which is removed when sent to a printer.

## Features

* Write using Markdown
* Book layout support
* Syntax highlight
* Generate HTML, PDF, e-Pub, Mobi and Text files
* Table of Contents automatically generated from chapter titles

## Installation

To install Kitabu, you’ll need a working Ruby 1.9+ installation.
If you’re cool with it, just run the following command to install it.

    gem install kitabu

After installing Kitabu, run the following command to check your external
dependencies.

    $ kitabu check

    Prince XML: Converts HTML files into PDF files.
    Installed.

    KindleGen: Converts ePub e-books into .mobi files.
    Installed.

    html2text: Converts HTML documents into plain text.
    Not installed.

There are no hard requirements here; just make sure you cleared the correct dependency based on the formats you want to export to.

## Usage

To create a new e-book, just run

    $ kitabu new mybook

This command creates a directory `mybook` with the following structure:

    mybook
    ├── code
    ├── config
    │   ├── helper.rb
    │   └── kitabu.yml
    ├── images
    ├── output
    ├── templates
    │   ├── epub
    │   │   ├── cover.erb
    │   │   ├── cover.png
    │   │   ├── page.erb
    │   │   └── user.css
    │   └── html
    │       ├── layout.css
    │       ├── layout.erb
    │       ├── syntax.css
    │       └── user.css
    └── text
        └── 01_Welcome.md

The `config/kitabu.yml` file holds some information about your book; so you'll always change it.

Now it's time to write your e-book. All your book content will be placed on the text directory. Kitabu requires you to separate your book into chapters. A chapter is nothing but a directory that holds lots of text files. The e-book will be generated using every folder/file alphabetically. So be sure to use a sequential numbering as the name. Here's a sample:

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

You'll want to see your progress eventually; it's time for you to generate the book PDF. Just run the command `kitabu export` and your book will be created on the `output` directory.

Kitabu can generate a Table of Contents (TOC) based on your h2-h6 tags. The h1 tag is discarded because it's meant to be the book title.

To print the TOC, you need to print a variable called +toc+, using the eRb tag.

    <%= toc %>

### Syntax Highlighting

To highlight code, use fenced code blocks.

    ``` ruby
    class User < ActiveRecord::Base
      validates_presence_of :login, :password, :email
      validates_uniqueness_of :login, :email
    end
    ```

You can even provide options:

    ```php?start_inline=1&line_numbers=1
    echo "Hello World";
    ```

- We use [Redcarpet](https://rubygems.org/gems/redcarpet) for Markdown processing.
- We use [Rouge](https://rubygems.org/gems/rouge) for syntax highlighting.

The following Redcarpet options are enabled:

* `autolink`
* `fenced_code_blocks`
* `footnotes`
* `hard_wrap`
* `highlight`
* `no_intra_emphasis`
* `safe_links_only`
* `space_after_headers`
* `strikethrough`
* `superscript`
* `tables`

### References

* Markdown: <http://daringfireball.net/projects/markdown/syntax>
* Markdown PHP: <https://michelf.ca/projects/php-markdown/extra/>

## Maintainer

* [Nando Vieira](http://nandovieira.com.br)
* [Jesse Storimer](http://jstorimer.com)

## License

(The MIT License)

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
'Software'), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
