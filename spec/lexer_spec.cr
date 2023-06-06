require "./spec_helper"

alias Lexer = Marker::CommonMark::Lexer
alias Kind = Marker::CommonMark::Token::Kind

describe Lexer do
  it "parses a heading" do
    tokens = Lexer.new("# This is a heading").run

    tokens[0].kind.should eq Kind::Heading
    tokens[0].value.should eq "#"
    tokens[1].kind.should eq Kind::Space
    tokens[1].value.should eq " "
    tokens[2].kind.should eq Kind::Text
    tokens[2].value.should eq "This is a heading"
    tokens[3].kind.should eq Kind::EOF
  end

  it "parses a paragraph/text" do
    tokens = Lexer.new("This is some text in a paragraph!").run

    tokens[0].kind.should eq Kind::Text
    tokens[0].value.should eq "This is some text in a paragraph!"
    tokens[1].kind.should eq Kind::EOF
  end

  it "parses strong text" do
    tokens = Lexer.new("This is a paragraph with some **strong text**").run

    tokens[0].kind.should eq Kind::Text
    tokens[0].value.should eq "This is a paragraph with some "
    tokens[1].kind.should eq Kind::Strong
    tokens[2].kind.should eq Kind::Text
    tokens[2].value.should eq "strong text"
    tokens[3].kind.should eq Kind::Strong
    tokens[4].kind.should eq Kind::EOF
  end

  it "parses emphasised text" do
    tokens = Lexer.new("There is _some emphasis_ in this text").run

    tokens[0].kind.should eq Kind::Text
    tokens[0].value.should eq "There is "
    tokens[1].kind.should eq Kind::Emphasis
    tokens[2].kind.should eq Kind::Text
    tokens[2].value.should eq "some emphasis"
    tokens[3].kind.should eq Kind::Emphasis
    tokens[4].kind.should eq Kind::Space
    tokens[4].value.should eq " "
    tokens[5].kind.should eq Kind::Text
    tokens[5].value.should eq "in this text"
    tokens[6].kind.should eq Kind::EOF
  end

  it "parses single-tick code spans" do
    tokens = Lexer.new("`a small code span`").run

    tokens[0].kind.should eq Kind::CodeSpan
    tokens[0].value.should eq "`a small code span`"
    tokens[1].kind.should eq Kind::EOF
  end

  it "parses double-tick code spans" do
    tokens = Lexer.new("``a slightly bigger code span``").run

    tokens[0].kind.should eq Kind::CodeSpan
    tokens[0].value.should eq "``a slightly bigger code span``"
    tokens[1].kind.should eq Kind::EOF
  end

  it "parses nested code spans" do
    tokens = Lexer.new("``this is a `nested code` span``").run

    tokens[0].kind.should eq Kind::CodeSpan
    tokens[0].value.should eq "``this is a `nested code` span``"
    tokens[1].kind.should eq Kind::EOF
  end

  it "parses a tilde code block" do
    tokens = Lexer.new(<<-MD).run
      ~~~
      this is
        a pretty big
          code block
      ~~~
      MD

    tokens[0].kind.should eq Kind::CodeBlock
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
    tokens = Lexer.new(<<-MD).run
      ````
      this is
        a pretty big
          code block
      ````
      MD

    tokens[0].kind.should eq Kind::CodeBlock
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
    tokens = Lexer.new(<<-MD).run
      ```crystal
      def fib(n : Int32) : Int32
        return 1 if n <= 1

        fib(n - 1) + fib(n - 2)
      end
      ```
      MD

    tokens[0].kind.should eq Kind::CodeBlock
    tokens[0].value.should eq <<-MD
      ```crystal
      def fib(n : Int32) : Int32
        return 1 if n <= 1

        fib(n - 1) + fib(n - 2)
      end
      ```
      MD

    tokens[1].kind.should eq Kind::EOF
  end

  it "parses raw HTML elements" do
    tokens = Lexer.new(<<-HTML).run
      <!DOCTYPE html>
      <html lang="en">
      <head>
        <title>Marker • A new way to parse Markdown</title>
      </head>
      HTML

    tokens[0].kind.should eq Kind::HTMLBlock
    tokens[0].value.should eq "<!DOCTYPE html>"
    tokens[1].kind.should eq Kind::Newline
    tokens[2].kind.should eq Kind::HTMLBlock
    tokens[2].value.should eq %(<html lang="en">)
    tokens[3].kind.should eq Kind::Newline
    tokens[4].kind.should eq Kind::HTMLBlock
    tokens[4].value.should eq "<head>"
    tokens[5].kind.should eq Kind::Newline
    tokens[6].kind.should eq Kind::Space
    tokens[6].value.should eq "  "
    tokens[7].kind.should eq Kind::HTMLBlock
    tokens[7].value.should eq "<title>"
    tokens[8].kind.should eq Kind::Text
    tokens[8].value.should eq "Marker • A new way to parse Markdown"
    tokens[9].kind.should eq Kind::HTMLBlock
    tokens[9].value.should eq "</title>"
    tokens[10].kind.should eq Kind::Newline
    tokens[11].kind.should eq Kind::HTMLBlock
    tokens[11].value.should eq "</head>"
    tokens[12].kind.should eq Kind::EOF
  end
end
