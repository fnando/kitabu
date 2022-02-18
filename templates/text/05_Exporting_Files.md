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
├── images
│   ├── kitabu.png
│   └── kitabu.svg
├── kitabu.epub
├── kitabu.html
├── kitabu.mobi
├── kitabu.pdf
├── kitabu.print.pdf
└── styles
    ├── epub.css
    ├── html.css
    ├── pdf.css
    └── print.css
```

This can take a while depending on your book size, but usually the process is
pretty fast. If you want to generate a specific format faster, provide the
`--only` flag.

```
$ kitabu export --only pdf
```

You can also automatically generate files when something changes. You can use
[Guard](http://rubygems.org/gems/guard) for this, and Kitabu even generates a
sample file for you. All you have to do is running `bundle exec guard`.

```
$ bundle exec guard
20:38:10 - INFO - Guard is now watching at '/Users/fnando/Projects/kitabu/examples/kitabu'
** e-book has been exported
```

### Exporting PDF with DocRaptor

After exporting your files (you can use `--only pdf` for this), upload files to
somewhere public, possibly your [Dropbox](http://dropbox.com) account. You can
even use curl; since the command is quite long, you can view it at
<https://gist.github.com/fnando/de555a08e7aab14a661a>.

[^1]: Depend on Prince and Calibre being available on your `$PATH`.
