= bookmaker

* http://rbookmaker.rubyforge.org

== DESCRIPTION:

A framework for creating ebooks from Markdown text markup using Ruby. 
Using the Prince PDF generator, you'll be able to get high quality PDFs.
Mac users that have Textmate installed can have source code highlighted 
with his/her favorite theme.

While Prince is too expensive (495USD for a single user license), the 
free version available at http://www.princexml.com/download/ generates
a PDF with a small logo on the first page, which is removed when sent
to a printer.

== FEATURES/PROBLEMS:

* Write PDF using Markdown text markup
* Support book layout
* Support syntax highlight theme 
* Generate a PDF with a single rake task

== SYNOPSIS:

Create a new book with `bookmaker mybook`. Bookmaker has support for book
layout and syntax highlight theme. You can specify other settings:

bookmaker mybook --theme=mac_classic
bookmaker mybook --layout=boom

You can check available layouts and themes with `bookmaker --help`

The `bookmaker` command creates a directory "mybook" with the 
following structure:

+ book
	- config.yml
	- images
	- output
	- Rakefile
	+ templates
		- layout.css
		- layout.html
		- syntax.css
		- user.css
	- text

The config.yml file holds some information about your book; so you'll always
change it. This is the default generated file:

		title: [Your Book Title]
		copyright: Copyright (c) 2008 [Your Name], All Rights Reserved
		authors:
		  - [Your Name]
		  - [Other Name]
		theme: eiffel

If you're writing on a different language, the user.css file can override all
the messages added by the layout.css. Examples on doing this coming soon.

Now it's time to write your book. All your book content will be placed on the
text directory. Bookmaker requires you to separate your book into chapters. 
A chapter is nothing but a directory that holds lots of Markdown files. The book
will be generated using every folder/file alphabetically. So be sure to use
a sequential numbering as the name. Here's a sample:

+ text
	+ 01_Introduction
		- 01_introduction.markdown
	+ 02_What_is_Ruby_on_Rails
		- 01_MVC.markdown
		- 02_DRY.markdown
		- 03_Convention_Over_Configuration.markdown

For now, Bookmaker accepts only Markdown, but I'm working on Textile support.

You'll want to see your progress eventually; it's time for your to generate
the book PDF. Just run the command `rake pdf` and your book will be created on
the output directory.

== INSTALL:

You need to install some gems before you go any further.

sudo gem install discount

If you're a Mac user and have Textmate installed, you can
generate HTML from your source code with syntax highlight,
the same way you see in Textmate. First, you need to install
Oniguruma regular expression library that can be found at:

http://www.geocities.jp/kosako3/oniguruma/

Then, you need to install the Ultraviolet gem.

sudo gem install ultraviolet

== LICENSE:

(The MIT License)

Copyright (c) 2008 Nando Vieira

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