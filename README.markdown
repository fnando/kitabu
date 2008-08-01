Kitabu
======

* [http://github.com/fnando/kitabu](http://github.com/fnando/kitabu)

DESCRIPTION:
------------

A framework for creating e-books from Markdown/Textile text markup using Ruby. 
Using the Prince PDF generator, you'll be able to get high quality PDFs.
Mac users that have [Textmate](http://macromates.com) installed can have source 
code highlighted with his/her favorite theme.

While Prince is too expensive (495USD for a single user license), the 
free version available at [http://www.princexml.com/download/](http://www.princexml.com/download/) generates
a PDF with a small logo on the first page, which is removed when sent
to a printer.

FEATURES:
---------

* Write PDF using Markdown or Textile text markup
* Book layout support
* Syntax highlight theme based on Textmate
* Generate a PDF with a single rake task
* Table of Contents automatically generated from chapter titles

SYNOPSIS:
---------

Create a new book with `kitabu mybook`. Kitabu has support for book
layout and syntax highlight theme. You can specify other settings:

	kitabu mybook --theme=mac_classic
	kitabu mybook --layout=boom

You can check available layouts and themes with `kitabu --help`

The `kitabu` command creates a directory "mybook" with the 
following structure:

- book
	- config.yml
	- images
	- output
	- Rakefile
	- templates
		- layout.css
		- layout.html
		- syntax.css
		- user.css
	- text

The `config.yml` file holds some information about your book; so you'll always
change it. This is the default generated file:

	title: [Your Book Title]
	copyright: Copyright (c) 2008 [Your Name], All Rights Reserved
	authors:
	  - [Your Name]
	  - [Other Name]
	subject: [Write down what your book is about]
	keywords: [The keywords related to your book]
	theme: eiffel

If you're writing on a different language, the `user.css` file can override all
the messages added by the `layout.css`. Examples on doing this coming soon.

Now it's time to write your book. All your book content will be placed on the
text directory. Kitabu requires you to separate your book into chapters. 
A chapter is nothing but a directory that holds lots of Markdown/Textile files.
The book will be generated using every folder/file alphabetically. So be sure 
to use a sequential numbering as the name. Here's a sample:

- text
	- 01_Introduction
		- 01\_introduction.markdown
	- 02\_What\_is\_Ruby\_on\_Rails
		- 01\_MVC.markdown
		- 02\_DRY.markdown
		- 03\_Convention\_Over\_Configuration.markdown
	- 03\_Installing\_Ruby\_on\_Rails
		- 01\_Installing.textile
		- 02\_Mac\_OS\_X\_instructions.textile
		- 03\_Windows\_instructions.markdown
		- 04\_Ubuntu\_Linux\_instructions.markdown

Note that you can use Textile or Markdown at the same time. Just use the 
`.markdown` or `.textile` file extension.

You'll want to see your progress eventually; it's time for you to generate
the book PDF. Just run the command `rake kitabu:pdf` and your book will be 
created on the output directory.

There are other rake tasks you can use:

* `kitabu:html` - generate a html from your content
* `kitabu:syntaxes` - list all available syntaxes
* `kitabu:themes` - list all available themes
* `kitabu:titles` - list all titles and its permalinks
* `kitabu:watch` - watch `text` for any change and automatically generate html

Kitabu can generate a Table of Contents (TOC) based on your h2-h6 tags. The 
h1 tag is discarded because it's meant to be the book title. 

If you need to link to a specific chapter, you can use the `kitabu:titles` rake
task to know what's the permalink that you need. For example, a title 
`Installing Mac OS X` will have a permalink `installing-mac-os-x` and you can
link to this chapter by writing
`"See more on Installing Mac OS X":#installing-mac-os-x` when using 
Textile.

To generate the TOC, you need to print a variable called `toc`, using the eRb
tag `<%= toc %>`.

Syntax Highlighting (Mac OS X)
==============================

If you're using Textile, all you need to do is use the tag `syntax.`. For 
example, to highlight a code added right into your text, just do something like

	syntax(ruby_on_rails). class User < ActiveRecord::Base
	  validates_presence_of :login, :password, :email
	__
	  validates_uniqueness_of :login, :email
	end

To keep multiple line breaks into a single code block, add a line `__`;
Kitabu will replace it when generating the HTML file.

If you want to highlight a file, you need to place it into the `code` 
directory and call it like this:

	syntax(ruby_on_rails). some_file.rb

You can specify the lines you want to highlight; the example below will 
highlight lines 10-17 from some_file.rb.

	syntax(ruby_on_rails 10,17). some_file.rb

You can also specify named blocks to highlight. Named blocks are identified
by `#begin` and `#end` marks. If some_file.rb has the following code

	require "rubygems"
	require "hpricot"
	require "open"

	# begin: get_all_h2_tags
	doc = Hpricot(open('http://simplesideias.com.br'))
	(doc/"h2").each {|h2| puts h2.inner_text }
	# end: get_all_h2_tags

you can get the code between `get_all_h2_tags` using

	syntax(ruby#get_all_h2_tags). some_file.rb

*Note:* Makdown uses the same syntax above. You just need to indent your code
(as usual) and add the `syntax.` thing as the first line.

INSTALL:
--------

You need to install some gems before you go any further.

	sudo gem install rubigen
	sudo gem install discount
	sudo gem install hpricot
	sudo gem install unicode

If you're a Mac user and have Textmate installed, you can
generate HTML from your source code with syntax highlight,
the same way you see in Textmate. First, you need to install
Oniguruma regular expression library that can be found at 
[http://www.geocities.jp/kosako3/oniguruma/](http://www.geocities.jp/kosako3/oniguruma/)

Then, you need to install the Ultraviolet gem.

	sudo gem install ultraviolet
	
After installing these dependencies, download the latest version:
	
	git clone git://github.com/fnando/kitabu.git
	sudo gem install newgem
	cd kitabu
	rake install_gem

or

	curl -O http://f.simplesideias.com.br/kitabu-latest.gem
	sudo gem install kitabu

REFERENCES:
-----------

- Textile: [http://hobix.com/textile/](http://hobix.com/textile/)
- Markdown: [http://daringfireball.net/projects/markdown/syntax](http://daringfireball.net/projects/markdown/syntax)

MAINTAINER
----------
 
* Nando Vieira ([http://simplesideias.com.br](http://simplesideias.com.br))

LICENSE:
--------

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