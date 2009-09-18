module Textpow
   class ScoreManager
      POINT_DEPTH    = 4
      NESTING_DEPTH  = 40
      START_VALUE    = 2 ** ( POINT_DEPTH * NESTING_DEPTH )
      BASE           = 2 ** POINT_DEPTH
      
      def initialize
         @scores = {}
      end
      
      def score search_scope, reference_scope
         max = 0
         search_scope.split( ',' ).each do |scope|
            arrays = scope.split(/\B-/)
            if arrays.size == 1
               max = [max, score_term( arrays[0], reference_scope )].max
            elsif arrays.size > 1
               excluded = false
               arrays[1..-1].each do |a| 
                  if score_term( arrays[1], reference_scope ) > 0
                     excluded = true
                     break
                  end
               end
               max = [max, score_term( arrays[0], reference_scope )].max unless excluded
            else
               raise ParsingError, "Error in scope string: '#{search_scope}' #{arrays.size} is not a valid number of operands" if arrays.size < 1
            end
         end
         max
      end   
      
      private
      
      def score_term search_scope, reference_scope
         unless @scores[reference_scope] && @scores[reference_scope][search_scope]
            @scores[reference_scope] ||= {}
            @scores[reference_scope][search_scope] = score_array( search_scope.split(' '), reference_scope.split( ' ' ) )
         end
         @scores[reference_scope][search_scope]
      end
      
      def score_array search_array, reference_array
         pending = search_array
         current = reference_array.last
         reg = Regexp.new( "^#{Regexp.escape( pending.last )}" )
         multiplier = START_VALUE
         result = 0
         while pending.size > 0 && current
            if reg =~ current
               point_score = (2**POINT_DEPTH) - current.count( '.' ) + Regexp.last_match[0].count( '.' )
               result += point_score * multiplier
               pending.pop
               reg = Regexp.new( "^#{Regexp.escape( pending.last )}" ) if pending.size > 0
            end
            multiplier = multiplier / BASE
            reference_array.pop
            current = reference_array.last
         end
         result = 0 if pending.size > 0
         result
      end
   end
end
