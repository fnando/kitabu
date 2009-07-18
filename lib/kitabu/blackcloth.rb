class BlackCloth < RedCloth
  @@syntax_blocks = []
  
  FN_RE = /
    (\s+)?    # getting spaces
    %\{       # opening
    (.*?)     # footnote
    \}#       # closing
  /xms
  
  # Usage: Writing some text with a footnote %{this is a footnote}
  def inline_textile_fn(text)
    text.gsub!( FN_RE )  do |m|
      %(<span class="footnote">#{$2}</span>)
    end
    
    text
  end
  
  FN_URL_LINK = /
    <
    ((?:https?|ftp):\/\/.*?)
    >
  /x
  
  # Usage: <http://google.com>
  def inline_textile_url_link(text)
    text.gsub!( FN_URL_LINK ) do |m|
      %(<a href="#{$1}">#{$1}</a>)
    end
  end
  
  # Usage:
  # file. app/models/users.rb
  #
  # Remember to set `base_url` in your Kitabu configuration file
  def textile_file(tag, attrs, cite, content)
    base_url = Kitabu::Base.config["base_url"]
    
    if base_url
      url = File.join(base_url, content)
    else
      url = content
      puts "\nYou're using `file. #{content}` but didn't set base_url in your configuration file.\n"
    end
    
    %(<p class="file"><span><strong>Download</strong> <a href="#{url}">#{content}</a></span></p>)
  end
  
  # Usage:
  # syntax(ruby). Some code
  #
  # getting from line 100 to 200 of file.rb
  # syntax(ruby 100,200). file.rb
  #
  # getting block 'sample' from file.rb
  # syntax(ruby#sample). file.rb
  #
  # to create a block:
  # #begin: sample
  #   some code
  # #end: sample
  def textile_syntax(tag, attrs, cite, content)
    # get syntax
    m, syntax = *attrs.match(/class="(.*?)([# ].*?)?"/)
    syntax = 'plain_text' if tag == "pre"
    
    # set source
    source_file = content
    
    # get block name
    m, block_name = *attrs.match(/id="(.*?)"/ms)
    
    # get line interval
    m, from_line, to_line = *attrs.match(/class=".*? ([0-9]+),([0-9]+)"/)
    
    content = Kitabu::Markup.content_for({
      :code => content,
      :syntax => syntax,
      :source_file => source_file,
      :block_name => block_name,
      :from_line => from_line,
      :to_line => to_line
    })
    @@syntax_blocks << [syntax, content]
    position = @@syntax_blocks.size - 1
    %(@syntax:#{position})
  end
  
  def syntax_blocks
    @@syntax_blocks
  end
  
  # Usage: pre. Some code
  def textile_pre(*args)
    # Should I add the default theme as a class?
    send(:textile_syntax, *args)
  end
  
  # Usage: note. Some text
  def textile_note(tag, attrs, cite, content)
    %(<p class="note">#{content}</p>)
  end
  
  # Usage: figure(This is the caption). some_image.jpg
  def textile_figure(tag, attrs, cite, content)
    m, title = *attrs.match(/class="(.*?)"/)
    %(<p class="figure"><img src="../images/#{content}" alt="#{title}" /><br/><span class="caption">#{title}</span></p>)
  end
  
  # overriding inline method
  def inline( text ) 
    @rules += [:inline_textile_fn, :inline_textile_url_link]
    super
  end
  
  # overriding to_html method
  def to_html( *rules )
      rules = DEFAULT_RULES if rules.empty?
      # make our working copy
      text = self.dup
      
      @urlrefs = {}
      @shelf = []
      textile_rules = [:refs_textile, :block_textile_table, :block_textile_lists,
                       :block_textile_prefix, :inline_textile_image, :inline_textile_link,
                       :inline_textile_code, :inline_textile_span, :glyphs_textile]
      markdown_rules = [:refs_markdown, :block_markdown_setext, :block_markdown_atx, :block_markdown_rule,
                        :block_markdown_bq, :block_markdown_lists, 
                        :inline_markdown_reflink, :inline_markdown_link]
      @rules = rules.collect do |rule|
          case rule
          when :markdown
              markdown_rules
          when :textile
              textile_rules
          else
              rule
          end
      end.flatten

      # standard clean up
      incoming_entities text 
      clean_white_space text 

      # start processor
      @pre_list = []
      rip_offtags text
      no_textile text
      hard_break text 
      unless @lite_mode
          refs text
          blocks text
      end
      inline text
      smooth_offtags text

      retrieve text

      text.gsub!( /<\/?notextile>/, '' )
      text.gsub!( /x%x%/, '&#38;' )
      clean_html text if filter_html
      text.strip!
      text

  end
end