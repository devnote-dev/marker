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

      strong.value.size.should eq 1
      strong.value[0].should be_a CMark::Text
      strong.value[0].as(CMark::Text).value.should eq "strong"
    end

    it "parses nested text types" do
      nodes = parse("this is **_kinda_ strong**")

      nodes.size.should eq 1
      nodes[0].should be_a CMark::Paragraph
      para = nodes[0].as(CMark::Paragraph)

      para.value.size.should eq 2
      para.value[0].should be_a CMark::Text
      para.value[0].as(CMark::Text).value.should eq "this is "
      para.value[1].should be_a CMark::Strong
      strong = para.value[1].as(CMark::Strong)

      strong.value.size.should eq 3
      strong.value[0].should be_a CMark::Emphasis
      emph = strong.value[0].as(CMark::Emphasis)

      emph.value.size.should eq 1
      emph.value[0].should be_a CMark::Text
      emph.value[0].as(CMark::Text).value.should eq "kinda"

      strong.value[1].should be_a CMark::Text
      strong.value[1].as(CMark::Text).value.should eq " "
      strong.value[2].should be_a CMark::Text
      strong.value[2].as(CMark::Text).value.should eq "strong"
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

      emph.value.size.should eq 1
      emph.value[0].should be_a CMark::Text
      emph.value[0].as(CMark::Text).value.should eq "emphatic"
    end

    it "parses nested text types" do
      nodes = parse("this is _**very** emphatic_")

      nodes.size.should eq 1
      nodes[0].should be_a CMark::Paragraph
      para = nodes[0].as(CMark::Paragraph)

      para.value.size.should eq 2
      para.value[0].should be_a CMark::Text
      para.value[0].as(CMark::Text).value.should eq "this is "
      para.value[1].should be_a CMark::Emphasis
      emph = para.value[1].as(CMark::Emphasis)

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
end