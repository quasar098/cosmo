class Cosmo::StringIntrinsics
  def initialize(
    @interpreter : Interpreter,
    @value : String
  )
  end

  def get_method(name : Token) : IntrinsicFunction
    case name.lexeme
    when "chars"
      Chars.new(@interpreter, @value, name)
    when "blank?"
      Blank.new(@interpreter, @value, name)
    else
      Logger.report_error("Invalid string method", name.lexeme, name)
    end
  end

  class Chars < IntrinsicFunction
    def initialize(
      interpreter : Interpreter,
      @_self : String,
      @token : Token
    )

      super interpreter
    end

    def arity : Range(UInt32, UInt32)
      0.to_u .. 0.to_u
    end

    def call(args : Array(ValueType)) : Array(ValueType)
      TypeChecker.array_as_value_type(@_self.chars)
    end
  end

  class Blank < IntrinsicFunction
    def initialize(
      interpreter : Interpreter,
      @_self : String,
      @token : Token
    )

      super interpreter
    end

    def arity : Range(UInt32, UInt32)
      0.to_u .. 0.to_u
    end

    def call(args : Array(ValueType)) : Bool
      @_self.blank?
    end
  end
end