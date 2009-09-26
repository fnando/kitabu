module ExitMatcher
  class ExitWithStatus
    attr_reader :expected
    attr_reader :actual
    
    def initialize(expected)
      @expected = expected
    end
    
    def matches?(given_proc)
      status = nil
      
      begin
        given_proc.call
      rescue SystemExit
        status = $!.status
      end
      
      @actual = status
      
      @actual == @expected
    end
    
    def failure_message_for_should
      if actual.nil?
        "expected block to exit with #{expected.inspect} status, but didn't exit"
      else
        "expected block to exit with #{expected.inspect} status, but did it with #{actual.inspect}"
      end
    end
    
    def failure_message_for_should_not
      "expected block to not exit with #{actual.inspect} status, but did it"
    end
    
    private
      def negative_expectation?
        caller.first(3).find { |s| s =~ /should_not/ }
      end
  end
  
  def exit_with(expected)
    ExitWithStatus.new(expected)
  end
end
