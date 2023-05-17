require "./spec_helper"

def assert_var_declaration(
  expr : AST::Expression::Base,
  type : String,
  ident : String,
  constant : Bool = false
) : AST::Expression::Base
  expr.should be_a AST::Expression::VarDeclaration
  declaration = expr.as AST::Expression::VarDeclaration
  declaration.constant?.should eq constant
  declaration.typedef.type.should eq Syntax::TypeDef
  declaration.typedef.value.should eq type
  declaration.typedef.lexeme.should eq type
  declaration.var.should be_a AST::Expression::Var
  declaration.var.token.type.should eq Syntax::Identifier
  declaration.var.token.value.should eq ident
  declaration.var.token.lexeme.should eq ident
  declaration
end

describe Parser do
  describe "parses literals" do
    it "floats" do
      stmts = Parser.new("6.54321", "test", false).parse
      stmts.should_not be_empty
      expr = stmts.first.as(AST::Statement::SingleExpression).expression
      literal = expr.as AST::Expression::FloatLiteral
      literal.should be_a AST::Expression::FloatLiteral
      literal.value.should eq 6.54321
    end
    it "integers" do
      stmts = Parser.new("1234", "test", false).parse
      stmts.should_not be_empty
      expr = stmts.first.as(AST::Statement::SingleExpression).expression
      literal = expr.as AST::Expression::IntLiteral
      literal.should be_a AST::Expression::IntLiteral
      literal.as(AST::Expression::IntLiteral).value.should eq 1234

      stmts = Parser.new("0xABC", "test", false).parse
      stmts.should_not be_empty
      expr = stmts.first.as(AST::Statement::SingleExpression).expression
      literal = expr.as AST::Expression::IntLiteral
      literal.should be_a AST::Expression::IntLiteral
      literal.as(AST::Expression::IntLiteral).value.should eq 2748

      stmts = Parser.new("0b1111", "test", false).parse
      stmts.should_not be_empty
      expr = stmts.first.as(AST::Statement::SingleExpression).expression
      literal = expr.as AST::Expression::IntLiteral
      literal.should be_a AST::Expression::IntLiteral
      literal.value.should eq 15
    end
    it "booleans" do
      stmts = Parser.new("false", "test", false).parse
      stmts.should_not be_empty
      expr = stmts.first.as(AST::Statement::SingleExpression).expression
      literal = expr.as AST::Expression::BooleanLiteral
      literal.should be_a AST::Expression::BooleanLiteral
      literal.value.should be_false

      stmts = Parser.new("true", "test", false).parse
      stmts.should_not be_empty
      expr = stmts.first.as(AST::Statement::SingleExpression).expression
      literal = expr.as AST::Expression::BooleanLiteral
      literal.should be_a AST::Expression::BooleanLiteral
      literal.value.should be_true
    end
    it "none" do
      stmts = Parser.new("none", "test", false).parse
      stmts.should_not be_empty
      expr = stmts.first.as(AST::Statement::SingleExpression).expression
      literal = expr.as AST::Expression::NoneLiteral
      literal.should be_a AST::Expression::NoneLiteral
      literal.value.should eq nil
    end
    it "vectors" do
      stmts = Parser.new("int[] nums = [1, 2, 3]", "test", false).parse
      stmts.should_not be_empty
      expr = stmts.first.as(AST::Statement::SingleExpression).expression
      expr.should be_a AST::Expression::VarDeclaration
      declaration = expr.as AST::Expression::VarDeclaration
      declaration.typedef.type.should eq Syntax::TypeDef
      declaration.typedef.value.should eq "int[]"
      declaration.var.should be_a AST::Expression::Var
      declaration.var.token.type.should eq Syntax::Identifier
      declaration.var.token.value.should eq "nums"
      vector = declaration.value.as AST::Expression::VectorLiteral
      vector.should be_a AST::Expression::VectorLiteral

      vector.values.should be_a Array(AST::Expression::Base)
      list = vector.values.as Array(AST::Expression::Base)
      list.should_not be_empty
      one, two, three = list
      one.as(AST::Expression::IntLiteral).value.should eq 1
      two.as(AST::Expression::IntLiteral).value.should eq 2
      three.as(AST::Expression::IntLiteral).value.should eq 3
    end
    it "tables" do
      stmts = Parser.new("any valid = {yes -> true, no -> false}", "test", false).parse
      stmts.should_not be_empty
      expr = stmts.first.as(AST::Statement::SingleExpression).expression
      expr.should be_a AST::Expression::VarDeclaration
      declaration = expr.as AST::Expression::VarDeclaration
      declaration.typedef.type.should eq Syntax::TypeDef
      declaration.typedef.value.should eq "any"
      declaration.var.should be_a AST::Expression::Var
      declaration.var.token.type.should eq Syntax::Identifier
      declaration.var.token.value.should eq "valid"
      table = declaration.value.as AST::Expression::TableLiteral
      table.should be_a AST::Expression::TableLiteral
      table.hashmap.should_not be_empty
    end
    it "ranges" do
      stmts = Parser.new("1..7", "test", false).parse
      stmts.should_not be_empty
      expr = stmts.first.as(AST::Statement::SingleExpression).expression
      literal = expr.as AST::Expression::RangeLiteral
      literal.should be_a AST::Expression::RangeLiteral
      literal.from.should be_a AST::Expression::IntLiteral
      literal.to.should be_a AST::Expression::IntLiteral
      from = literal.from.as AST::Expression::IntLiteral
      to = literal.to.as AST::Expression::IntLiteral
      from.value.should eq 1
      to.value.should eq 7
    end
  end
  it "parses unary operators" do
    stmts = Parser.new("+-12", "test", false).parse
    stmts.should_not be_empty
    expr = stmts.first.as(AST::Statement::SingleExpression).expression
    unary = expr.as AST::Expression::UnaryOp
    unary.should be_a AST::Expression::UnaryOp
    unary.operator.type.should eq Syntax::Plus

    negate = unary.operand.as AST::Expression::UnaryOp
    negate.should be_a AST::Expression::UnaryOp
    negate.operator.type.should eq Syntax::Minus

    literal = negate.operand.as AST::Expression::IntLiteral
    literal.should be_a AST::Expression::IntLiteral
    literal.value.should eq 12

    stmts = Parser.new("!true", "test", false).parse
    stmts.should_not be_empty
    expr = stmts.first.as(AST::Statement::SingleExpression).expression
    unary = expr.as AST::Expression::UnaryOp
    unary.should be_a AST::Expression::UnaryOp
    unary.operator.type.should eq Syntax::Bang

    literal = unary.operand.as AST::Expression::BooleanLiteral
    literal.should be_a AST::Expression::BooleanLiteral
    literal.value.should be_true

    stmts = Parser.new("*something", "test", false).parse
    stmts.should_not be_empty
    expr = stmts.first.as(AST::Statement::SingleExpression).expression
    unary = expr.as AST::Expression::UnaryOp
    unary.should be_a AST::Expression::UnaryOp
    unary.operator.type.should eq Syntax::Star

    literal = unary.operand.as AST::Expression::Var
    literal.should be_a AST::Expression::Var
    literal.token.type.should eq Syntax::Identifier
    literal.token.value.should eq "something"
    stmts = Parser.new("#my_vec", "test", false).parse
    stmts.should_not be_empty
    expr = stmts.first.as(AST::Statement::SingleExpression).expression
    unary = expr.as AST::Expression::UnaryOp
    unary.should be_a AST::Expression::UnaryOp
    unary.operator.type.should eq Syntax::Hashtag

    literal = unary.operand.as AST::Expression::Var
    literal.should be_a AST::Expression::Var
    literal.token.type.should eq Syntax::Identifier
    literal.token.value.should eq "my_vec"
  end
  it "parses binary operators" do
    stmts = Parser.new("false & true", "test", false).parse
    stmts.should_not be_empty
    expr = stmts.first.as(AST::Statement::SingleExpression).expression
    binary = expr.as AST::Expression::BinaryOp
    binary.should be_a AST::Expression::BinaryOp
    binary.operator.type.should eq Syntax::Ampersand

    left = binary.left.as AST::Expression::BooleanLiteral
    left.should be_a AST::Expression::BooleanLiteral
    left.value.should be_false

    right = binary.right.as AST::Expression::BooleanLiteral
    right.should be_a AST::Expression::BooleanLiteral
    right.value.should be_true

    stmts = Parser.new("10 % 2", "test", false).parse
    stmts.should_not be_empty
    expr = stmts.first.as(AST::Statement::SingleExpression).expression
    binary = expr.as AST::Expression::BinaryOp
    binary.should be_a AST::Expression::BinaryOp
    binary.operator.type.should eq Syntax::Percent

    left = binary.left.as(AST::Expression::IntLiteral)
    left.should be_a AST::Expression::IntLiteral
    left.value.should eq 10

    right = binary.right.as(AST::Expression::IntLiteral)
    right.should be_a AST::Expression::IntLiteral
    right.value.should eq 2

    stmts = Parser.new("16.23 <= 46", "test", false).parse
    stmts.should_not be_empty
    expr = stmts.first.as(AST::Statement::SingleExpression).expression
    binary = expr.as AST::Expression::BinaryOp
    binary.should be_a AST::Expression::BinaryOp
    binary.operator.type.should eq Syntax::LessEqual

    left = binary.left.as(AST::Expression::FloatLiteral)
    left.should be_a AST::Expression::FloatLiteral
    left.value.should eq 16.23

    right = binary.right.as(AST::Expression::IntLiteral)
    right.should be_a AST::Expression::IntLiteral
    right.value.should eq 46
  end
  it "parses variable references" do
    stmts = Parser.new("abc", "test", false).parse
    stmts.should_not be_empty
    expr = stmts.first.as(AST::Statement::SingleExpression).expression
    var = expr.as AST::Expression::Var
    var.should be_a AST::Expression::Var
    var.token.type.should eq Syntax::Identifier
    var.token.value.should eq "abc"

    stmts = Parser.new("_this_isValid$", "test", false).parse
    stmts.should_not be_empty
    expr = stmts.first.as(AST::Statement::SingleExpression).expression
    var = expr.as AST::Expression::Var
    var.should be_a AST::Expression::Var
    var.token.type.should eq Syntax::Identifier
    var.token.value.should eq "_this_isValid$"
  end
  it "parses variable assignments" do
    stmts = Parser.new("abc = 1.234", "test", false).parse
    stmts.should_not be_empty
    expr = stmts.first.as(AST::Statement::SingleExpression).expression
    assignment = expr.as AST::Expression::VarAssignment
    assignment.var.should be_a AST::Expression::Var
    assignment.var.token.type.should eq Syntax::Identifier
    assignment.var.token.value.should eq "abc"
    literal = assignment.value.as AST::Expression::FloatLiteral
    literal.should be_a AST::Expression::FloatLiteral
    literal.value.should eq 1.234

    stmts = Parser.new("_this_isValid$ = false", "test", false).parse
    stmts.should_not be_empty
    expr = stmts.first.as(AST::Statement::SingleExpression).expression
    assignment = expr.as AST::Expression::VarAssignment
    assignment.var.should be_a AST::Expression::Var
    assignment.var.token.type.should eq Syntax::Identifier
    assignment.var.token.value.should eq "_this_isValid$"
    literal = assignment.value.as AST::Expression::BooleanLiteral
    literal.should be_a AST::Expression::BooleanLiteral
    literal.value.should be_false
  end
  it "parses variable declarations" do
    stmts = Parser.new("float abc = 1.234", "test", false).parse
    stmts.should_not be_empty
    expr = stmts.first.as(AST::Statement::SingleExpression).expression
    expr.should be_a AST::Expression::VarDeclaration
    declaration = expr.as AST::Expression::VarDeclaration
    declaration.typedef.type.should eq Syntax::TypeDef
    declaration.typedef.value.should eq "float"
    declaration.var.should be_a AST::Expression::Var
    declaration.var.token.type.should eq Syntax::Identifier
    declaration.var.token.value.should eq "abc"
    literal = declaration.value.as AST::Expression::FloatLiteral
    literal.should be_a AST::Expression::FloatLiteral
    literal.value.should eq 1.234

    stmts = Parser.new("bool _this_isValid$ = false", "test", false).parse
    stmts.should_not be_empty
    expr = stmts.first.as(AST::Statement::SingleExpression).expression
    declaration = expr.as AST::Expression::VarDeclaration
    declaration.typedef.type.should eq Syntax::TypeDef
    declaration.typedef.value.should eq "bool"
    declaration.var.token.type.should eq Syntax::Identifier
    declaration.var.token.value.should eq "_this_isValid$"
    literal = declaration.value.as AST::Expression::BooleanLiteral
    literal.should be_a AST::Expression::BooleanLiteral
    literal.value.should be_false
  end
  it "parses type aliases" do
    stmts = Parser.new("type MyInt = int", "test", false).parse
    stmts.should_not be_empty
    expr = stmts.first.as(AST::Statement::SingleExpression).expression
    expr.should be_a AST::Expression::TypeAlias
    type_alias = expr.as AST::Expression::TypeAlias
    type_alias.type_token.type.should eq Syntax::TypeDef
    type_alias.type_token.value.should eq "type"
    type_alias.var.should be_a AST::Expression::Var
    type_alias.var.token.type.should eq Syntax::Identifier
    type_alias.var.token.value.should eq "MyInt"

    type_alias.value.should be_a AST::Expression::TypeRef
    alias_value = type_alias.value.as AST::Expression::TypeRef
    alias_value.name.value.should eq "int"
  end
  it "parses compound assignment" do
    stmts = Parser.new("int a = 5; a += 2", "test", false).parse
    stmts.should_not be_empty
    expr = stmts.first.as(AST::Statement::SingleExpression).expression
    declaration = assert_var_declaration(expr, "int", "a")
    literal = declaration.value.as AST::Expression::IntLiteral
    literal.should be_a AST::Expression::IntLiteral
    literal.value.should eq 5

    expr = stmts.last.as(AST::Statement::SingleExpression).expression
    expr.should be_a AST::Expression::CompoundAssignment
    assignment = expr.as AST::Expression::CompoundAssignment
    assignment.name.type.should eq Syntax::Identifier
    assignment.name.value.should eq "a"
    assignment.operator.type.should eq Syntax::PlusEqual
    literal = assignment.value.as AST::Expression::IntLiteral
    literal.should be_a AST::Expression::IntLiteral
    literal.value.should eq 2
  end
  it "parses property assignment" do
    stmts = Parser.new("foo::bar = \"baz\"", "test", false).parse
    stmts.should_not be_empty
    expr = stmts.first.as(AST::Statement::SingleExpression).expression
    expr.should be_a AST::Expression::PropertyAssignment
    assignment = expr.as AST::Expression::PropertyAssignment
    assignment.object.should be_a AST::Expression::Access
    access = assignment.object.as AST::Expression::Access
    access.key.should be_a Token
    access.key.lexeme.should eq "bar"
    access.object.should be_a AST::Expression::Var
    access.object.as(AST::Expression::Var).token.lexeme.should eq "foo"
    assignment.value.should be_a AST::Expression::StringLiteral
    assignment.value.as(AST::Expression::StringLiteral).value.should eq "baz"
  end
  it "parses function definitions & calls" do
    lines = [
      "bool fn is_eq(int a, int b) {",
      " a == b",
      "}",
      "is_eq(1, 1)",
    ]
    stmts = Parser.new(lines.join('\n'), "test", false).parse
    stmts.should_not be_empty
    function_def = stmts.first.as AST::Statement::FunctionDef
    function_def.parameters.should_not be_empty
    function_def.parameters.first.typedef.value.should eq "int"
    function_def.parameters.first.identifier.value.should eq "a"
    function_def.parameters.last.typedef.value.should eq "int"
    function_def.parameters.last.identifier.value.should eq "b"
    function_def.identifier.value.should eq "is_eq"
    function_def.body.nodes.should_not be_empty
    function_def.return_typedef.type.should eq Syntax::TypeDef
    function_def.return_typedef.value.should eq "bool"

    expr = function_def.body.nodes.first.as(AST::Statement::SingleExpression).expression
    expr.should be_a AST::Expression::BinaryOp

    expr = stmts.last.as(AST::Statement::SingleExpression).expression
    function_call = expr.as AST::Expression::FunctionCall
    function_call.token.type.should eq Syntax::Identifier
    function_call.token.value.should eq "is_eq"
    arg1, arg2 = function_call.arguments

    arg1.should be_a AST::Expression::IntLiteral
    arg1.as(AST::Expression::IntLiteral).value.should eq 1
    arg2.should be_a AST::Expression::IntLiteral
    arg2.as(AST::Expression::IntLiteral).value.should eq 1

    stmts = Parser.new(lines.last + " == none", "test", false).parse
    stmts.should_not be_empty
    expr = stmts.first.as(AST::Statement::SingleExpression).expression
    binary = expr.as AST::Expression::BinaryOp
    function_call = binary.left.as AST::Expression::FunctionCall
    function_call.token.type.should eq Syntax::Identifier
    function_call.token.value.should eq "is_eq"

    binary.operator.type.should eq Syntax::EqualEqual
    binary.right.should be_a AST::Expression::NoneLiteral

    lines = [
      "void fn say_hi() {",
      " puts(\"hi\")",
      "}",
      "say_hi()",
    ]
    stmts = Parser.new(lines.join('\n'), "test", false).parse
    stmts.should_not be_empty
    function_def = stmts.first.as AST::Statement::FunctionDef
    function_def.parameters.empty?.should be_true
    function_def.identifier.value.should eq "say_hi"
    function_def.body.nodes.should_not be_empty
    function_def.return_typedef.type.should eq Syntax::TypeDef
    function_def.return_typedef.value.should eq "void"

    expr = function_def.body.nodes.first.as(AST::Statement::SingleExpression).expression
    expr.should be_a AST::Expression::FunctionCall
    function_call = expr.as AST::Expression::FunctionCall
    function_call.token.type.should eq Syntax::Identifier
    function_call.token.value.should eq "puts"

    arg = function_call.arguments.first
    arg.should be_a AST::Expression::StringLiteral
    arg.as(AST::Expression::StringLiteral).value.should eq "hi"

    expr = stmts.last.as(AST::Statement::SingleExpression).expression
    function_call = expr.as AST::Expression::FunctionCall
    function_call.token.type.should eq Syntax::Identifier
    function_call.token.value.should eq "say_hi"
    function_call.arguments.empty?.should be_true
  end
  it "parses vector indexing" do
    stmts = Parser.new("int[] x = [1, 2]; x[0]", "test", false).parse
    stmts.should_not be_empty
    expr = stmts.last.as(AST::Statement::SingleExpression).expression
    index = expr.as AST::Expression::Index
    index.object.token.type.should eq Syntax::Identifier
    index.object.token.value.should eq "x"

    index.key.should be_a AST::Expression::IntLiteral
    key = index.key.as AST::Expression::IntLiteral
    key.value.should eq 0
  end
  it "parses if/unless statements" do
    lines = [
      "int x = 5",
      "if x == 5 {",
      " puts(\"x is 5\")",
      "} else {",
      " puts(\"x is not 5\")",
      "}"
    ]

    stmts = Parser.new(lines.join('\n'), "test", false).parse
    stmts.should_not be_empty
    expr = stmts.first.as(AST::Statement::SingleExpression).expression
    declaration = assert_var_declaration(expr, "int", "x")
    literal = declaration.value.as AST::Expression::IntLiteral
    literal.should be_a AST::Expression::IntLiteral
    literal.value.should eq 5

    stmts.last.should be_a AST::Statement::If
    if_stmt = stmts.last.as AST::Statement::If
    if_stmt.condition.should be_a AST::Expression::BinaryOp
    if_stmt.then.should be_a AST::Statement::Block
    if_stmt.else.should be_a AST::Statement::Block

    lines = [
      "string name = \"bob\"",
      "unless name == \"bob\" {",
      " puts(\"ur not bob... >:(\")",
      "} else {",
      " puts(\"it's bob!!!!11 :D\")",
      "}"
    ]

    stmts = Parser.new(lines.join('\n'), "test", false).parse
    stmts.should_not be_empty
    expr = stmts.first.as(AST::Statement::SingleExpression).expression
    declaration = assert_var_declaration(expr, "string", "name")
    literal = declaration.value.as AST::Expression::StringLiteral
    literal.should be_a AST::Expression::StringLiteral
    literal.value.should eq "bob"

    stmts.last.should be_a AST::Statement::Unless
    unless_stmt = stmts.last.as AST::Statement::Unless
    unless_stmt.condition.should be_a AST::Expression::BinaryOp
    unless_stmt.then.should be_a AST::Statement::Block
    unless_stmt.else.should be_a AST::Statement::Block
  end
  it "parses while/until statements" do
    lines = [
      "while true {",
      " puts(\"h\")",
      "}"
    ]

    stmts = Parser.new(lines.join('\n'), "test", false).parse
    stmts.should_not be_empty
    stmts.first.should be_a AST::Statement::While
    while_stmt = stmts.first.as AST::Statement::While
    while_stmt.condition.should be_a AST::Expression::BooleanLiteral
    while_stmt.condition.as(AST::Expression::BooleanLiteral).value.should eq true
    while_stmt.block.should be_a AST::Statement::Block

    lines = [
      "until false {",
      " puts(\"h\")",
      "}"
    ]

    stmts = Parser.new(lines.join('\n'), "test", false).parse
    stmts.should_not be_empty
    stmts.first.should be_a AST::Statement::Until
    while_stmt = stmts.first.as AST::Statement::Until
    while_stmt.condition.should be_a AST::Expression::BooleanLiteral
    while_stmt.condition.as(AST::Expression::BooleanLiteral).value.should eq false
    while_stmt.block.should be_a AST::Statement::Block
  end
  it "parses every statements" do
    lines = [
      "const int[] nums = [1,2,3]",
      "int sum = 0",
      "every const int n in nums {",
      " sum += n",
      "}"
    ]

    stmts = Parser.new(lines.join('\n'), "test", false).parse
    stmts.should_not be_empty

    expr = stmts.first.as(AST::Statement::SingleExpression).expression
    declaration = assert_var_declaration(expr, "int[]", "nums", constant: true)
    literal = declaration.value.as AST::Expression::VectorLiteral
    literal.should be_a AST::Expression::VectorLiteral
    literal.values.first.should be_a AST::Expression::IntLiteral

    expr = stmts[1].as(AST::Statement::SingleExpression).expression
    declaration = assert_var_declaration(expr, "int", "sum")
    literal = declaration.value.as AST::Expression::IntLiteral
    literal.should be_a AST::Expression::IntLiteral
    literal.value.should eq 0

    stmts.last.should be_a AST::Statement::Every
    every_stmt = stmts.last.as AST::Statement::Every
    declaration = assert_var_declaration(every_stmt.var, "int", "n", constant: true)
    every_stmt.enumerable.should be_a AST::Expression::Var
    every_stmt.block.nodes.first.should be_a AST::Statement::SingleExpression
    expr = every_stmt.block.nodes.first.as AST::Statement::SingleExpression
    expr.expression.should be_a AST::Expression::CompoundAssignment
  end
end
