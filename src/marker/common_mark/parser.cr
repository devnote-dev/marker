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
          if token.value.size > 5
            parse_paragraph previous_token
          else
            parse_heading token
          end
        else
          parse_paragraph previous_token
        end
      when .text?
        parse_paragraph token
      when .strong?
        if next_token.kind.space?
          parse_strong token
        else
          parse_paragraph previous_token
        end
      when .emphasis?
        if next_token.kind.space?
          parse_emphasis token
        else
          parse_paragraph previous_token
        end
      when .code_span?
        parse_code_span token
      when .code_block?
        parse_code_block token
      when .block_quote?
        parse_block_quote
        # when .list_item?
        #   parse_list
      when .newline?
        parse_node next_token
      end
    end

    def parse_heading(token : Token) : Node
      level = token.value.size
      token = next_token
      value = [] of Inline

      loop do
        case token.kind
        when .eof?, .newline?
          break
        when .heading?
          next
        when .strong?
          value << parse_strong token
        when .emphasis?
          value << parse_emphasis token
        when .code_span?
          value << parse_code_span token
        else
          value << Text.new token.value
        end
        token = next_token
      end

      Heading.new level, value
    end

    def parse_paragraph(token : Token) : Inline
      value = [] of Inline

      loop do
        case token.kind
        when .eof?, .newline?
          break
        when .strong?
          value << parse_strong token
        when .emphasis?
          value << parse_emphasis token
        when .code_span?
          value << parse_code_span token
        else
          value << Text.new token.value
        end
        token = next_token
      end

      Paragraph.new value
    end

    def parse_strong(token : Token) : Inline
      asterisk = token.value == "**"
      value = [] of Inline

      loop do
        token = next_token
        case token.kind
        when .eof?, .newline?
          return Paragraph.new value
        when .strong?
          break
        when .emphasis?
          value << parse_emphasis token
        when .code_span?
          value << parse_code_span token
        else
          value << Text.new token.value
        end
      end

      Strong.new asterisk, value
    end

    def parse_emphasis(token : Token) : Inline
      asterisk = token.value == "*"
      value = [] of Inline

      loop do
        token = next_token
        case token.kind
        when .eof?, .newline?
          return Paragraph.new value
        when .strong?
          value << parse_strong token
        when .emphasis?
          break
        when .code_span?
          value << parse_code_span token
        when .list_item?
          if asterisk
            if token.value == "* "
              value << Text.new " "
              break
            else
              value << Text.new token.value
            end
          else
            if token.value == "_ "
              value << Text.new " "
              break
            else
              value << Text.new token.value
            end
          end
        else
          value << Text.new token.value
        end
      end

      Emphasis.new asterisk, value
    end

    def parse_code_span(token : Token) : Node
      next_token
      CodeSpan.new token.value.strip '`'
    end

    def parse_code_block(token : Token) : Node
      next_token

      info : String? = nil
      line = token.value.lines.first
      delim = line[0]
      value = token.value.strip(delim).strip('\n')
      kind = delim == '`' ? CodeBlock::Kind::Backtick : CodeBlock::Kind::Tilde

      unless line.ends_with? delim
        line = line.strip delim
        unless line.includes? delim
          info = line
          value = value.lstrip(info).strip('\n')
        end
      end

      CodeBlock.new kind, info, value
    end

    def parse_block_quote : Node
      value = [] of Inline
      in_quote = true

      loop do
        token = next_token
        case token.kind
        when .eof?
          break
        when .newline?
          break unless in_quote
          in_quote = false
          next
        when .space?
          next
        when .block_quote?
          in_quote = true
          next
        when .strong?
          value << parse_strong token
        when .emphasis?
          value << parse_emphasis token
        when .code_span?
          value << parse_code_span token
        else
          value << Text.new token.value
        end

        unless in_quote
          next_token
          break
        end
      end

      BlockQuote.new value
    end

    # TODO: requires delimiter context
    def parse_list : Node
      values = [] of Inline
      wants_new_item = false

      loop do
        token = next_token
        case token.kind
        when .eof?
          break
        when .newline?
          wants_new_item = true
          next
        when .space?
          if wants_new_item
            break unless peek_token.kind.list_item?
          end
        when .list_item?
          wants_new_item = false
        else
          break if wants_new_item
          case token.kind
          when .strong?
            values << parse_strong token
          when .emphasis?
            values << parse_emphasis token
          when .code_span?
            values << parse_code_span token
          when .list_item?
            values << parse_list
          else
            values << Text.new token.value
          end
        end
      end

      List.new values
    end

    protected def current_token : Token
      @tokens[@pos]
    end

    protected def peek_token : Token
      @tokens[@pos + 1]
    end

    protected def next_token : Token
      @tokens[@pos += 1]
    end

    protected def previous_token : Token
      @tokens[@pos -= 1]
    end
  end
end
