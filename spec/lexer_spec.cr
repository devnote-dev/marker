require "./spec_helper"

alias Lexer = Marker::Parser::CommonMark::Lexer
alias Type = Marker::Parser::CommonMark::Token::Type

describe Lexer do
  it "parses a heading" do
    tokens = Lexer.new("# This is a heading").run

    tokens[0].type.should eq Type::Heading
    tokens[0].value.should eq "#"
    tokens[1].type.should eq Type::Whitespace
    tokens[1].value.should eq " "
    tokens[2].type.should eq Type::Text
    tokens[2].value.should eq "This is a heading"
    tokens[3].type.should eq Type::EOF
    tokens[3].value.should be_empty
  end

  it "parses a paragraph/text" do
    tokens = Lexer.new("This is some text in a paragraph!").run

    tokens[0].type.should eq Type::Text
    tokens[0].value.should eq "This is some text in a paragraph!"
    tokens[1].type.should eq Type::EOF
    tokens[1].value.should be_empty
  end

  it "parses strong text" do
    tokens = Lexer.new("This is a paragraph with some **strong text**").run

    tokens[0].type.should eq Type::Text
    tokens[0].value.should eq "This is a paragraph with some "
    tokens[1].type.should eq Type::Strong
    tokens[1].value.should eq "**"
    tokens[2].type.should eq Type::Text
    tokens[2].value.should eq "strong text"
    tokens[3].type.should eq Type::Strong
    tokens[3].value.should eq "**"
    tokens[4].type.should eq Type::EOF
    tokens[4].value.should be_empty
  end

  it "parses emphasised text" do
    tokens = Lexer.new("There is _some emphasis_ in this text").run

    tokens[0].type.should eq Type::Text
    tokens[0].value.should eq "There is "
    tokens[1].type.should eq Type::Emphasis
    tokens[1].value.should eq "_"
    tokens[2].type.should eq Type::Text
    tokens[2].value.should eq "some emphasis"
    tokens[3].type.should eq Type::Emphasis
    tokens[3].value.should eq "_"
    tokens[4].type.should eq Type::Whitespace
    tokens[4].value.should eq " "
    tokens[5].type.should eq Type::Text
    tokens[5].value.should eq "in this text"
    tokens[6].type.should eq Type::EOF
    tokens[6].value.should be_empty
  end

  it "parses single-tick code spans" do
    tokens = Lexer.new("`a small code span`").run

    tokens[0].type.should eq Type::CodeSpan
    tokens[0].value.should eq "`a small code span`"
    tokens[1].type.should eq Type::EOF
    tokens[1].value.should be_empty
  end

  it "parses double-tick code spans" do
    tokens = Lexer.new("``a slightly bigger code span``").run

    tokens[0].type.should eq Type::CodeSpan
    tokens[0].value.should eq "``a slightly bigger code span``"
    tokens[1].type.should eq Type::EOF
    tokens[1].value.should be_empty
  end

  it "parses nested code spans" do
    tokens = Lexer.new("``this is a `nested code` span``").run

    tokens[0].type.should eq Type::CodeSpan
    tokens[0].value.should eq "``this is a `nested code` span``"
    tokens[1].type.should eq Type::EOF
    tokens[1].value.should be_empty
  end

  it "parses a tilde code block" do
    tokens = Lexer.new(<<-MD).run
    ~~~
    this is
      a pretty big
        code block
    ~~~
    MD

    tokens[0].type.should eq Type::CodeBlock
    tokens[0].value.should eq <<-MD
    ~~~
    this is
      a pretty big
        code block
    ~~~
    MD

    tokens[1].type.should eq Type::EOF
    tokens[1].value.should be_empty
  end

  it "parses a backtick code block" do
    tokens = Lexer.new(<<-MD).run
    ````
    this is
      a pretty big
        code block
    ````
    MD

    tokens[0].type.should eq Type::CodeBlock
    tokens[0].value.should eq <<-MD
    ````
    this is
      a pretty big
        code block
    ````
    MD

    tokens[1].type.should eq Type::EOF
    tokens[1].value.should be_empty
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

    tokens[0].type.should eq Type::CodeBlock
    tokens[0].value.should eq <<-MD
    ```crystal
    def fib(n : Int32) : Int32
      return 1 if n <= 1

      fib(n - 1) + fib(n - 2)
    end
    ```
    MD

    tokens[1].type.should eq Type::EOF
    tokens[1].value.should be_empty
  end

  pending "parses raw HTML elements" do
    tokens = Lexer.new(<<-HTML).run
    <!DOCTYPE html>
    <html lang="en">
    <head>
      <title>Marker • A new way to parse Markdown</title>
    </head>
    HTML

    tokens[0].type.should eq Type::HTMLBlock
    tokens[0].value.should eq "<!DOCTYPE html>"

    tokens[1].type.should eq Type::Newline
    tokens[1].value.should be_empty

    tokens[2].type.should eq Type::HTMLBlock
    tokens[2].value.should eq %(<html lang="en">)

    tokens[3].type.should eq Type::Newline
    tokens[3].value.should be_empty

    tokens[4].type.should eq Type::HTMLBlock
    tokens[4].value.should eq "<head>"

    tokens[5].type.should eq Type::Newline
    tokens[5].value.should be_empty

    tokens[6].type.should eq Type::Whitespace
    tokens[6].value.should eq "  "

    tokens[7].type.should eq Type::HTMLBlock
    tokens[7].value.should eq "<title>"

    tokens[8].type.should eq Type::Text
    tokens[8].value.should eq "Marker • A new way to parse Markdown"

    tokens[9].type.should eq Type::HTMLBlock
    tokens[9].value.should eq "</title>"

    tokens[10].type.should eq Type::Newline
    tokens[10].value.should eq be_empty

    tokens[11].type.should eq Type::HTMLBlock
    tokens[11].value.should eq "</head>"

    tokens[12].type.should eq Type::EOF
    tokens[12].value.should be_empty
  end
end
