require "../spec_helper"

describe Marker::Parser do
  context "parses inlines - code spans:" do
    it "example 327" do
      nodes = parse "`hi`lo"

      nodes.size.should eq 1
      node = nodes[0].should be_a Marker::Paragraph

      node.values.size.should eq 2
      code = node.values[0].should be_a Marker::CodeSpan

      code.value.should eq "hi"
      text = node.values[1].should be_a Marker::Text

      text.value.should eq "lo"
    end

    it "example 328" do
      nodes = parse "`foo`"

      nodes.size.should eq 1
      node = nodes[0].should be_a Marker::Paragraph

      node.values.size.should eq 1
      code = node.values[0].should be_a Marker::CodeSpan

      code.value.should eq "foo"
    end

    it "example 329" do
      nodes = parse "``foo ` bar``"

      nodes.size.should eq 1
      node = nodes[0].should be_a Marker::Paragraph

      node.values.size.should eq 1
      code = node.values[0].should be_a Marker::CodeSpan

      code.value.should eq "foo ` bar"
    end

    it "example 330" do
      nodes = parse "` `` `"

      nodes.size.should eq 1
      node = nodes[0].should be_a Marker::Paragraph

      node.values.size.should eq 1
      code = node.values[0].should be_a Marker::CodeSpan

      code.value.should eq "``"
    end

    it "example 331" do
      nodes = parse "`  ``  `"

      nodes.size.should eq 1
      node = nodes[0].should be_a Marker::Paragraph

      node.values.size.should eq 1
      code = node.values[0].should be_a Marker::CodeSpan

      code.value.should eq " `` "
    end

    it "example 332" do
      nodes = parse "` a`"

      nodes.size.should eq 1
      node = nodes[0].should be_a Marker::Paragraph

      node.values.size.should eq 1
      code = node.values[0].should be_a Marker::CodeSpan

      code.value.should eq " a"
    end

    it "example 333" do
      nodes = parse "` b `"

      nodes.size.should eq 1
      node = nodes[0].should be_a Marker::Paragraph

      node.values.size.should eq 1
      code = node.values[0].should be_a Marker::CodeSpan

      code.value.should eq " b "
    end

    it "example 334" do
      nodes = parse <<-MD
        ` `
        `  `
        MD

      nodes.size.should eq 1
      node = nodes[0].should be_a Marker::Paragraph

      node.values.size.should eq 2
      code = node.values[0].should be_a Marker::CodeSpan

      code.value.should eq " "
      code = node.values[1].should be_a Marker::CodeSpan

      code.value.should eq "  "
    end

    it "example 335" do
      nodes = parse <<-MD
        ``
        foo
        bar  
        baz
        ``
        MD

      nodes.size.should eq 1
      node = nodes[0].should be_a Marker::Paragraph

      node.values.size.should eq 1
      code = node.values[0].should be_a Marker::CodeSpan

      code.value.should eq "foo bar   baz"
    end

    pending "example 336" do
      nodes = parse <<-MD
        ``
        foo 
        ``
        MD

      nodes.size.should eq 1
      node = nodes[0].should be_a Marker::Paragraph

      node.values.size.should eq 1
      code = node.values[0].should be_a Marker::CodeSpan

      code.value.should eq "foo "
    end

    it "example 337" do
      nodes = parse <<-MD
        `foo   bar 
        baz`
        MD

      nodes.size.should eq 1
      node = nodes[0].should be_a Marker::Paragraph

      node.values.size.should eq 1
      code = node.values[0].should be_a Marker::CodeSpan

      code.value.should eq "foo   bar  baz"
    end

    it "example 338" do
      nodes = parse "`foo\\`bar`"

      nodes.size.should eq 1
      node = nodes[0].should be_a Marker::Paragraph

      node.values.size.should eq 3
      code = node.values[0].should be_a Marker::CodeSpan

      # This might be a bug, "bar" and "`" are read separately
      # but should be joined together in parsing

      code.value.should eq "foo\\"
      code = node.values[1].should be_a Marker::Text

      code.value.should eq "bar"
      text = node.values[2].should be_a Marker::Text

      text.value.should eq "`"
    end
  end
end
