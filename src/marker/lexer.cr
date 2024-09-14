module Marker
  class Lexer
    @reader : Char::Reader
    @pool : StringPool
    @line : Int32
    @column : Int32
    @loc : Location

    def self.lex(source : String) : Array(Token)
      new(source).lex
    end

    private def initialize(source : String)
      @reader = Char::Reader.new source
      @pool = StringPool.new
      @line = @column = 0
      @loc = Location[0, 0]
    end

    def lex : Array(Token)
      tokens = [] of Token

      loop do
        tokens << (token = lex_next_token)
        break if token.kind.eof?
      end

      tokens
    end

    private def lex_next_token : Token
      case current_char
      when '\0'
        Token.new :eof, location
      when ' '
        lex_space
      when '\r', '\n'
        lex_newline
      when '\\'
        next_char
        Token.new :escape, location, "\\"
      when '#'
        lex_atx_heading
      when '='
        start = current_pos
        if next_char == '='
          if next_char == '='
            lex_setext_heading start
          else
            prev_char
            Token.new :equal, location, "="
          end
        else
          Token.new :equal, location, "="
        end
      when '`'
        start = current_pos
        if next_char == '`'
          if next_char == '`'
            lex_fence_block start
          else
            lex_code_span start, 2
          end
        else
          lex_code_span start, 1
        end
      when '~'
        start = current_pos
        if next_char == '~'
          if next_char == '~'
            lex_fence_block start
          else
            prev_char
            Token.new :tilde, location, "~"
          end
        else
          Token.new :tilde, location, "~"
        end
      when '<'
        if next_char == '!'
          if next_char == '-'
            if next_char == '-'
              next_char
              Token.new :html_open_comment, location, "<!--"
            else
              prev_char
              Token.new :text, location, "<!-"
            end
          else
            Token.new :html_directive, location, "<!"
          end
        else
          Token.new :left_angle, location, "<"
        end
      when '-'
        start = current_pos
        if next_char == '-'
          case next_char
          when '-'
            lex_thematic_break start
          when '>'
            next_char
            Token.new :html_close_comment, location, "-->"
          else
            prev_char
            Token.new :list_item, location, "-"
          end
        else
          Token.new :list_item, location, "-"
        end
      when '/'
        if next_char == '>'
          next_char
          Token.new :html_close_tag, location, "/>"
        else
          Token.new :text, location, "/"
        end
      when '*'
        start = current_pos
        if next_char == '*'
          if next_char == '*'
            lex_thematic_break start
          else
            prev_char
            Token.new :asterisk, location, "*"
          end
        else
          Token.new :asterisk, location, "*"
        end
      when '.'
        next_char
        Token.new :period, location, "."
      when '_'
        start = current_pos
        if next_char == '_'
          if next_char == '_'
            lex_thematic_break start
          else
            prev_char
            Token.new :underscore, location, "_"
          end
        else
          Token.new :underscore, location, "_"
        end
      when '['
        next_char
        Token.new :left_bracket, location, "["
      when ']'
        next_char
        Token.new :right_bracket, location, "]"
      when '('
        next_char
        Token.new :left_paren, location, "("
      when ')'
        next_char
        Token.new :right_paren, location, ")"
      when '>'
        next_char
        Token.new :right_angle, location, ">"
      when '"', '\''
        value = current_char.to_s
        next_char
        Token.new :quote, location, value
      when ':'
        next_char
        Token.new :colon, location, ":"
      when '!'
        next_char
        Token.new :bang, location, "!"
      else
        lex_text
      end
    end

    private def current_char : Char
      @reader.current_char
    end

    private def next_char : Char
      @column += 1
      @reader.next_char
    end

    private def prev_char : Nil
      @column -= 1
      @reader.pos -= 1
    end

    private def current_pos : Int32
      @reader.pos
    end

    private def location : Location
      loc = @loc.end_at(@line, @column).dup
      @loc.start_at(@line, @column)
      loc
    end

    private def read_string_from(start : Int32) : String
      @pool.get Slice.new(@reader.string.to_unsafe + start, @reader.pos - start)
    end

    private def lex_space : Token
      start = current_pos

      while current_char == ' '
        next_char
      end

      Token.new :space, location, read_string_from start
    end

    private def lex_newline : Token
      start = current_pos

      loop do
        case current_char
        when '\r'
          next_char
        when '\n'
          @line += 1
          @column = 0
          next_char
        else
          break
        end
      end

      Token.new :newline, location, read_string_from start
    end

    private def lex_atx_heading : Token
      start = current_pos

      while current_char == '#'
        next_char
      end

      value = read_string_from start
      if current_char == ' '
        if value.size > 6
          Token.new :text, location, value
        else
          Token.new :atx_heading, location, value
        end
      else
        Token.new :text, location, value
      end
    end

    private def lex_setext_heading(start : Int32) : Token
      while current_char == '='
        next_char
      end

      Token.new :setext_heading, location, read_string_from start
    end

    private def lex_fence_block(start : Int32) : Token
      char = current_char

      loop do
        case current_char
        when '\0'
          break
        when char
          next_char
        else
          break
        end
      end

      count = read_string_from(start).size

      loop do
        case current_char
        when '\0'
          break
        when char
          stop = true
          count.times do
            if next_char == char
              next
            else
              stop = false
              break
            end
          end
          break if stop
        else
          next_char
        end
      end

      Token.new :fence_block, location, read_string_from start
    end

    private def lex_code_span(start : Int32, level : Int32) : Token
      loop do
        case current_char
        when '\0'
          break
        when '`'
          if level == 1
            break unless next_char == '`'
          end

          if level == 2 && next_char == '`'
            break unless next_char == '`'
          end

          next_char
        else
          next_char
        end
      end

      value = read_string_from start
      if value == "`" && level == 1
        Token.new :text, location, value
      else
        Token.new :code_span, location, value
      end
    end

    private def lex_thematic_break(start : Int32) : Token
      char = current_char

      while current_char == char
        next_char
      end

      Token.new :thematic_break, location, read_string_from start
    end

    private def lex_text : Token
      start = current_pos

      until current_char.in?('\0', '\r', '\n', '\\', '`', '~', '<', '*', '_', '[', ']', '"', '\'', '!')
        next_char
      end

      Token.new :text, location, read_string_from start
    end
  end
end
