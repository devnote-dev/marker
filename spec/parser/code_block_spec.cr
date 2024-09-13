require "../spec_helper"

describe Marker::Parser do
  context "parses indented code blocks:" do
    it "example 107" do
      nodes = parse <<-MD
            a simple
              indented code block
        MD

      nodes.size.should eq 1
      node = nodes[0].should be_a Marker::CodeBlock

      node.kind.should eq Marker::CodeBlock::Kind::Indent
      node.value.should eq "a simple\n  indented code block"
    end

    it "example 110" do
      nodes = parse <<-MD
            <a/>
            *hi*

            - one
        MD

      nodes.size.should eq 1
      node = nodes[0].should be_a Marker::CodeBlock

      node.kind.should eq Marker::CodeBlock::Kind::Indent
      node.value.should eq "<a/>\n*hi*\n\n- one"
    end

    # Please for the love of god nobody mess with the formatting of these specs

    it "example 111" do
      nodes = parse <<-MD
            chunk1

            chunk2
          
         
         
            chunk3
        MD

      nodes.size.should eq 1
      node = nodes[0].should be_a Marker::CodeBlock

      node.kind.should eq Marker::CodeBlock::Kind::Indent
      node.value.should eq "chunk1\n\nchunk2\n\n\n\nchunk3"
    end

    it "example 112" do
      nodes = parse <<-MD
            chunk1
              
              chunk2
        MD

      nodes.size.should eq 1
      node = nodes[0].should be_a Marker::CodeBlock

      node.kind.should eq Marker::CodeBlock::Kind::Indent
      node.value.should eq "chunk1\n  \n  chunk2"
    end

    it "example 116" do
      nodes = parse <<-MD
                foo
            bar
        MD

      nodes.size.should eq 1
      node = nodes[0].should be_a Marker::CodeBlock

      node.kind.should eq Marker::CodeBlock::Kind::Indent
      node.value.should eq "    foo\nbar"
    end

    it "example 117" do
      nodes = parse <<-MD
            
            foo
            
        MD

      nodes.size.should eq 1
      node = nodes[0].should be_a Marker::CodeBlock

      node.kind.should eq Marker::CodeBlock::Kind::Indent
      node.value.should eq "foo"
    end

    it "example 118" do
      nodes = parse "    foo  "

      nodes.size.should eq 1
      node = nodes[0].should be_a Marker::CodeBlock

      node.kind.should eq Marker::CodeBlock::Kind::Indent
      node.value.should eq "foo  "
    end
  end

  context "parses fenced code blocks:" do
    it "example 119" do
      nodes = parse <<-MD
        ```
        <
         >
        ```
        MD

      nodes.size.should eq 1
      node = nodes[0].should be_a Marker::CodeBlock

      node.kind.should eq Marker::CodeBlock::Kind::Backtick
      node.value.should eq "\n<\n >\n"
    end

    it "example 120" do
      nodes = parse <<-MD
        ~~~
        <
         >
        ~~~
        MD

      nodes.size.should eq 1
      node = nodes[0].should be_a Marker::CodeBlock

      node.kind.should eq Marker::CodeBlock::Kind::Tilde
      node.value.should eq "\n<\n >\n"
    end

    it "example 122" do
      nodes = parse <<-MD
        ```
        aaa
        ~~~
        ```
        MD

      nodes.size.should eq 1
      node = nodes[0].should be_a Marker::CodeBlock

      node.kind.should eq Marker::CodeBlock::Kind::Backtick
      node.value.should eq "\naaa\n~~~\n"
    end

    it "example 123" do
      nodes = parse <<-MD
        ~~~
        aaa
        ```
        ~~~
        MD

      nodes.size.should eq 1
      node = nodes[0].should be_a Marker::CodeBlock

      node.kind.should eq Marker::CodeBlock::Kind::Tilde
      node.value.should eq "\naaa\n```\n"
    end

    pending "example 124" do
      nodes = parse <<-MD
        ````
        aaa
        ```
        ``````
        MD

      nodes.size.should eq 1
      node = nodes[0].should be_a Marker::CodeBlock

      node.kind.should eq Marker::CodeBlock::Kind::Backtick
      node.value.should eq "\naaa\n```\n"
    end

    it "example 125" do
      nodes = parse <<-MD
        ~~~~
        aaa
        ~~~
        ~~~~
        MD

      nodes.size.should eq 1
      node = nodes[0].should be_a Marker::CodeBlock

      node.kind.should eq Marker::CodeBlock::Kind::Tilde
      node.value.should eq "\naaa\n~~~\n"
    end

    it "example 126" do
      nodes = parse "```"

      nodes.size.should eq 1
      node = nodes[0].should be_a Marker::CodeBlock

      node.kind.should eq Marker::CodeBlock::Kind::Backtick
      node.value.should be_empty
    end

    it "example 127" do
      nodes = parse <<-MD
        `````

        ```
        aaa
        MD

      nodes.size.should eq 1
      node = nodes[0].should be_a Marker::CodeBlock

      node.kind.should eq Marker::CodeBlock::Kind::Backtick
      node.value.should eq "\n\n```\naaa"
    end

    # TODO: needs confirmation
    it "example 129" do
      nodes = parse <<-MD
        ```

          
        ```
        MD

      nodes.size.should eq 1
      node = nodes[0].should be_a Marker::CodeBlock

      node.kind.should eq Marker::CodeBlock::Kind::Backtick
      node.value.should eq "\n\n  \n"
    end

    it "example 130" do
      nodes = parse <<-MD
        ```
        ```
        MD

      nodes.size.should eq 1
      node = nodes[0].should be_a Marker::CodeBlock

      node.kind.should eq Marker::CodeBlock::Kind::Backtick
      node.value.should eq "\n"
    end
  end
end
