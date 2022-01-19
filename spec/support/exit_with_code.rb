# frozen_string_literal: true

RSpec::Matchers.define :exit_with_code do |code|
  actual = nil

  match do |block|
    begin
      block.call
    rescue SystemExit => error
      actual = error.status
    end

    actual && actual == code
  end

  failure_message do |_block|
    "expected block to call exit(#{code}) but exit" +
      (actual ? "(#{actual}) was called" : " not called")
  end

  failure_message_when_negated do |_block|
    "expected block not to call exit(#{code})"
  end

  description do
    "expect block to call exit(#{code})"
  end
end
