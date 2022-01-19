# frozen_string_literal: true

module Kitabu
  class Dependency
    def self.kindlegen?
      @kindlegen ||= `which kindlegen` && $CHILD_STATUS.success?
    end

    def self.prince?
      @prince ||= `which prince` && $CHILD_STATUS.success?
    end

    def self.html2text?
      @html2text ||= `which html2text` && $CHILD_STATUS.success?
    end
  end
end
