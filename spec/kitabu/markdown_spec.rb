require 'spec_helper'

describe Kitabu::Markdown do
  it 'enables fenced code blocks' do
    html = Kitabu::Markdown.render <<-TEXT.strip_heredoc
      ```ruby
      class User
      end
      ```
    TEXT

    expect(html).to include('<pre class="highlight ruby">')
  end

  it 'enables options' do
    html = Kitabu::Markdown.render <<-TEXT.strip_heredoc
    ```php?start_inline=true
    echo 'Hello';
    ```
    TEXT

    expect(html).to include('<span class="k">echo</span>')
  end
end
