# frozen_string_literal: true

module Kitabu
  class Hook
    # The hook name.
    attr_reader :name

    # The block that will be called with the data for that hook.
    attr_reader :callback

    def initialize(hook, &block)
      @hook = hook
      @callback = block
    end
  end
end
