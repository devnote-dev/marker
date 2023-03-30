class Marker::Parser::CommonMark
  @source : String
  @tokens : Array(Token)
  @pos : Int32

  def initialize(@source : String)
    @tokens = [] of Token
    @pos = -1
  end

  def self.parse(source : String) : Node
    new(source).parse
  end

  def parse : Node
    @tokens.clear
    @tokens = Lexer.new(@source).run
    document = Node.new :document, ""

    loop do
      @pos += 1
      if token = @tokens[@pos]?
        break if token.type.eof?
        document.children << parse_token token
      end
    end

    document
  end

  protected def parse_token(token : Token) : Node
    case token.type
    when .heading?
      return parse_paragraph(token) if token.value.size > 6
      parse_heading token
    when .text?
      parse_paragraph token
    when .whitespace?
      return parse_code_block(token) if token.value.size >= 4
      parse_token @tokens[@pos += 1]
    end
  end

  protected def parse_heading(token : Token) : Node
    nodes = get_remaining_line.map &->parse_token(Token)
  end

  protected def parse_paragraph(token : Token) : Node
    Node.new :paragraph, token.value
  end

  protected def parse_whitespace(token : Token) : Node
    return parse_code_block(token) if token.value.size >= 4
  end

  private def get_remaining_line : Array(Token)
    tokens = [] of Token

    loop do
      token = @tokens[@pos += 1]
      break if token.type.eof? || token.type.newline?
      tokens << token
    end

    tokens
  end
end
