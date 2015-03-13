module Kitabu
  class Dependency
    def self.kindlegen?
      @kindlegen ||= `which kindlegen` && $?.success?
    end

    def self.prince?
      @prince ||= `which prince` && $?.success?
    end

    def self.html2text?
      @html2text ||= `which html2text` && $?.success?
    end
  end
end
