## Exporting Files

You can generate files as you go. Just execute `kitabu export` from your book's
root directory.

```
$ kitabu export
** e-book has been exported
```

This command will generate all supported formats[^1]. The generated files will
be placed on your `output` directory; the following output list only the
relevant files.

```
$ tree output
output
├── fonts
├── images
│   ├── cover.png
│   ├── kitabu.svg
│   ├── markdown.svg
│   └── up.svg
├── sample.epub
├── sample.html
├── sample.mobi
├── sample.pdf
├── sample.pdf.html
├── sample.print.html
├── sample.print.pdf
└── styles
    ├── epub.css
    ├── files
    │   ├── normalize.css
    │   ├── notes.css
    │   └── toc.css
    ├── html.css
    ├── pdf.css
    └── print.css
```

This can take a while depending on your book size, but usually the process is
pretty fast. If you want to generate a specific format faster, provide the
`--only` flag.

```
$ kitabu export --only html
```

You can also automatically generate files when something changes. You can use
[Guard](http://rubygems.org/gems/guard) for this, and Kitabu even generates a
sample file for you. All you have to do is running `bundle exec guard`.

```
$ bundle exec guard
20:38:10 - INFO - Guard is now watching at 'kitabu/examples/kitabu'
** e-book has been exported
```

### Exporting PDF with DocRaptor

After exporting your files, upload the `output` directory somewhere and make it
available to the internet. Then you can even use curl to generate the pdf.

The command is fairly long, so I won't try to paste it here. You can see the
full command on the
[README of this project](https://github.com/fnando/kitabu#exporting-pdfs-with-docraptor).

[^1]: Depend on Prince and Calibre being available on your `$PATH`.
