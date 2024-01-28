# frozen_string_literal: true

module Kitabu
  class Context
    def self.create(locals)
      new.create(locals)
    end

    def create(locals)
      @__context = OpenStruct.new(locals).extend(Helpers)
      @__context.instance_eval { binding }
    end
  end
end
