# frozen_string_literal: true

module Kitabu
  class Dependency
    def self.calibre?
      @calibre ||= `which ebook-convert` && $CHILD_STATUS.success?
    end

    def self.prince?
      @prince ||= `which prince` && $CHILD_STATUS.success?
    end

    def self.linux?
      RUBY_PLATFORM.include?("linux")
    end

    def self.macos?
      RUBY_PLATFORM.include?("darwin")
    end
  end
end
