# frozen_string_literal: true

module SpecHelper
  def tmpdir
    TMPDIR
  end

  def capture(stream)
    begin
      stream = stream.to_s
      eval "$#{stream} = StringIO.new" # rubocop:disable Security/Eval, Style/EvalWithLocation
      yield
      result = eval("$#{stream}").string # rubocop:disable Security/Eval, Style/EvalWithLocation
    ensure
      eval "$#{stream} = #{stream.upcase}" # rubocop:disable Security/Eval, Style/EvalWithLocation
    end

    result
  end
end
