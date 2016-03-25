module Kitabu
  module ToSlim

    def self.render(file)
      Slim::Template.new("#{file}", {pretty:true}).render(self)
    end
  end
end
