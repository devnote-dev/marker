require "./spec_helper"

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

  context "parses thematic breaks:" do
    it "example 43" do
      nodes = parse <<-MD
        ***
        ---
        ___
        MD

      nodes.size.should eq 3
      node = nodes[0].should be_a Marker::ThematicBreak

      node.kind.should eq Marker::ThematicBreak::Kind::Asterisk
      node.size.should eq 3
      node = nodes[1].should be_a Marker::ThematicBreak

      node.kind.should eq Marker::ThematicBreak::Kind::Dash
      node.size.should eq 3
      node = nodes[2].should be_a Marker::ThematicBreak

      node.kind.should eq Marker::ThematicBreak::Kind::Underscore
      node.size.should eq 3
    end

    it "example 47" do
      nodes = parse <<-MD
         ***
          ---
           ___
        MD

      nodes.size.should eq 3
      node = nodes[0].should be_a Marker::ThematicBreak

      node.kind.should eq Marker::ThematicBreak::Kind::Asterisk
      node.size.should eq 3
      node = nodes[1].should be_a Marker::ThematicBreak

      node.kind.should eq Marker::ThematicBreak::Kind::Dash
      node.size.should eq 3
      node = nodes[2].should be_a Marker::ThematicBreak

      node.kind.should eq Marker::ThematicBreak::Kind::Underscore
      node.size.should eq 3
    end

    it "example 50" do
      nodes = parse "_____________________________________"

      nodes.size.should eq 1
      node = nodes[0].should be_a Marker::ThematicBreak

      node.kind.should eq Marker::ThematicBreak::Kind::Underscore
      node.size.should eq 37
    end

    pending "example 51" do
      nodes = parse " - - -"

      nodes.size.should eq 1
      node = nodes[0].should be_a Marker::ThematicBreak

      node.kind.should eq Marker::ThematicBreak::Kind::Dash
      node.size.should eq 6
    end

    pending "example 52" do
      nodes = parse " **  * ** * ** * **"

      nodes.size.should eq 1
      node = nodes[0].should be_a Marker::ThematicBreak

      node.kind.should eq Marker::ThematicBreak::Kind::Asterisk
      node.size.should eq 19
    end

    pending "example 53" do
      nodes = parse "-     -      -      -"

      nodes.size.should eq 1
      node = nodes[0].should be_a Marker::ThematicBreak

      node.kind.should eq Marker::ThematicBreak::Kind::Dash
      node.size.should eq 21
    end

    pending "example 54" do
      nodes = parse "- - - -    "

      nodes.size.should eq 1
      node = nodes[0].should be_a Marker::ThematicBreak

      node.kind.should eq Marker::ThematicBreak::Kind::Dash
      node.size.should eq 6
    end
  end
end
