class String
  def to_permalink
    str = ActiveSupport::Multibyte::Chars.new(self.dup)
    str = str.normalize(:kd).gsub(/[^\x00-\x7F]/,'').to_s
    str.gsub!(/[^-\w\d]+/xim, "-")
    str.gsub!(/-+/xm, "-")
    str.gsub!(/^-?(.*?)-?$/, '\1')
    str.downcase!
    str
  end
end
