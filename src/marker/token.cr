module Marker
  # class Location
  #   @loc : StaticArray(Int32, 4)
  #
  #   def self.[](line : Int32, column : Int32)
  #     new StaticArray[line, line, column, column]
  #   end
  #
  #   def initialize(@loc : StaticArray(Int32, 4))
  #   end
  #
  #   def line : {Int32, Int32}
  #     {@loc[0], @loc[1]}
  #   end
  #
  #   def column : {Int32, Int32}
  #     {@loc[2], @loc[3]}
  #   end
  #
  #   def set_end(line : Int32, column : Int32) : Nil
  #     @loc[1] = line
  #     @loc[3] = column
  #   end
  # end

  class Token
    enum Kind
      Heading    # #
      Text       # Aa
      Strong     # ** or __
      Emphasis   # * or _
      CodeSpan   # ``
      CodeBlock  # ``` or ~~~
      HTMLBlock  # <!-- -->
      BlockQuote # >
      ListItem   # - or * or 1-9.

      # LeftBracket  # [
      # RightBracket # ]
      # LeftParen    # (
      # RightParen   # )
      # Colon        # :

      Space
      Newline
      Escape
      EOF
    end

    property kind : Kind
    # getter loc : Location
    @value : String?

    def initialize(@kind : Kind, @value : String? = nil)
    end

    def value : String
      @value.as(String)
    end
  end
end
