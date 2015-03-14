## Creating Chapters

You can create chapters by having multiple files or directories. They're alphabetically sorted, so make sure you use a prefixed file name like  `01_Introduction.md` as the file name.

If you're going to write a long book, make sure you use the directory organization. This way you can have smaller text files, which will be easier to read and change as you go. A file structure suggestion for a book about [Ruby on Rails](http://guides.rubyonrails.com) would be:

```text
getting-started-with-rails
├── text
    └── 01_Guide_Assumptions.md
    └── 02_Whats_Rails.md
    └── 03_Creating_A_New_Project
        └── 01_Installing_Rails.md
        └── 02_Creating_The_Blog_Application.md
    └── 04_Hello_Rails
        └── 01_Starting_Up_The_Web_Server.md
        └── 02_Say_Hello_Rails.md
        └── 03_Setting_The_Application_Home_Page.md
    └── ...
```

Notice that the file name does not need to be readable, but it will make your life easier.
