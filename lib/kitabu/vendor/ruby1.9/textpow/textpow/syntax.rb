# encoding: utf-8
module Textpow

   class SyntaxProxy
      def initialize hash, syntax
         @syntax = syntax
         @proxy = hash["include"]
      end
      
      def method_missing method, *args, &block
         if @proxy 
            @proxy_value = proxy unless @proxy_value
            if @proxy_value
               @proxy_value.send(method, *args, &block)
            else
               STDERR.puts "Failed proxying #{@proxy}.#{method}(#{args.join(', ')})"
            end
         end
      end
      
      def proxy
         case @proxy 
         when /^#/
            if @syntax.repository && @syntax.repository[@proxy[1..-1]]
               #puts "Repository"
               #@table["syntax"].repository.each_key{|k| puts k}
               return @syntax.repository[@proxy[1..-1]]
            end
         when "$self"
            return @syntax
         when "$base"
            return @syntax
         else
            return @syntax.syntaxes[@proxy]
         end
      end
   end

   class SyntaxNode
      #OPTIONS = {:options => Oniguruma::OPTION_CAPTURE_GROUP}
      
      @@syntaxes = {}
      
      attr_accessor :syntax
      attr_accessor :firstLineMatch
      attr_accessor :foldingStartMarker
      attr_accessor :foldingStopMarker
      attr_accessor :match
      attr_accessor :begin
      attr_accessor :content
      attr_accessor :fileTypes
      attr_accessor :name
      attr_accessor :contentName
      attr_accessor :end
      attr_accessor :scopeName
      attr_accessor :keyEquivalent
      attr_accessor :captures
      attr_accessor :beginCaptures
      attr_accessor :endCaptures
      attr_accessor :repository
      attr_accessor :patterns
      
      def self.load filename, name_space = :default
         table = nil
         case filename
         when /(\.tmSyntax|\.plist)$/
            table = Plist::parse_xml( filename )
         else
            File.open( filename ) do |f|
               table = YAML.load( f )
            end
         end
         if table
            SyntaxNode.new( table, nil, name_space )
         else
            nil
         end
      end
      
      def initialize hash, syntax = nil, name_space = :default
         @name_space = name_space
         @@syntaxes[@name_space] ||= {}
         @@syntaxes[@name_space][hash["scopeName"]] = self if hash["scopeName"]
         @syntax = syntax || self
         hash.each do |key, value|
            case key
            when "firstLineMatch", "foldingStartMarker", "foldingStopMarker", "match", "begin"
               begin
                    value.force_encoding("UTF-8")
                  instance_variable_set( "@#{key}", Regexp.new( value ) )
               rescue ArgumentError => e
                  raise ParsingError, "Parsing error in #{value}: #{e.to_s}"
               end
            when "content", "fileTypes", "name", "contentName", "end", "scopeName", "keyEquivalent"
               instance_variable_set( "@#{key}", value )
            when "captures", "beginCaptures", "endCaptures"
               instance_variable_set( "@#{key}", value.sort )
            when "repository"
               parse_repository value
            when "patterns"
               create_children value
            else
               STDERR.puts "Ignoring: #{key} => #{value.gsub("\n", "\n>>")}" if $DEBUG
            end
         end
      end
      
      
      def syntaxes
         @@syntaxes[@name_space]
      end
      
      def parse( string, processor = nil )
         processor.start_parsing self.scopeName if processor
         stack = [[self, nil]]
         string.each_line do |line|
            parse_line stack, line, processor
         end
         processor.end_parsing self.scopeName if processor
         processor
      end
      
      protected
    
      def parse_repository repository
         @repository = {}
         repository.each do |key, value|
            if value["include"]
               @repository[key] = SyntaxProxy.new( value, self.syntax )
            else
               @repository[key] = SyntaxNode.new( value, self.syntax, @name_space )
            end
         end
      end
      
      def create_children patterns
         @patterns = []
         patterns.each do |p|
            if p["include"]
               @patterns << SyntaxProxy.new( p, self.syntax )
            else
               @patterns << SyntaxNode.new( p, self.syntax, @name_space )
            end
         end
      end

      def parse_captures name, pattern, match, processor
         captures = pattern.match_captures( name, match )
         captures.reject! { |group, range, name| ! range.first || range.first == range.last }
         starts = []
         ends = []
         captures.each do |group, range, name|
            starts << [range.first, group, name]
            ends   << [range.last, -group, name]
         end
         
#          STDERR.puts '-' * 100
#          starts.sort!.reverse!.each{|c| STDERR.puts c.join(', ')}
#          STDERR.puts 
#          ends.sort!.reverse!.each{|c| STDERR.puts c.join(', ')}
         starts.sort!.reverse!
         ends.sort!.reverse!
         
         while ! starts.empty? || ! ends.empty?
            if starts.empty?
               pos, key, name = ends.pop
               processor.close_tag name, pos
            elsif ends.empty?
               pos, key, name = starts.pop
               processor.open_tag name, pos
            elsif ends.last[1].abs < starts.last[1]
               pos, key, name = ends.pop
               processor.close_tag name, pos
            else
               pos, key, name = starts.pop
               processor.open_tag name, pos
            end
         end
      end
      
      def match_captures name, match
         matches = []
         captures = instance_variable_get "@#{name}"
         if captures
            captures.each do |key, value|
               if key =~ /^\d*$/
                  matches << [key.to_i, match.offset( key.to_i ), value["name"]] if key.to_i < match.size
               else
                  matches << [match.to_index( key.to_sym ), match.offset( key.to_sym), value["name"]] if match.to_index( key.to_sym )
               end
            end
         end
         matches
      end
      
      def match_first string, position
         if self.match
            if match = self.match.match( string, position )
               return [self, match] 
            end
         elsif self.begin
            if match = self.begin.match( string, position )
               return [self, match] 
            end
         elsif self.end
         else
            return match_first_son( string, position )
         end
         nil
      end
      
      def match_end string, match, position
         regstring = self.end.clone
         regstring.gsub!( /\\([1-9])/ ) { |s| match[$1.to_i] }
         regstring.gsub!( /\\g<(.*?)>/ ) { |s| match[$1.to_sym] }
         Regexp.new( regstring ).match( string, position )
      end
      
      def match_first_son string, position
         match = nil
         if self.patterns
            self.patterns.each do |p|
               tmatch = p.match_first string, position
               if tmatch
                  if ! match || match[1].offset(0).first > tmatch[1].offset(0).first
                     match = tmatch
                  end
                  #break if tmatch[1].offset.first == position
               end
            end
         end
         match
      end
      
      def parse_line stack, line, processor
         processor.new_line line if processor
         top, match = stack.last
         position = 0
         #@ln ||= 0
         #@ln += 1
         #STDERR.puts @ln
         while true
            if top.patterns
               pattern, pattern_match = top.match_first_son line, position
            else
               pattern, pattern_match = nil
            end
            
            end_match = nil
            if top.end
               end_match = top.match_end( line, match, position )
            end
            
            if end_match && ( ! pattern_match || pattern_match.offset(0).first >= end_match.offset(0).first )
               pattern_match = end_match
               start_pos = pattern_match.offset(0).first
               end_pos = pattern_match.offset(0).last
               processor.close_tag top.contentName, start_pos if top.contentName && processor
               parse_captures "captures", top, pattern_match, processor if processor
               parse_captures "endCaptures", top, pattern_match, processor if processor
               processor.close_tag top.name, end_pos if top.name && processor
               stack.pop
               top, match = stack.last
            else
               break unless pattern
               start_pos = pattern_match.offset(0).first
               end_pos = pattern_match.offset(0).last
               if pattern.begin
                  processor.open_tag pattern.name, start_pos if pattern.name && processor
                  parse_captures "captures", pattern, pattern_match, processor if processor
                  parse_captures "beginCaptures", pattern, pattern_match, processor if processor
                  processor.open_tag pattern.contentName, end_pos if pattern.contentName && processor
                  top = pattern
                  match = pattern_match
                  stack << [top, match]
               elsif pattern.match
                  processor.open_tag pattern.name, start_pos if pattern.name && processor
                  parse_captures "captures", pattern, pattern_match, processor if processor
                  processor.close_tag pattern.name, end_pos if pattern.name && processor
               end
            end
            position = end_pos
         end
      end
   end
end
