require "./spec_helper"

describe Marker::Lexer do
  it "lexes general tokens" do
    assert_tokens "", :eof

    assert_tokens "\n", :newline, :eof
    assert_tokens "\r\n", :newline, :eof
    assert_tokens "\r\n\r\n", :newline, :eof

    assert_tokens " ", :space, :eof
    assert_tokens "          ", :space, :eof
    assert_tokens "\r\n          \r\n", :newline, :space, :newline, :eof

    assert_tokens %{\\=-.~*_[]()"':!},
      :escape, :equal, :list_item, :period, :tilde,
      :asterisk, :underscore, :left_bracket, :right_bracket,
      :left_paren, :right_paren, :quote, :quote, :colon, :bang, :eof
  end

  it "lexes thematic breaks" do
    assert_tokens "---", :thematic_break, :eof
    assert_tokens "___", :thematic_break, :eof
    assert_tokens "***", :thematic_break, :eof
    assert_tokens "------------", :thematic_break, :eof
    assert_tokens "_____", :thematic_break, :eof
    assert_tokens "*********", :thematic_break, :eof
  end

  it "lexes ATX headings" do
    assert_tokens "#", :text, :eof
    assert_tokens "# ", :atx_heading, :space, :eof
    assert_tokens "## ", :atx_heading, :space, :eof
    assert_tokens "### ", :atx_heading, :space, :eof
    assert_tokens "#### ", :atx_heading, :space, :eof
    assert_tokens "##### ", :atx_heading, :space, :eof
    assert_tokens "###### ", :atx_heading, :space, :eof
    assert_tokens "####### ", :text, :space, :eof
  end

  it "lexes setext headings" do
    assert_tokens "==", :equal, :equal, :eof
    assert_tokens "===", :setext_heading, :eof
    assert_tokens "===========", :setext_heading, :eof
  end

  it "lexes fence blocks" do
    assert_tokens "``", :code_span, :eof
    assert_tokens "```", :fence_block, :eof
    assert_tokens "``````````", :fence_block, :eof
    assert_tokens "~~", :tilde, :tilde, :eof
    assert_tokens "~~~", :fence_block, :eof
    assert_tokens "~~~~~~~~~~", :fence_block, :eof
  end

  it "lexes HTML tokens" do
    assert_tokens "</>", :left_angle, :html_close_tag, :eof
    assert_tokens "<!>", :html_directive, :right_angle, :eof
    assert_tokens "<!---->", :html_open_comment, :html_close_comment, :eof
  end

  it "lexes plain text" do
    tokens = lex "foo bar baz"

    tokens.size.should eq 2
    tokens[0].kind.should eq Kind::Text
    tokens[0].value.should eq "foo bar baz"
    tokens[1].kind.should eq Kind::EOF
  end

  it "parses single-tick code spans" do
    tokens = lex "`a small code span`"

    tokens.size.should eq 2
    tokens[0].kind.should eq Kind::CodeSpan
    tokens[0].value.should eq "`a small code span`"
    tokens[1].kind.should eq Kind::EOF
  end

  it "parses double-tick code spans" do
    tokens = lex "``a slightly bigger code span``"

    tokens.size.should eq 2
    tokens[0].kind.should eq Kind::CodeSpan
    tokens[0].value.should eq "``a slightly bigger code span``"
    tokens[1].kind.should eq Kind::EOF
  end

  it "parses nested code spans" do
    tokens = lex "``this is a `nested code` span``"

    tokens.size.should eq 2
    tokens[0].kind.should eq Kind::CodeSpan
    tokens[0].value.should eq "``this is a `nested code` span``"
    tokens[1].kind.should eq Kind::EOF
  end

  it "parses a tilde code block" do
    tokens = lex <<-MD
      ~~~
      this is
        a pretty big
          code block
      ~~~
      MD

    tokens.size.should eq 2
    tokens[0].kind.should eq Kind::FenceBlock
    tokens[0].value.should eq <<-MD
      ~~~
      this is
        a pretty big
          code block
      ~~~
      MD

    tokens[1].kind.should eq Kind::EOF
  end

  it "parses a backtick code block" do
    tokens = lex <<-MD
      ````
      this is
        a pretty big
          code block
      ````
      MD

    tokens.size.should eq 2
    tokens[0].kind.should eq Kind::FenceBlock
    tokens[0].value.should eq <<-MD
      ````
      this is
        a pretty big
          code block
      ````
      MD

    tokens[1].kind.should eq Kind::EOF
  end

  it "parses a language code block" do
    tokens = lex <<-MD
      ```
      def fib(n : Int32) : Int32
        return 1 if n <= 1

        fib(n - 1) + fib(n - 2)
      end
      ```
      MD

    tokens.size.should eq 2
    tokens[0].kind.should eq Kind::FenceBlock
    tokens[0].value.should eq <<-MD
      ```
      def fib(n : Int32) : Int32
        return 1 if n <= 1

        fib(n - 1) + fib(n - 2)
      end
      ```
      MD

    tokens[1].kind.should eq Kind::EOF
  end

  # TODO: reimplement stricter HTML tokens
  #
  # it "parses raw HTML elements" do
  #   tokens = Lexer.new(<<-HTML).run
  #     <!DOCTYPE html>
  #     <html lang="en">
  #     <head>
  #       <title>Marker • A new way to parse Markdown</title>
  #     </head>
  #     HTML

  #   tokens[0].kind.should eq Kind::HTMLBlock
  #   tokens[0].value.should eq "<!DOCTYPE html>"
  #   tokens[1].kind.should eq Kind::Newline
  #   tokens[2].kind.should eq Kind::HTMLBlock
  #   tokens[2].value.should eq %(<html lang="en">)
  #   tokens[3].kind.should eq Kind::Newline
  #   tokens[4].kind.should eq Kind::HTMLBlock
  #   tokens[4].value.should eq "<head>"
  #   tokens[5].kind.should eq Kind::Newline
  #   tokens[6].kind.should eq Kind::Space
  #   tokens[6].value.should eq "  "
  #   tokens[7].kind.should eq Kind::HTMLBlock
  #   tokens[7].value.should eq "<title>"
  #   tokens[8].kind.should eq Kind::Text
  #   tokens[8].value.should eq "Marker • A new way to parse Markdown"
  #   tokens[9].kind.should eq Kind::HTMLBlock
  #   tokens[9].value.should eq "</title>"
  #   tokens[10].kind.should eq Kind::Newline
  #   tokens[11].kind.should eq Kind::HTMLBlock
  #   tokens[11].value.should eq "</head>"
  #   tokens[12].kind.should eq Kind::EOF
  # end
end
