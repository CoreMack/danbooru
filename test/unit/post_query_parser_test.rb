require 'test_helper'

class PostQueryParserTest < ActiveSupport::TestCase
  def assert_parse_equals(expected, input)
    assert_equal(expected, PostQuery::Parser.parse(input).simplify.to_sexp)
  end

  context "PostQueryParser:" do
    should "parse empty queries correctly" do
      assert_parse_equals("all", "")
      assert_parse_equals("all", " ")
    end

    should "parse basic tags correctly" do
      assert_parse_equals("a", "a")
      assert_parse_equals("a", "A")

      assert_parse_equals("foo_(bar)", "foo_(bar)")
      assert_parse_equals("foo_(bar)", "(foo_(bar))")

      assert_parse_equals("foo_(bar_(baz))", "foo_(bar_(baz))")
      assert_parse_equals("foo_(bar_(baz))", "(foo_(bar_(baz)))")

      assert_parse_equals(";)", ";)")
      assert_parse_equals("9", "(9)")
    end

    should "parse basic queries correctly" do
      assert_parse_equals("(and a b)", "a b")
      assert_parse_equals("(or a b)", "a or b")
      assert_parse_equals("(or a b)", "~a ~b")

      assert_parse_equals("(not a)", "-a")
      assert_parse_equals("(and (not b) a)", "a -b")

      assert_parse_equals("fav:a", "fav:a")
      assert_parse_equals("(not fav:a)", "-fav:a")

      assert_parse_equals("(and fav:a fav:b)", "fav:a fav:b")
    end

    should "parse metatags correctly" do
      assert_parse_equals("fav:a", "fav:a")
      assert_parse_equals("user:a", "user:a")
      assert_parse_equals("pool:a", "pool:a")
      assert_parse_equals("order:a", "order:a")
      assert_parse_equals("source:a", "source:a")

      assert_parse_equals("fav:a", "FAV:a")
      assert_parse_equals("fav:A", "fav:A")

      assert_parse_equals("fav:a", "~fav:a")
      assert_parse_equals("(not fav:a)", "-fav:a")

      assert_parse_equals("(and fav:a fav:b)", "fav:a fav:b")
      assert_parse_equals("(or fav:a fav:b)", "~fav:a ~fav:b")
      assert_parse_equals("(or fav:a fav:b)", "fav:a or fav:b")

      assert_parse_equals("fav:a", "(fav:a)")
      assert_parse_equals("fav:(a)", "fav:(a)")
      assert_parse_equals("fav:(a", "(fav:(a)")

      assert_parse_equals('source:foo bar', 'source:"foo bar"')
      assert_parse_equals('source:foobar"(', 'source:foobar"(')
      assert_parse_equals('source:', 'source:""')
      assert_parse_equals(%q{source:don't say "lazy" okay}, %q{source:"don't say \"lazy\" okay"})
      assert_parse_equals(%q{(and source:foo)bar a)}, %q{(a (source:"foo)bar"))})
    end

    should "parse wildcard tags correctly" do
      assert_parse_equals("(wildcard *)", "*")
      assert_parse_equals("(wildcard *a)", "*a")
      assert_parse_equals("(wildcard a*)", "a*")
      assert_parse_equals("(wildcard *a*)", "*a*")
      assert_parse_equals("(wildcard a*b)", "a*b")

      assert_parse_equals("(and b (wildcard *))", "* b")
      assert_parse_equals("(and b (wildcard *a))", "*a b")
      assert_parse_equals("(and b (wildcard a*))", "a* b")
      assert_parse_equals("(and b (wildcard *a*))", "*a* b")

      assert_parse_equals("(and a (wildcard *))", "a *")
      assert_parse_equals("(and a (wildcard *b))", "a *b")
      assert_parse_equals("(and a (wildcard b*))", "a b*")
      assert_parse_equals("(and a (wildcard *b*))", "a *b*")

      assert_parse_equals("(and (not (wildcard *)) a)", "a -*")
      assert_parse_equals("(and (not (wildcard b*)) a)", "a -b*")
      assert_parse_equals("(and (not (wildcard *b)) a)", "a -*b")
      assert_parse_equals("(and (not (wildcard *b*)) a)", "a -*b*")

      assert_parse_equals("(or a (wildcard *))", "~a ~*")
      assert_parse_equals("(or a (wildcard *))", "~* ~a")
      assert_parse_equals("(or a (wildcard *a))", "~a ~*a")
      assert_parse_equals("(or a (wildcard *a))", "~*a ~a")

      assert_parse_equals("(or a (wildcard a*))", "a or a*")
      assert_parse_equals("(and a (wildcard a*))", "a and a*")

      assert_parse_equals("(and (wildcard a*) (wildcard b*))", "a* b*")
      assert_parse_equals("(or (wildcard a*) (wildcard b*))", "a* or b*")

      assert_parse_equals("(and a c (wildcard b*))", "a b* c")
      assert_parse_equals("(and (not (wildcard *)) a c)", "a -* c")
    end

    should "parse single tag queries correctly" do
      assert_parse_equals("a", "a")
      assert_parse_equals("a", "a ")
      assert_parse_equals("a", " a")
      assert_parse_equals("a", " a ")
      assert_parse_equals("a", "(a)")
      assert_parse_equals("a", "( a)")
      assert_parse_equals("a", "(a )")
      assert_parse_equals("a", " ( a ) ")
      assert_parse_equals("a", "((a))")
      assert_parse_equals("a", "( ( a ) )")
      assert_parse_equals("a", " ( ( a ) ) ")
    end

    should "parse nested AND queries correctly" do
      assert_parse_equals("(and a b)", "a b")
      assert_parse_equals("(and a b)", "(a b)")
      assert_parse_equals("(and a b)", "a (b)")
      assert_parse_equals("(and a b)", "(a) b")
      assert_parse_equals("(and a b)", "(a) (b)")
      assert_parse_equals("(and a b)", "((a) (b))")

      assert_parse_equals("(and a b c)", "a b c")
      assert_parse_equals("(and a b c)", "(a b) c")
      assert_parse_equals("(and a b c)", "((a) b) c")
      assert_parse_equals("(and a b c)", "(((a) b) c)")
      assert_parse_equals("(and a b c)", "((a b) c)")
      assert_parse_equals("(and a b c)", "((a) (b) (c))")

      assert_parse_equals("(and a b c)", "a (b c)")
      assert_parse_equals("(and a b c)", "a (b (c))")
      assert_parse_equals("(and a b c)", "(a (b (c)))")
      assert_parse_equals("(and a b c)", "(a (b c))")
      assert_parse_equals("(and a b c)", "(a b c)")

      assert_parse_equals("(and a b)", "a and b")
      assert_parse_equals("(and a b)", "a AND b")
      assert_parse_equals("(and a b)", "(a and b)")
      assert_parse_equals("(and a b c)", "a and b and c")
      assert_parse_equals("(and a b c)", "(a and b) and c")
      assert_parse_equals("(and a b c)", "a and (b and c)")
      assert_parse_equals("(and a b c)", "(a and b and c)")
    end

    should "parse nested OR queries correctly" do
      assert_parse_equals("(or a b)", "a or b")
      assert_parse_equals("(or a b)", "a OR b")
      assert_parse_equals("(or a b)", "(a or b)")
      assert_parse_equals("(or a b)", "(a) or (b)")

      assert_parse_equals("(or a b c)", "a or b or c")
      assert_parse_equals("(or a b c)", "(a or b) or c")
      assert_parse_equals("(or a b c)", "a or (b or c)")
      assert_parse_equals("(or a b c)", "(a or b or c)")

      assert_parse_equals("(or a b c d)", "a or (b or (c or d))")
      assert_parse_equals("(or a b c d)", "((a or b) or c) or d")
      assert_parse_equals("(or a b c d)", "(a or b) or (c or d)")
    end

    should "parse the '~' operator correctly" do
      assert_parse_equals("(or a b)", "~a ~b")
      assert_parse_equals("(or a b c)", "~a ~b ~c")
      assert_parse_equals("(or a b c d)", "~a ~b ~c ~d")

      assert_parse_equals("a", "~a")
      assert_parse_equals("a", "(~a)")
      assert_parse_equals("a", "~(a)")
      assert_parse_equals("a", "~(~a)")
      assert_parse_equals("a", "~(~(~a))")

      assert_parse_equals("(not a)", "~(-a)")
      assert_parse_equals("(not a)", "-(~a)")
      assert_parse_equals("a", "-(~(-(~a)))")
      assert_parse_equals("a", "~(-(~(-a)))")

      assert_parse_equals("(and a b)", "a ~b")
      assert_parse_equals("(and a b)", "~a b")
      assert_parse_equals("(and a b)", "((a) ~b)")
      assert_parse_equals("(and a b)", "~(a b)")

      assert_parse_equals("(and a b)", "~a and ~b")
      assert_parse_equals("(or a b)", "~a or ~b")
      assert_parse_equals("(or (not a) (not b))", "~(-a) or ~(-b)")

      assert_parse_equals("(or a b)", "~(a) ~(b)")
      assert_parse_equals("(and a b)", "(~a) (~b)")

      assert_parse_equals("(and (or b c) a)", "(~a) ~b ~c")
      assert_parse_equals("(and (or b c) a)", "~a (~b ~c)")

      assert_parse_equals("(or a b c d)", "~a ~b or ~c ~d")
      assert_parse_equals("(and (or a b) (or c d))", "~a ~b and ~c ~d")
      assert_parse_equals("(and (or a b) (or c d))", "(~a ~b) (~c ~d)")
      assert_parse_equals("(and (or a c) (or a d) (or b c) (or b d))", "~(a b) ~(c d)")
      assert_parse_equals("(and (or a c) (or a d) (or b c) (or b d))", "(a b) or (c d)")

      assert_parse_equals("(and a b c d)",      " a  b  c  d")
      assert_parse_equals("(and a b c d)",      " a  b  c ~d")
      assert_parse_equals("(and a b c d)",      " a  b ~c  d")
      assert_parse_equals("(and (or c d) a b)", " a  b ~c ~d")
      assert_parse_equals("(and a b c d)",      " a ~b  c  d")
      assert_parse_equals("(and (or b d) a c)", " a ~b  c ~d")
      assert_parse_equals("(and (or b c) a d)", " a ~b ~c  d")
      assert_parse_equals("(and (or b c d) a)", " a ~b ~c ~d")
      assert_parse_equals("(and a b c d)",      "~a  b  c  d")
      assert_parse_equals("(and (or a d) b c)", "~a  b  c ~d")
      assert_parse_equals("(and (or a c) b d)", "~a  b ~c  d")
      assert_parse_equals("(and (or a c d) b)", "~a  b ~c ~d")
      assert_parse_equals("(and (or a b) c d)", "~a ~b  c  d")
      assert_parse_equals("(and (or a b d) c)", "~a ~b  c ~d")
      assert_parse_equals("(and (or a b c) d)", "~a ~b ~c  d")
      assert_parse_equals("(or a b c d)",       "~a ~b ~c ~d")
    end

    should "parse NOT queries correctly" do
      assert_parse_equals("(not a)", "-a")

      assert_parse_equals("(and (not b) a)", "(a -b)")
      assert_parse_equals("(and (not b) a)", "a (-b)")
      assert_parse_equals("(and (not b) a)", "((a) -b)")
    end

    should "eliminate double negations" do
      assert_parse_equals("(not a)", "-a")
      assert_parse_equals("(not a)", "-(-(-a))")

      assert_parse_equals("a", "-(-a)")
      assert_parse_equals("a", "-(-(-(-a)))")

      assert_parse_equals("(and a b c)", "a -(-(b)) c")
      assert_parse_equals("(and a b c d)", "a -(-(b -(-c))) d")
    end

    should "apply DeMorgan's law" do
      assert_parse_equals("(or (not a) (not b))", "-(a b)")
      assert_parse_equals("(and (not a) (not b))", "-(a or b)")

      assert_parse_equals("(or (not a) (not b) (not c))", "-(a b c)")
      assert_parse_equals("(and (not a) (not b) (not c))", "-(a or b or c)")

      assert_parse_equals("(or a b c)", "-(-a -b -c)")
      assert_parse_equals("(and a b c)", "-(-a or -b or -c)")

      assert_parse_equals("(and (or (not a) (not c) (not d)) (or (not a) b))", "-(a -(b -(c d)))")
    end

    should "apply the distributive law" do
      assert_parse_equals("(and (or a b) (or a c))", "a or (b c)")
      assert_parse_equals("(and (or a b) (or a c))", "(b c) or a")

      assert_parse_equals("(and (or a c) (or a d) (or b c) (or b d))", "(a b) or (c d)")

      assert_parse_equals("(and (or a c e) (or a c f) (or a d e) (or a d f) (or b c e) (or b c f) (or b d e) (or b d f))", "(a b) or (c d) or (e f)")
    end

    should "return the empty search for syntax errors" do
      assert_parse_equals("none", "(")
      assert_parse_equals("none", ")")
      assert_parse_equals("none", "-")
      assert_parse_equals("none", "~")

      assert_parse_equals("none", "(a")
      assert_parse_equals("none", ")a")
      assert_parse_equals("none", "-~a")
      assert_parse_equals("none", "~-a")
      assert_parse_equals("none", "~~a")
      assert_parse_equals("none", "--a")

      assert_parse_equals("none", "and")
      assert_parse_equals("none", "-and")
      assert_parse_equals("none", "~and")
      assert_parse_equals("none", "or")
      assert_parse_equals("none", "-or")
      assert_parse_equals("none", "~or")
      assert_parse_equals("none", "a and")
      assert_parse_equals("none", "a or")
      assert_parse_equals("none", "and a")
      assert_parse_equals("none", "or a")

      assert_parse_equals("none", "a -")
      assert_parse_equals("none", "a ~")

      assert_parse_equals("none", "(a b")
      assert_parse_equals("none", "(a (b)")

      assert_parse_equals("none", 'source:"foo')
      assert_parse_equals("none", 'source:"foo bar')
    end
  end
end
