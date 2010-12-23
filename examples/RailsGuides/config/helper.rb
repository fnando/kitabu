# Put any Ruby code in here.
# Here's an example on how you can extend RedCloth (Textile) with new formatters.
#
#   module RedCloth
#     module Formatters
#       module HTML
#         def attention(options)
#           %[<p class="attention">#{options[:text]}</p>]
#         end
#       end
#     end
#   end
#
# Then you can just use `attention. This is an important note!` on your text.
#
# You can add inline formatters as well. The approach is slightly different,
# but pretty straightforward.
#
# Add your formatter to `RedCloth::INLINE_FORMATTERS` and implement the method, making sure that it
# replaces the content using `String#gsub!`.
#
#   module RedCloth
#     def my_formatter(text)
#       text.gsub!(/Hello/, "Hi")
#     end
#   end
#
#   RedCloth::INLINE_FORMATTERS << :my_formatter
#