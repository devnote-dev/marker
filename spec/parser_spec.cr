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

  context "parses ATX headings:" do
    it "example 62" do
      nodes = parse <<-MD
        # foo
        ## foo
        ### foo
        #### foo
        ##### foo
        ###### foo
        MD

      nodes.size.should eq 6
      nodes.each_with_index do |node, index|
        node = node.should be_a Marker::Heading

        node.kind.should eq Marker::Heading::Kind::ATX
        node.level.should eq index + 1
        node.values.size.should eq 1
        text = node.values[0].should be_a Marker::Text

        text.value.should eq "foo"
      end
    end

    pending "example 63" do
      nodes = parse "####### foo"

      nodes.size.should eq 1
      node = nodes[0].should be_a Marker::Paragraph

      node.values.size.should eq 3
      text = node.values[0].should be_a Marker::Text

      text.value.should eq "#######"
      text = node.values[1].should be_a Marker::Text

      text.value.should eq " "
      text = node.values[2].should be_a Marker::Text

      text.value.should eq "foo"
    end

    pending "example 64" do
      nodes = parse <<-MD
        #5 bolt

        #hashtag
        MD

      nodes.size.should eq 2
      node = nodes[0].should be_a Marker::Paragraph

      node.values.size.should eq 2
      text = node.values[0].should be_a Marker::Text

      text.value.should eq "#"
      text = node.values[1].should be_a Marker::Text

      text.value.should eq "5 bolt"
      node = nodes[1].should be_a Marker::Paragraph

      node.values.size.should eq 1
      text = node.values[0].should be_a Marker::Text

      text.value.should eq "#hashtag"
    end

    pending "example 65" do
      nodes = parse "\\## foo"

      nodes.size.should eq 1
      node = nodes[0].should be_a Marker::Paragraph

      node.values.size.should eq 3
      text = node.values[0].should be_a Marker::Text

      text.value.should eq "##"
      text = node.values[1].should be_a Marker::Text

      text.value.should eq " "
      text = node.values[2].should be_a Marker::Text

      text.value.should eq "foo"
    end

    it "example 67" do
      nodes = parse "#                  foo                     "

      nodes.size.should eq 1
      node = nodes[0].should be_a Marker::Heading

      node.kind.should eq Marker::Heading::Kind::ATX
      node.level.should eq 1
      node.values.size.should eq 1
      text = node.values[0].should be_a Marker::Text

      text.value.should eq "foo"
    end

    it "example 68" do
      nodes = parse <<-MD
        ### foo
         ## foo
          # foo
        MD

      nodes.size.should eq 3
      nodes.each_with_index do |node, index|
        node = node.should be_a Marker::Heading

        node.kind.should eq Marker::Heading::Kind::ATX
        node.level.should eq 3 - index
        node.values.size.should eq 1
        text = node.values[0].should be_a Marker::Text

        text.value.should eq "foo"
      end
    end

    it "example 71" do
      nodes = parse <<-MD
        ## foo ##
          ###   bar    ###
        MD

      nodes.size.should eq 2
      node = nodes[0].should be_a Marker::Heading

      node.kind.should eq Marker::Heading::Kind::ATX
      node.level.should eq 2
      node.values.size.should eq 1
      text = node.values[0].should be_a Marker::Text

      text.value.should eq "foo"
      node = nodes[1].should be_a Marker::Heading

      node.kind.should eq Marker::Heading::Kind::ATX
      node.level.should eq 3
      node.values.size.should eq 1
      text = node.values[0].should be_a Marker::Text

      text.value.should eq "bar"
    end

    it "example 72" do
      nodes = parse <<-MD
        # foo ##################################
        ##### foo ##
        MD

      nodes.size.should eq 2
      node = nodes[0].should be_a Marker::Heading

      node.kind.should eq Marker::Heading::Kind::ATX
      node.level.should eq 1
      node.values.size.should eq 1
      text = node.values[0].should be_a Marker::Text

      text.value.should eq "foo"
      node = nodes[1].should be_a Marker::Heading

      node.kind.should eq Marker::Heading::Kind::ATX
      node.level.should eq 5
      node.values.size.should eq 1
      text = node.values[0].should be_a Marker::Text

      text.value.should eq "foo"
    end

    it "example 73" do
      nodes = parse "### foo ###     "

      nodes.size.should eq 1
      node = nodes[0].should be_a Marker::Heading

      node.kind.should eq Marker::Heading::Kind::ATX
      node.level.should eq 3
      node.values.size.should eq 1
      text = node.values[0].should be_a Marker::Text

      text.value.should eq "foo"
    end

    it "example 74" do
      nodes = parse "### foo ### b"

      nodes.size.should eq 1
      node = nodes[0].should be_a Marker::Heading

      node.kind.should eq Marker::Heading::Kind::ATX
      node.level.should eq 3
      node.values.size.should eq 1
      text = node.values[0].should be_a Marker::Text

      text.value.should eq "foo ### b"
    end

    it "example 75" do
      nodes = parse "# foo#"

      nodes.size.should eq 1
      node = nodes[0].should be_a Marker::Heading

      node.kind.should eq Marker::Heading::Kind::ATX
      node.level.should eq 1
      node.values.size.should eq 1
      text = node.values[0].should be_a Marker::Text

      text.value.should eq "foo#"
    end

    # Why does this have to exist...
    pending "example 79" do
      nodes = parse <<-MD
        ## 
        #
        ### ###
        MD

      nodes.size.should eq 3
      node = nodes[0].should be_a Marker::Heading

      node.kind.should eq Marker::Heading::Kind::ATX
      node.level.should eq 2
      node.values.size.should eq 1
      text = node.values[0].should be_a Marker::Text

      text.value.should eq " "
      node = nodes[1].should be_a Marker::Heading

      node.kind.should eq Marker::Heading::Kind::ATX
      node.level.should eq 1
      node.values.should be_empty
      node = nodes[2].should be_a Marker::Heading

      node.kind.should eq Marker::Heading::Kind::ATX
      node.level.should eq 3
      node.values.size.should eq 1
      text = node.values[0].should be_a Marker::Text

      text.value.should eq " "
    end
  end
end
