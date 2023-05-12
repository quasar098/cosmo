require "./spec_helper"

describe Lexer do
  it "throws for unexpected characters" do
    lexer = Cosmo::Lexer.new("@/\\", "test")
    expect_raises(Exception, "[1:1] Unexpected character: @") { lexer.tokenize }
  end
  it "lexes floats" do
    tokens = Cosmo::Lexer.new("1234.4321", "test").tokenize
    tokens.first.type.should eq Syntax::Float
    tokens.first.value.should eq 1234.4321
  end
  it "lexes integers" do
    tokens = Cosmo::Lexer.new("1234", "test").tokenize
    tokens.first.type.should eq Syntax::Integer
    tokens.first.value.should eq 1234
  end
  it "lexes booleans" do

  end
  it "lexes hex literals" do

  end
  it "lexes binary literals" do

  end
  it "lexes none value" do

  end
  it "lexes strings" do

  end
  it "lexes chars" do

  end
  it "lexes identifiers" do

  end
  it "lexes keywords" do

  end
  it "lexes type keywords" do

  end
  it "lexes other characters" do

  end
end