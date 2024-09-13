module Marker
  class Location
    @value : StaticArray(Int32, 4)

    def self.[](line : Int32, column : Int32)
      new StaticArray[line, column, line, column]
    end

    def initialize(@value : StaticArray(Int32, 4))
    end

    def start : {Int32, Int32}
      {@value[0], @value[1]}
    end

    def end : {Int32, Int32}
      {@value[2], @value[3]}
    end

    def start_at(line : Int32, column : Int32) : self
      @value[0] = line
      @value[1] = column

      self
    end

    def end_at(line : Int32, column : Int32) : self
      @value[2] = line
      @value[3] = column

      self
    end

    def &(other : Location) : Location
      Location[@value[0], @value[1]].end_at(*other.end)
    end
  end

  struct Token
    enum Kind
      EOF
      Space
      Newline

      Escape           # \
      ThematicBreak    # --- or ___ or ***
      ATXHeading       # #
      SetextHeading    # ===
      FenceBlock       # ``` or ~~~
      HTMLDirective    # <!
      HTMLOpenComment  # <!--
      HTMLCloseComment # -->
      HTMLCloseTag     # />
      Equal            # =
      ListItem         # -
      Period           # .
      CodeSpan         # `
      Tilde            # ~
      Asterisk         # *
      Underscore       # _
      LeftBracket      # [
      RightBracket     # ]
      LeftParen        # (
      RightParen       # )
      LeftAngle        # <
      RightAngle       # >
      Quote            # "" or ''
      Colon            # :
      Bang             # !
      Text
    end

    getter kind : Kind
    getter loc : Location
    @value : String?

    def initialize(@kind : Kind, @loc : Location, @value : String? = nil)
    end

    def value : String
      @value.as(String)
    end
  end
end
