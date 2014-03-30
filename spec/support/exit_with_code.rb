RSpec::Matchers.define :exit_with_code do |code|
  actual = nil

  match do |block|
    begin
      block.call
    rescue SystemExit => e
      actual = e.status
    end

    actual && actual == code
  end

  failure_message do |block|
    "expected block to call exit(#{code}) but exit" +
    (actual ? "(#{actual}) was called" : " not called")
  end

  failure_message_when_negated do |block|
    "expected block not to call exit(#{code})"
  end

  description do
    "expect block to call exit(#{code})"
  end
end
