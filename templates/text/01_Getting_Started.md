## Getting Started

This guide is designed for beginners who want to get started with Kitabu from scratch. However, to get the most out of it, you need to have some prerequisites installed:

* The [Ruby](http://ruby-lang.org) interpreter version 2.0.0 or greater.
* The [PrinceXML](http://princexml.com) converter version 9.0 or greater.
* The [KindleGen](http://www.amazon.com/gp/feature.html?docId=1000765211) converter.

### Installing Ruby

To install Ruby, consider using [RVM](http://rvm.io) or [rbenv](http://rbenv.org), both available for Mac OSX and Linux distros. If you're running a Windows, well, I can't help you. I don't even know if Kitabu runs over Windows boxes, so if you find any bugs, make sure you [let me know](http://github.com/fnando/kitabu/issues).

### Installing PrinceXML

[PrinceXML](http://princexml.com) is the best HTML to PDF converter available. You can use advanced CSS features to style your book in any way you want. But good things don't come for free, and PrinceXML is no exception. The Professional License, which you grant you a installation on a single computer by a single user costs 495USD. If you don't like the price tag, consider using [DocRaptor](http://docraptor.com) when you're ready to publish your book.

To install PrinceXML, go to the website and download the correct version for your platform; you can choose from Mac OSX, to Linux and Windows.

### Installing KindleGen

KindleGen is the command-line tool that allows you to convert e-pubs into `.mobi` files. You can't sell these files, though.[^1] So if that's the case, consider using [Calibre](http://calibre-ebook.com/) for this task.[^2]

If you're running [Homebrew](http://brew.sh) on the Mac OSX, you can install it with `brew install kindlegen`. Go to [KindleGen's website](http://www.amazon.com/gp/feature.html?docId=1000765211) and download the appropriate installer otherwise.

[^1]: You can, but that would be a violation of Amazon's terms of use.
[^2]: Calibre is not perfect, but does a good job.
