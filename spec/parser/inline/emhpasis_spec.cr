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

      node.values.size.should eq 1
      text = node.values[0].should be_a Marker::Text

      text.value.should eq "a * foo bar"
    end

    it "example 352" do
      nodes = parse %(a*"foo")

      nodes.size.should eq 1
      node = nodes[0].should be_a Marker::Paragraph

      node.values.size.should eq 1
      text = node.values[0].should be_a Marker::Text

      text.value.should eq %(a*"foo")
    end

    it "example 353" do
      nodes = parse "* a *"

      nodes.size.should eq 1
      node = nodes[0].should be_a Marker::Paragraph

      node.values.size.should eq 1
      text = node.values[0].should be_a Marker::Text

      text.value.should eq "* a *"
    end

    it "example 354" do
      nodes = parse <<-MD
        *$*alpha.

        *£*bravo.

        *€*charlie.
        MD

      nodes.size.should eq 3
      node = nodes[0].should be_a Marker::Paragraph

      node.values.size.should eq 1
      text = node.values[0].should be_a Marker::Text

      text.value.should eq "*$*alpha."
      node = nodes[1].should be_a Marker::Paragraph

      node.values.size.should eq 1
      text = node.values[0].should be_a Marker::Text

      text.value.should eq "*£*bravo."
      node = nodes[2].should be_a Marker::Paragraph

      node.values.size.should eq 1
      text = node.values[0].should be_a Marker::Text

      text.value.should eq "*€*charlie."
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

      node.values.size.should eq 1
      text = node.values[0].should be_a Marker::Text

      text.value.should eq "_ foo bar_"
    end

    it "example 359" do
      nodes = parse %(a_"foo"_)

      nodes.size.should eq 1
      node = nodes[0].should be_a Marker::Paragraph

      node.values.size.should eq 1
      text = node.values[0].should be_a Marker::Text

      text.value.should eq %(a_"foo"_)
    end

    it "example 360" do
      nodes = parse "foo_bar_"

      nodes.size.should eq 1
      node = nodes[0].should be_a Marker::Paragraph

      node.values.size.should eq 1
      text = node.values[0].should be_a Marker::Text

      text.value.should eq "foo_bar_"
    end

    it "example 361" do
      nodes = parse "5_6_78"

      nodes.size.should eq 1
      node = nodes[0].should be_a Marker::Paragraph

      node.values.size.should eq 1
      text = node.values[0].should be_a Marker::Text

      text.value.should eq "5_6_78"
    end

    it "example 362" do
      nodes = parse "пристаням_стремятся_"

      nodes.size.should eq 1
      node = nodes[0].should be_a Marker::Paragraph

      node.values.size.should eq 1
      text = node.values[0].should be_a Marker::Text

      text.value.should eq "пристаням_стремятся_"
    end

    it "example 363" do
      nodes = parse %(aa_"bb"_cc)

      nodes.size.should eq 1
      node = nodes[0].should be_a Marker::Paragraph

      node.values.size.should eq 1
      text = node.values[0].should be_a Marker::Text

      text.value.should eq %(aa_"bb"_cc)
    end

    it "example 364" do
      nodes = parse "foo-_(bar)_"

      nodes.size.should eq 1
      node = nodes[0].should be_a Marker::Paragraph

      node.values.size.should eq 2
      text = node.values[0].should be_a Marker::Text

      text.value.should eq "foo-"
      emph = node.values[1].should be_a Marker::Emphasis

      emph.value.size.should eq 2
      text = emph.value[0].should be_a Marker::Text

      text.value.should eq "("
      text = emph.value[1].should be_a Marker::Text

      text.value.should eq "bar)"
    end

    it "example 365" do
      nodes = parse "_foo*"

      nodes.size.should eq 1
      node = nodes[0].should be_a Marker::Paragraph

      node.values.size.should eq 1
      text = node.values[0].should be_a Marker::Text

      text.value.should eq "_foo*"
    end

    it "example 366" do
      nodes = parse "*foo bar *"

      nodes.size.should eq 1
      node = nodes[0].should be_a Marker::Paragraph

      node.values.size.should eq 1
      text = node.values[0].should be_a Marker::Text

      text.value.should eq "*foo bar *"
    end

    it "example 367" do
      nodes = parse <<-MD
        *foo bar
        *
        MD

      nodes.size.should eq 1
      node = nodes[0].should be_a Marker::Paragraph

      node.values.size.should eq 1
      text = node.values[0].should be_a Marker::Text

      text.value.should eq "*foo bar\n*"
    end

    it "example 368" do
      nodes = parse "*(*foo"

      nodes.size.should eq 1
      node = nodes[0].should be_a Marker::Paragraph

      node.values.size.should eq 1
      text = node.values[0].should be_a Marker::Text

      text.value.should eq "*(*foo"
    end

    pending "example 369" do
      nodes = parse "*(*foo*)*"

      nodes.size.should eq 1
      # node = nodes[0].should be_a Marker::Paragraph
    end

    it "example 370" do
      nodes = parse "*foo*bar"

      nodes.size.should eq 1
      node = nodes[0].should be_a Marker::Paragraph

      node.values.size.should eq 2
      emph = node.values[0].should be_a Marker::Emphasis

      emph.value.size.should eq 1
      text = emph.value[0].should be_a Marker::Text

      text.value.should eq "foo"
      text = node.values[1].should be_a Marker::Text

      text.value.should eq "bar"
    end

    it "example 371" do
      nodes = parse "_foo bar _"

      nodes.size.should eq 1
      node = nodes[0].should be_a Marker::Paragraph

      node.values.size.should eq 1
      text = node.values[0].should be_a Marker::Text

      text.value.should eq "_foo bar _"
    end

    pending "example 372" do
      nodes = parse "_(_foo"

      nodes.size.should eq 1
      node = nodes[0].should be_a Marker::Paragraph

      node.values.size.should eq 1
      text = node.values[0].should be_a Marker::Text

      text.value.should eq "_(_foo"
    end

    pending "example 373" do
      nodes = parse "_(_foo_)_"

      nodes.size.should eq 1
      # node = nodes[0].should be_a Marker::Paragraph
    end

    pending "example 374" do
      nodes = parse "_foo_bar"

      nodes.size.should eq 1
      node = nodes[0].should be_a Marker::Paragraph

      node.values.size.should eq 1
      text = node.values[0].should be_a Marker::Text

      text.value.should eq "_foo_bar"
    end
  end
end
