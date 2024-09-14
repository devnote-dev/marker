require "../../spec_helper"

describe Marker::Parser do
  context "parses link reference definitions:" do
    it "example 192 (partial)" do
      nodes = parse <<-MD
        [foo]: /url "title"
        MD

      nodes.size.should eq 1
      node = nodes[0].should be_a Marker::LinkReference

      node.label.size.should eq 1
      text = node.label[0].should be_a Marker::Text

      text.value.should eq "foo"
      node.destination.should eq "/url"
      node.title.should eq "title"
    end

    pending "example 193 (partial)" do
      nodes = parse <<-MD
          [foo]: 
            /url  
                'the title'  
        MD

      nodes.size.should eq 1
      node = nodes[0].should be_a Marker::LinkReference

      node.label.size.should eq 1
      text = node.label[0].should be_a Marker::Text

      text.value.should eq "foo"
      node.destination.should eq "/url"
      node.title.should eq "the title"
    end
  end
end
