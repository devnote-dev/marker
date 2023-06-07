module Marker::CommonMark
  abstract class Node
  end

  class SyntaxTree < Node
    property nodes : Array(Node)

    def initialize(@nodes)
    end
  end

  class Heading < Node
    property level : Int32
    property value : Array(Node)

    def initialize(@level, @value)
    end
  end

  class Paragraph < Node
    property value : Array(Node)

    def initialize(@value)
    end
  end

  class Text < Node
    property value : String

    def initialize(@value)
    end
  end

  class Strong < Node
    property? asterisk : Bool
    property? underscore : Bool
    property value : Array(Node)

    def initialize(@asterisk, @value)
      @underscore = !@asterisk
    end
  end

  class Emphasis < Node
    property? asterisk : Bool
    property? underscore : Bool
    property value : Array(Node)

    def initialize(@asterisk, @value)
      @underscore = !@asterisk
    end
  end

  class CodeSpan < Node
    property value : String

    def initialize(@value)
    end
  end

  class CodeBlock < Node
    enum Kind
      Backtick
      Tilde
    end

    property kind : Kind
    property info : String?
    property value : String

    def initialize(@kind, @info, @value)
    end
  end

  class BlockQuote < Node
    property value : Array(Node)

    def initialize(@value)
    end
  end

  class List < Node
    property items : Array(Node)

    def initialize(@items)
    end
  end
end
