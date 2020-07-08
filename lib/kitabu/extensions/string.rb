# frozen_string_literal: false

class String
  def to_permalink
    str = dup.unicode_normalize(:nfkd)
    str = str.gsub(/[^\x00-\x7F]/, "").to_s
    str.gsub!(/[^-\w]+/xim, "-")
    str.gsub!(/-+/xm, "-")
    str.gsub!(/^-?(.*?)-?$/, '\1')
    str.downcase!
    str
  end
end
