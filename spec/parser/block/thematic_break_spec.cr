require "../../spec_helper"

describe Marker::Parser do
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
