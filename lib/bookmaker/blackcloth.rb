class BlackCloth < RedCloth
  attr_accessor :escape_html
  alias htmlesc_original htmlesc
  
  def initialize(*args)
    @escape_html = false
    super
  end
  
  def textile_syntax(tag, attrs, cite, content)
    # get syntax
    m, syntax = *attrs.match(/class="(.*?)([# ].*?)?"/)
    
    # set source
    source_file = content
    
    # get block name
    m, block_name = *attrs.match(/id="(.*?)"/ms)
    
    # get line interval
    m, from_line, to_line = *attrs.match(/class=".*? ([0-9]+),([0-9]+)"/)

    code = Bookmaker::Markup.syntax({
      :code => content,
      :syntax => syntax,
      :source_file => source_file,
      :block_name => block_name,
      :from_line => from_line,
      :to_line => to_line
    })
    
    code
  end
  
  def textile_pre(tag, attrs, cite, content)
    %(<pre class="#{Bookmaker::Base.default_theme}">#{content}</pre>)
  end
  
  def htmlesc(str, mode)
    if @escape_html
      htmlesc_original(str, mode)
    else
      str
    end
  end
end