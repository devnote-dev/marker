# TODO: move into /common_mark/
require "./spec_helper"

describe Parser do
  describe CMark::Heading do
    it "parses headings" do
      nodes = parse("# a heading")

      nodes.size.should eq 1
      nodes[0].should be_a CMark::Heading
      heading = nodes[0].as(CMark::Heading)

      heading.level.should eq 1
      heading.value.size.should eq 1
      heading.value[0].should be_a CMark::Text
      heading.value[0].as(CMark::Text).value.should eq "a heading"
    end

    it "parses multi-level headings" do
      nodes = parse("##### something")

      nodes.size.should eq 1
      nodes[0].should be_a CMark::Heading
      heading = nodes[0].as(CMark::Heading)

      heading.level.should eq 5
      heading.value.size.should eq 1
      heading.value[0].should be_a CMark::Text
      heading.value[0].as(CMark::Text).value.should eq "something"
    end

    it "parses invalid headings as paragraphs" do
      nodes = parse("#not a heading")

      nodes.size.should eq 1
      nodes[0].should be_a CMark::Paragraph
      para = nodes[0].as(CMark::Paragraph)

      para.value.size.should eq 2
      para.value[0].should be_a CMark::Text
      para.value[0].as(CMark::Text).value.should eq "#"
      para.value[1].should be_a CMark::Text
      para.value[1].as(CMark::Text).value.should eq "not a heading"
    end

    it "parses exceeding headings as paragraphs" do
      nodes = parse("###### something")

      nodes.size.should eq 1
      nodes[0].should be_a CMark::Paragraph
      para = nodes[0].as(CMark::Paragraph)

      para.value.size.should eq 3
      para.value[0].should be_a CMark::Text
      para.value[0].as(CMark::Text).value.should eq "######"
      para.value[1].should be_a CMark::Text
      para.value[1].as(CMark::Text).value.should eq " "
      para.value[2].should be_a CMark::Text
      para.value[2].as(CMark::Text).value.should eq "something"
    end
  end

  describe CMark::Paragraph do
    it "parses single paragraphs" do
      nodes = parse("foo bar baz")

      nodes.size.should eq 1
      nodes[0].should be_a CMark::Paragraph
      para = nodes[0].as(CMark::Paragraph)

      para.value.size.should eq 1
      para.value[0].should be_a CMark::Text
      para.value[0].as(CMark::Text).value.should eq "foo bar baz"
    end

    it "parses multiline paragraphs" do
      nodes = parse("maybe a paragraph\non two lines")

      nodes.size.should eq 2
      nodes[0].should be_a CMark::Paragraph
      para = nodes[0].as(CMark::Paragraph)

      para.value.size.should eq 1
      para.value[0].should be_a CMark::Text
      para.value[0].as(CMark::Text).value.should eq "maybe a paragraph"

      nodes[1].should be_a CMark::Paragraph
      para = nodes[1].as(CMark::Paragraph)

      para.value.size.should eq 1
      para.value[0].should be_a CMark::Text
      para.value[0].as(CMark::Text).value.should eq "on two lines"
    end
  end

  describe CMark::Strong do
    it "parses strong text" do
      nodes = parse("this is **strong**")

      nodes.size.should eq 1
      nodes[0].should be_a CMark::Paragraph
      para = nodes[0].as(CMark::Paragraph)

      para.value.size.should eq 2
      para.value[0].should be_a CMark::Text
      para.value[0].as(CMark::Text).value.should eq "this is "
      para.value[1].should be_a CMark::Strong
      strong = para.value[1].as(CMark::Strong)

      strong.asterisk?.should be_true
      strong.underscore?.should be_false
      strong.value.size.should eq 1
      strong.value[0].should be_a CMark::Text
      strong.value[0].as(CMark::Text).value.should eq "strong"
    end

    it "parses nested text types" do
      # TODO: this probably shouldn't insert a space as part of emphasis
      # ref: line 141-142
      nodes = parse("this is __*kinda* strong__")

      nodes.size.should eq 1
      nodes[0].should be_a CMark::Paragraph
      para = nodes[0].as(CMark::Paragraph)

      para.value.size.should eq 2
      para.value[0].should be_a CMark::Text
      para.value[0].as(CMark::Text).value.should eq "this is "
      para.value[1].should be_a CMark::Strong
      strong = para.value[1].as(CMark::Strong)

      strong.asterisk?.should be_false
      strong.underscore?.should be_true
      strong.value.size.should eq 2
      strong.value[0].should be_a CMark::Emphasis
      emph = strong.value[0].as(CMark::Emphasis)

      emph.value.size.should eq 2
      emph.value[0].should be_a CMark::Text
      emph.value[0].as(CMark::Text).value.should eq "kinda"
      emph.value[1].should be_a CMark::Text
      emph.value[1].as(CMark::Text).value.should eq " "

      strong.value[1].should be_a CMark::Text
      strong.value[1].as(CMark::Text).value.should eq "strong"
    end
  end

  describe CMark::Emphasis do
    it "parses emphatic text" do
      nodes = parse("this is _emphatic_")

      nodes.size.should eq 1
      nodes[0].should be_a CMark::Paragraph
      para = nodes[0].as(CMark::Paragraph)

      para.value.size.should eq 2
      para.value[0].should be_a CMark::Text
      para.value[0].as(CMark::Text).value.should eq "this is "
      para.value[1].should be_a CMark::Emphasis
      emph = para.value[1].as(CMark::Emphasis)

      emph.asterisk?.should be_false
      emph.underscore?.should be_true
      emph.value.size.should eq 1
      emph.value[0].should be_a CMark::Text
      emph.value[0].as(CMark::Text).value.should eq "emphatic"
    end

    it "parses nested text types" do
      nodes = parse("this is *__very__ emphatic*")

      nodes.size.should eq 1
      nodes[0].should be_a CMark::Paragraph
      para = nodes[0].as(CMark::Paragraph)

      para.value.size.should eq 2
      para.value[0].should be_a CMark::Text
      para.value[0].as(CMark::Text).value.should eq "this is "
      para.value[1].should be_a CMark::Emphasis
      emph = para.value[1].as(CMark::Emphasis)

      emph.asterisk?.should be_true
      emph.underscore?.should be_false
      emph.value.size.should eq 3
      emph.value[0].should be_a CMark::Strong
      strong = emph.value[0].as(CMark::Strong)

      strong.value.size.should eq 1
      strong.value[0].should be_a CMark::Text
      strong.value[0].as(CMark::Text).value.should eq "very"

      emph.value[1].should be_a CMark::Text
      emph.value[1].as(CMark::Text).value.should eq " "
      emph.value[2].should be_a CMark::Text
      emph.value[2].as(CMark::Text).value.should eq "emphatic"
    end
  end

  describe CMark::CodeSpan do
    it "parses single code spans" do
      nodes = parse("`this is some code`")

      nodes.size.should eq 1
      nodes[0].should be_a CMark::CodeSpan
      nodes[0].as(CMark::CodeSpan).value.should eq "this is some code"
    end

    it "parses double code spans" do
      nodes = parse("``this `is some` code``")

      nodes.size.should eq 1
      nodes[0].should be_a CMark::CodeSpan
      nodes[0].as(CMark::CodeSpan).value.should eq "this `is some` code"
    end
  end

  describe CMark::CodeBlock do
    it "parses backtick code blocks" do
      nodes = parse <<-CODE
        ```
        this is
          a big
            code block
        ```
        CODE

      nodes.size.should eq 1
      nodes[0].should be_a CMark::CodeBlock
      block = nodes[0].as(CMark::CodeBlock)

      block.kind.should eq CMark::CodeBlock::Kind::Backtick
      block.info.should be_nil
      block.value.should eq <<-STR
        this is
          a big
            code block
        STR
    end

    it "parses tilde code blocks" do
      nodes = parse <<-CODE
        ~~~~
          this is
        another
          code block
        ~~~~
        CODE

      nodes.size.should eq 1
      nodes[0].should be_a CMark::CodeBlock
      block = nodes[0].as(CMark::CodeBlock)

      block.kind.should eq CMark::CodeBlock::Kind::Tilde
      block.info.should be_nil
      block.value.should eq <<-STR
          this is
        another
          code block
        STR
    end

    it "parses code block info" do
      nodes = parse <<-CODE
        ```crystal
        def fib(n : Int32) : Int32
          return 1 if n <= 1

          fib(n - 1) + fib(n - 2)
        end
        ```
        CODE

      nodes.size.should eq 1
      nodes[0].should be_a CMark::CodeBlock
      block = nodes[0].as(CMark::CodeBlock)

      block.kind.should eq CMark::CodeBlock::Kind::Backtick
      block.info.should eq "crystal"
      block.value.should eq <<-STR
        def fib(n : Int32) : Int32
          return 1 if n <= 1

          fib(n - 1) + fib(n - 2)
        end
        STR
    end

    it "parses nested code block delimiters" do
      nodes = parse <<-CODE
        ~~~some-str ```
        foo bar
        baz qux
        ~~~
        CODE

      nodes.size.should eq 1
      nodes[0].should be_a CMark::CodeBlock
      block = nodes[0].as(CMark::CodeBlock)

      block.kind.should eq CMark::CodeBlock::Kind::Tilde
      block.info.should eq "some-str ```"
      block.value.should eq <<-STR
        foo bar
        baz qux
        STR
    end

    it "parses nested code blocks" do
      nodes = parse <<-CODE
        ````
        this is
          some crazy
          ~~~~
            levels of
            code block
          ~~~~
        nesting
        ````
        CODE

      nodes.size.should eq 1
      nodes[0].should be_a CMark::CodeBlock
      block = nodes[0].as(CMark::CodeBlock)

      block.kind.should eq CMark::CodeBlock::Kind::Backtick
      block.info.should be_nil
      block.value.should eq <<-STR
        this is
          some crazy
          ~~~~
            levels of
            code block
          ~~~~
        nesting
        STR
    end
  end

  describe CMark::BlockQuote do
    it "parses block quotes" do
      nodes = parse <<-QUOTE
        > foo bar
        > baz qux
        QUOTE

      nodes.size.should eq 1
      nodes[0].should be_a CMark::BlockQuote
      quote = nodes[0].as(CMark::BlockQuote)

      quote.value.size.should eq 2
      quote.value[0].should be_a CMark::Text
      quote.value[0].as(CMark::Text).value.should eq "foo bar"
      quote.value[1].should be_a CMark::Text
      quote.value[1].as(CMark::Text).value.should eq "baz qux"
    end

    it "parses indented block quotes" do
      nodes = parse <<-QUOTE
        >   foo bar
        >          baz qux
        QUOTE

      nodes.size.should eq 1
      nodes[0].should be_a CMark::BlockQuote
      quote = nodes[0].as(CMark::BlockQuote)

      quote.value.size.should eq 2
      quote.value[0].should be_a CMark::Text
      quote.value[0].as(CMark::Text).value.should eq "foo bar"
      quote.value[1].should be_a CMark::Text
      quote.value[1].as(CMark::Text).value.should eq "baz qux"
    end

    it "parses lazy block quote values" do
      nodes = parse <<-QUOTE
        > foo bar
            baz qux
        asdf
        QUOTE

      nodes.size.should eq 2
      nodes[0].should be_a CMark::BlockQuote
      quote = nodes[0].as(CMark::BlockQuote)

      quote.value.size.should eq 2
      quote.value[0].should be_a CMark::Text
      quote.value[0].as(CMark::Text).value.should eq "foo bar"
      quote.value[1].should be_a CMark::Text
      quote.value[1].as(CMark::Text).value.should eq "baz qux"

      nodes[1].should be_a CMark::Paragraph
      para = nodes[1].as(CMark::Paragraph)

      para.value[0].should be_a CMark::Text
      para.value[0].as(CMark::Text).value.should eq "asdf"
    end
  end

  describe CMark::List do
    it "parses loose lists" do
      nodes = parse <<-LIST
        - this is
        - a list
        LIST

      nodes.size.should eq 1
      nodes[0].should be_a CMark::List
      list = nodes[0].as(CMark::List)

      list.ordered?.should be_false
      list.items.size.should eq 2
      list.items[0].should be_a CMark::Paragraph
      list.items[0].as(CMark::Paragraph).value[0].should be_a CMark::Text
      list.items[0].as(CMark::Paragraph).value[0].as(CMark::Text).value.should eq "this is"
      list.items[1].should be_a CMark::Paragraph
      list.items[1].as(CMark::Paragraph).value[0].should be_a CMark::Text
      list.items[1].as(CMark::Paragraph).value[0].as(CMark::Text).value.should eq "a list"
    end
  end
end
