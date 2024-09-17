require "../../spec_helper"

describe Marker::Parser do
  context "parses paragraphs:" do
    it "example 219" do
      nodes = parse <<-MD
        aaa

        bbb
        MD

      nodes.size.should eq 2
      node = nodes[0].should be_a Marker::Paragraph

      node.values.size.should eq 1
      text = node.values[0].should be_a Marker::Text

      text.value.should eq "aaa"
      node = nodes[1].should be_a Marker::Paragraph

      node.values.size.should eq 1
      text = node.values[0].should be_a Marker::Text

      text.value.should eq "bbb"
    end

    it "example 220" do
      nodes = parse <<-MD
        aaa
        bbb

        ccc
        ddd
        MD

      nodes.size.should eq 2
      node = nodes[0].should be_a Marker::Paragraph

      node.values.size.should eq 1
      text = node.values[0].should be_a Marker::Text

      text.value.should eq "aaa\nbbb"
      node = nodes[1].should be_a Marker::Paragraph

      node.values.size.should eq 1
      text = node.values[0].should be_a Marker::Text

      text.value.should eq "ccc\nddd"
    end

    it "example 221" do
      nodes = parse <<-MD
        aaa


        bbb
        MD

      nodes.size.should eq 2
      node = nodes[0].should be_a Marker::Paragraph

      node.values.size.should eq 1
      text = node.values[0].should be_a Marker::Text

      text.value.should eq "aaa"
      node = nodes[1].should be_a Marker::Paragraph

      node.values.size.should eq 1
      text = node.values[0].should be_a Marker::Text

      text.value.should eq "bbb"
    end

    it "example 222" do
      nodes = parse <<-MD
          aaa
         bbb
        MD

      nodes.size.should eq 1
      node = nodes[0].should be_a Marker::Paragraph

      node.values.size.should eq 1
      text = node.values[0].should be_a Marker::Text

      text.value.should eq "aaa\nbbb"
    end

    it "example 223" do
      nodes = parse <<-MD
        aaa
             bbb
                                       ccc
        MD

      nodes.size.should eq 1
      node = nodes[0].should be_a Marker::Paragraph

      node.values.size.should eq 1
      text = node.values[0].should be_a Marker::Text

      text.value.should eq "aaa\nbbb\nccc"
    end
  end
end
