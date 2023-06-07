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
end
