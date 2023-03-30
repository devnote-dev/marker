require "./spec_helper"

alias Lexer = Marker::Parser::CommonMark::Lexer
alias Type = Marker::Parser::CommonMark::Token::Type

describe Lexer do
  it "parses a header" do
    tokens = Lexer.new("# This is a header").run

    tokens[0].type.should eq Type::Heading
    tokens[0].value.should eq "#"
    tokens[1].type.should eq Type::Whitespace
    tokens[1].value.should eq " "
    tokens[2].type.should eq Type::Text
    tokens[2].value.should eq "This is a header"
    tokens[3].type.should eq Type::EOF
    tokens[3].value.should be_empty
  end
end
