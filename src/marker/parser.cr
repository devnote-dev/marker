module Marker
  class Parser
    @tokens : Array(Token)
    @pos : Int32

    def self.parse(tokens : Array(Token)) : Array(Block)
      new(tokens).parse
    end

    private def initialize(@tokens : Array(Token))
      @pos = 0
    end

    def parse : Array(Block)
      blocks = [] of Block

      loop do
        break unless block = parse_next_block
        blocks << block
      end

      blocks
    end

    private def parse_next_block : Block?
      case current_token.kind
      when .eof?
        nil
      when .right_angle?
        parse_block_quote
      when .list_item?
        parse_list
      else
        parse_leaf_block
      end
    end

    private def parse_block_quote : Block
      raise "blockquote not implemented"
    end

    private def parse_list : Block
      raise "list not implemented"
    end

    private def parse_leaf_block : Block?
      case current_token.kind
      when .eof?
        nil
      when .space?
        if current_token.value.size > 3
          parse_indented_code_block
        else
          next_token
          parse_leaf_block
        end
      when .newline?
        next_token
        parse_leaf_block
      when .thematic_break?
        parse_thematic_break
      when .atx_heading?
        parse_atx_heading
      when .fence_block?
        parse_fenced_code_block
      when .left_bracket?
        parse_link_reference
      else
        parse_paragraph
      end
    end

    private def current_token : Token
      @tokens[@pos]
    end

    private def next_token : Token
      @tokens[@pos += 1]
    end

    private def parse_indented_code_block : Block
      values = [] of String
      last_is_space = true
      last_value_index = 0

      loop do
        case current_token.kind
        when .eof?
          break
        when .space?
          last_is_space = true
          if current_token.value.size > 4
            values << current_token.value[4..]
          end
          next_token
        when .newline?
          last_is_space = true
          values << current_token.value
          next_token
        else
          break unless last_is_space

          last_is_space = false
          values << current_token.value
          last_value_index = values.size - 1

          loop do
            case (inner = next_token).kind
            when .eof?
              break
            when .newline?
              values << inner.value
              last_value_index += 1
              break next_token
            else
              values << inner.value
              last_value_index += 1
            end
          end
        end
      end

      CodeBlock.new :indent, values[..last_value_index].join.strip '\n'
    end

    private def parse_thematic_break : Block
      token = current_token
      next_token

      case token.value
      when .includes? '*'
        kind = ThematicBreak::Kind::Asterisk
      when .includes? '-'
        kind = ThematicBreak::Kind::Dash
      else
        kind = ThematicBreak::Kind::Underscore
      end

      ThematicBreak.new kind, token.value.size
    end

    private def parse_atx_heading : Block
      level = current_token.value.size
      next_token
      values = parse_inlines.tap(&.shift)

      if text = values[-1].as?(Text)
        text.value = text.value.sub(/(?<![^\s])#+\s*$/, "").strip
      end

      Heading.new :atx, level, values
    end

    private def parse_fenced_code_block : Block
      value = current_token.value
      next_token

      char = value[0]
      kind = char == '`' ? CodeBlock::Kind::Backtick : CodeBlock::Kind::Tilde

      opening = String.build do |io|
        value.each_char do |c|
          c == char ? (io << c) : break
        end
      end

      unless value == opening
        value = value[opening.size..]
      end

      if value.ends_with? opening
        value = value.rstrip char
      end

      CodeBlock.new kind, value
    end

    private def parse_link_reference : Block
      next_token
      values = parse_inlines until: :right_bracket

      unless current_token.kind.right_bracket?
        values.unshift Text.new "["
        return Paragraph.new values
      end

      unless next_token.kind.colon?
        # not sure how this resolves
        raise "not implemented: unreferenced link"
      end

      if next_token.kind.space?
        next_token
      end

      if current_token.kind.eof?
        values << Text.new ":"
        return Paragraph.new values
      end

      dest = String.build do |io|
        loop do
          case current_token.kind
          when .eof?, .space?, .newline?
            break
          when .text?
            io << current_token.value
            break if current_token.value.ends_with? ' '
            next_token
          else
            io << current_token.value
            next_token
          end
        end
      end.strip

      if current_token.kind.eof?
        return LinkReference.new values, dest
      else
        next_token
      end

      if current_token.kind.newline? || !current_token.kind.quote?
        return LinkReference.new values, dest
      end

      quote = current_token.value
      closed = false
      title = String.build do |io|
        last_is_newline = false

        loop do
          case next_token.kind
          when .eof?
            break
          when .newline?
            break if last_is_newline
            last_is_newline = true
          when .quote?
            if current_token.value == quote
              next_token
              closed = true
              break
            else
              io << current_token.value
              last_is_newline = false
            end
          else
            io << current_token.value
            last_is_newline = false
          end
        end
      end

      if closed
        LinkReference.new values, dest, title
      else
        Paragraph.new values << Text.new title
      end
    end

    private def parse_paragraph : Block
      values = [] of Inline
      last_is_newline = false

      loop do
        case current_token.kind
        when .eof?
          break
        when .space?
          next_token
        when .newline?
          break if last_is_newline || current_token.value.size > 1
          last_is_newline = true
          next_token
        else
          values.concat parse_inlines
          last_is_newline = false
        end
      end

      Paragraph.new values
    end

    private def parse_inlines(*, until token_kind : Token::Kind = :newline) : Array(Inline)
      values = [] of Inline

      loop do
        case current_token.kind
        when .eof?, .newline?
          break
        when token_kind
          break
        when .space?, .text?, .quote?
          values << Text.new current_token.value
          next_token
        when .code_span?
          values << parse_code_span
        when .asterisk?, .underscore?
          last_is_space = values.last?.as?(Text).try(&.value.ends_with?(' '))
          case value = parse_emphasis_or_strong(last_is_space || false)
          when Array
            values.concat value
          else
            values << value
          end
        else
          raise "inline not implemented (on #{current_token.kind})"
        end
      end

      values
    end

    private def parse_code_span : Inline
      value = current_token.value.gsub '\n', ' '
      next_token

      if value.starts_with? "``"
        value = value[2...-2]
      else
        value = value.strip '`'
      end

      unless value.blank?
        if value.starts_with?(' ') && value.ends_with?(' ')
          if value.starts_with?("  ") && value.ends_with?("  ")
            value = ' ' + value.strip + ' '
          else
            value = value.strip
          end
        end
      end

      CodeSpan.new value
    end

    private def parse_emphasis_or_strong(last_is_space : Bool) : Inline | Array(Inline)
      kind = current_token.kind
      value = current_token.value
      values = [] of Inline
      token = next_token

      if token.kind.space?
        return Text.new value
      end

      unless last_is_space
        unless token.kind.text? && token.value[0].alphanumeric? # && token.kind.underscore?
          return Text.new value
        end
      end

      loop do
        case current_token.kind
        when .eof?, .newline?
          values.unshift Text.new value
          return values
        when kind
          if text = values[-1].as?(Text)
            if text.value.ends_with? ' '
              values << Text.new value
              next_token
              next
            end
          end

          next_token
          break
        else
          values.concat parse_inlines until: kind
        end
      end

      Emphasis.new values
    end
  end
end
