require "../../spec_helper"

describe Marker::Parser do
  context "parses empahsis:" do
    it "example 350" do
      nodes = parse "*foo bar*"

      nodes.size.should eq 1
      node = nodes[0].should be_a Marker::Paragraph

      node.values.size.should eq 1
      emph = node.values[0].should be_a Marker::Emphasis

      emph.value.size.should eq 1
      text = emph.value[0].should be_a Marker::Text

      text.value.should eq "foo bar"
    end

    it "example 351" do
      nodes = parse "a * foo bar"

      nodes.size.should eq 1
      node = nodes[0].should be_a Marker::Paragraph

      node.values.size.should eq 4
      text = node.values[0].should be_a Marker::Text

      text.value.should eq "a "
      text = node.values[1].should be_a Marker::Text

      text.value.should eq "*"
      text = node.values[2].should be_a Marker::Text

      text.value.should eq " "
      text = node.values[3].should be_a Marker::Text

      text.value.should eq "foo bar"
    end

    it "example 352" do
      nodes = parse %(a*"foo")

      nodes.size.should eq 1
      node = nodes[0].should be_a Marker::Paragraph

      node.values.size.should eq 5
      text = node.values[0].should be_a Marker::Text

      text.value.should eq "a"
      text = node.values[1].should be_a Marker::Text

      text.value.should eq "*"
      text = node.values[2].should be_a Marker::Text

      text.value.should eq %(")
      text = node.values[3].should be_a Marker::Text

      text.value.should eq "foo"
      text = node.values[4].should be_a Marker::Text

      text.value.should eq %(")
    end

    it "example 353" do
      nodes = parse "* a *"

      nodes.size.should eq 1
      node = nodes[0].should be_a Marker::Paragraph

      node.values.size.should eq 4
      text = node.values[0].should be_a Marker::Text

      text.value.should eq "*"
      text = node.values[1].should be_a Marker::Text

      text.value.should eq " "
      text = node.values[2].should be_a Marker::Text

      text.value.should eq "a "
      text = node.values[3].should be_a Marker::Text

      text.value.should eq "*"
    end

    it "example 354" do
      nodes = parse <<-MD
        *$*alpha.

        *£*bravo.

        *€*charlie.
        MD

      nodes.size.should eq 3
      node = nodes[0].should be_a Marker::Paragraph

      node.values.size.should eq 4
      text = node.values[0].should be_a Marker::Text

      text.value.should eq "*"
      text = node.values[1].should be_a Marker::Text

      text.value.should eq "$"
      text = node.values[2].should be_a Marker::Text

      text.value.should eq "*"
      text = node.values[3].should be_a Marker::Text

      text.value.should eq "alpha."
      node = nodes[1].should be_a Marker::Paragraph

      node.values.size.should eq 4
      text = node.values[0].should be_a Marker::Text

      text.value.should eq "*"
      text = node.values[1].should be_a Marker::Text

      text.value.should eq "£"
      text = node.values[2].should be_a Marker::Text

      text.value.should eq "*"
      text = node.values[3].should be_a Marker::Text

      text.value.should eq "bravo."
      node = nodes[2].should be_a Marker::Paragraph

      node.values.size.should eq 4
      text = node.values[0].should be_a Marker::Text

      text.value.should eq "*"
      text = node.values[1].should be_a Marker::Text

      text.value.should eq "€"
      text = node.values[2].should be_a Marker::Text

      text.value.should eq "*"
      text = node.values[3].should be_a Marker::Text

      text.value.should eq "charlie."
    end

    it "example 355" do
      nodes = parse "foo*bar*"

      nodes.size.should eq 1
      node = nodes[0].should be_a Marker::Paragraph

      node.values.size.should eq 2
      text = node.values[0].should be_a Marker::Text

      text.value.should eq "foo"
      emph = node.values[1].should be_a Marker::Emphasis

      emph.value.size.should eq 1
      text = emph.value[0].should be_a Marker::Text

      text.value.should eq "bar"
    end

    it "example 356" do
      nodes = parse "5*6*78"

      nodes.size.should eq 1
      node = nodes[0].should be_a Marker::Paragraph

      node.values.size.should eq 3
      text = node.values[0].should be_a Marker::Text

      text.value.should eq "5"
      emph = node.values[1].should be_a Marker::Emphasis

      emph.value.size.should eq 1
      text = emph.value[0].should be_a Marker::Text

      text.value.should eq "6"
      text = node.values[2].should be_a Marker::Text

      text.value.should eq "78"
    end

    it "example 357" do
      nodes = parse "_foo bar_"

      nodes.size.should eq 1
      node = nodes[0].should be_a Marker::Paragraph

      node.values.size.should eq 1
      emph = node.values[0].should be_a Marker::Emphasis

      emph.value.size.should eq 1
      text = emph.value[0].should be_a Marker::Text

      text.value.should eq "foo bar"
    end

    it "example 358" do
      nodes = parse "_ foo bar_"

      nodes.size.should eq 1
      node = nodes[0].should be_a Marker::Paragraph

      node.values.size.should eq 4
      text = node.values[0].should be_a Marker::Text

      text.value.should eq "_"
      text = node.values[1].should be_a Marker::Text

      text.value.should eq " "
      text = node.values[2].should be_a Marker::Text

      text.value.should eq "foo bar"
      text = node.values[3].should be_a Marker::Text

      text.value.should eq "_"
    end

    it "example 359" do
      nodes = parse %(a_"foo"_)

      nodes.size.should eq 1
      node = nodes[0].should be_a Marker::Paragraph

      node.values.size.should eq 6
      text = node.values[0].should be_a Marker::Text

      text.value.should eq "a"
      text = node.values[1].should be_a Marker::Text

      text.value.should eq "_"
      text = node.values[2].should be_a Marker::Text

      text.value.should eq %(")
      text = node.values[3].should be_a Marker::Text

      text.value.should eq "foo"
      text = node.values[4].should be_a Marker::Text

      text.value.should eq %(")
      text = node.values[5].should be_a Marker::Text

      text.value.should eq "_"
    end

    pending "example 360" do
      nodes = parse "foo_bar_"

      nodes.size.should eq 1
      node = nodes[0].should be_a Marker::Paragraph

      node.values.size.should eq 4
      text = node.values[0].should be_a Marker::Text

      text.value.should eq "foo"
      text = node.values[1].should be_a Marker::Text

      text.value.should eq "_"
      text = node.values[2].should be_a Marker::Text

      text.value.should eq "bar"
      text = node.values[3].should be_a Marker::Text

      text.value.should eq "_"
    end
  end
end
