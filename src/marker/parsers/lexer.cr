class Marker::Parser::CommonMark
  private class Token
    enum Type
      Heading
      Text
      Strong
      Emphasis
      CodeSpan
      CodeBlock
      HTMLBlock
      BlockQuote
      ListItem

      # LeftBracket
      # LeftParen
      # RightBracket
      # RightParen
      # Colon

      Whitespace
      Newline
      Escape
      EOF
    end

    getter pos : Position
    property type : Type
    property value : String

    def initialize(@type)
      @value = ""
      @pos = Position.new
    end
  end

  class Lexer
    TERMINATORS = {'\0', '\r', '\n'}

    @reader : Char::Reader
    @line : Int32
    @token : Token

    def initialize(input)
      @reader = Char::Reader.new input
      @line = 1
      @token = uninitialized Token
    end

    def run : Array(Token)
      tokens = [] of Token

      loop do
        next_token
        tokens << @token
        break if @token.type.eof?
      end

      tokens
    end

    def next_token : Nil
      @token = Token.new :eof
      @token.pos.set_start @line, @reader.pos

      case char = current_char
      when '\0'
        @token.type = :eof
        @token.pos.set_stop @line, @reader.pos
      when ' ' # no tabs yet
        consume_whitespace
      when '\r', '\n'
        consume_newline
      when '\\'
        next_char
        @token.type = :escape
        @token.pos.set_stop @line, @reader.pos
      when '#'
        consume_header
      when '*', '_'
        if next_char == char
          next_char
          @token.type = :strong
          @token.pos.set_stop @line, @reader.pos
          @token.value = get_text_range
          # Does not work, needs refining
          # elsif char == '*' && current_char.in?('\0', '\r', '\n', ' ')
          #   consume_list_item_or_text
        else
          @token.type = :emphasis
          @token.pos.set_stop @line, @reader.pos
          @token.value = get_text_range
        end
      when '`', '~'
        if next_char == char && next_char == char
          consume_code_block
        else
          consume_code_span
        end
      when '<'
        consume_html
      when '>'
        next_char
        @token.type = :block_quote
        @token.pos.set_stop @line, @reader.pos
        @token.value = get_text_range
      when '-', '+'
        next_char
        @token.type = :list_item
        @token.pos.set_stop @line, @reader.pos
        @token.value = get_text_range
      when '0'..'9'
        consume_list_item_or_text
      else
        consume_text
      end
    end

    def consume_whitespace : Nil
      @token.type = :whitespace

      while current_char == ' '
        next_char
      end

      @token.pos.set_stop @line, @reader.pos
      @token.value = get_text_range
    end

    def consume_newline : Nil
      @token.type = :newline

      while current_char.in? TERMINATORS
        @line += 1
        next_char
      end

      @token.pos.set_stop @line, @reader.pos
    end

    def consume_header : Nil
      @token.type = :heading

      while current_char == '#'
        next_char
      end

      @token.pos.set_stop @line, @reader.pos
      @token.value = get_text_range
    end

    def consume_code_block : Nil
      @token.type = :code_block

      while current_char == '`'
        next_char
      end
      count = get_text_range.size

      loop do
        break if current_char == '\0'

        if current_char == '`'
          nth = 1
          count.times do
            nth += 1 if next_char == '`'
            break if nth == count
          end
        end

        next_char
      end

      @token.pos.set_stop @line, @reader.pos
      @token.value = get_text_range
    end

    def consume_code_span : Nil
      @token.type = :code_span
      count = get_text_range.size

      loop do
        break if current_char == '\0'
        if current_char == '`'
          break if count == 1 || next_char == '`'
        else
          next_char
        end
      end

      next_char unless current_char == '\0'
      @token.pos.set_stop @line, @reader.pos
      @token.value = get_text_range
    end

    def consume_html : Nil
      @token.type = :html_block

      until current_char == '>'
        next_char
      end

      next_char
      @token.pos.set_stop @line, @reader.pos
      @token.value = get_text_range
    end

    def consume_list_item_or_text : Nil
      loop do
        case current_char
        when '0'..'9' then next_char
        when '.', ')' then break
        else               return consume_text
        end
      end

      next_char
      @token.type = :list_item
      @token.pos.set_stop @line, @reader.pos
      @token.value = get_text_range
    end

    def consume_text : Nil
      @token.type = :text

      loop do
        break if current_char.in? TERMINATORS
        break if current_char.in?('\\', '#', '*', '_', '`', '~', '<', '>', '-', '+')
        next_char
      end

      @token.pos.set_stop @line, @reader.pos
      @token.value = get_text_range
    end

    private def current_char : Char
      @reader.current_char
    end

    private def next_char : Char
      @reader.next_char
    end

    private def get_text_range : String
      @reader.string[@token.pos.column[0]..@reader.pos - 1]
    end
  end
end
