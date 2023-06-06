module Marker::CommonMark
  class Parser
    @tokens : Array(Token)
    @pos : Int32

    def initialize(@tokens : Array(Token))
      @pos = 0
    end

    def parse : SyntaxTree
      nodes = [] of Node

      loop do
        node = parse_node current_token
        break if node.nil?
        nodes << node
      end

      SyntaxTree.new nodes
    end

    def parse_node(token : Token) : Node?
      case token.kind
      when .heading?
        if next_token.kind.space?
          parse_heading token
        else
          parse_paragraph previous_token
        end
      when .text?
        parse_paragraph token
      when .newline?
        parse_node next_token
      end
    end

    def parse_heading(token : Token) : Node
      level = token.value.size
      token = next_token
      values = [] of Node

      loop do
        case token.kind
        when .eof?, .newline?
          break
        when .heading?
          next
        when .strong?, .emphasis?
          node = parse_node token
          break if node.nil?
          values << node
        else
          values << Text.new token.value
        end
        token = next_token
      end

      Heading.new level, values
    end

    def parse_paragraph(token : Token) : Node
      values = [] of Node

      loop do
        case token.kind
        when .eof?, .newline?
          break
        when .strong?, .emphasis?
          node = parse_node token
          break if node.nil?
          values << node
        else
          values << Text.new token.value
        end
        token = next_token
      end

      Paragraph.new values
    end

    protected def current_token : Token
      @tokens[@pos]
    end

    protected def peek_token : Token
      @tokens[@pos + 1]
    end

    protected def next_token : Token
      @tokens[@pos]
      @tokens[@pos += 1]
    end

    protected def previous_token : Token
      @tokens[@pos -= 1]
    end
  end
end
