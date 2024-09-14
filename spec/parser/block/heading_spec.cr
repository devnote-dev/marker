require "../../spec_helper"

describe Marker::Parser do
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
