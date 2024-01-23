# frozen_string_literal: true

EeePub::NCX.class_eval do
  def uid
    @uid[:id]
  end
end
