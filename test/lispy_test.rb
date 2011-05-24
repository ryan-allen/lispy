require 'test/unit'
require 'lispy'

class LispyTest < Test::Unit::TestCase
  class Whatever
    extend Lispy
    acts_lispy

    setup :workers => 30, :connections => 1024
    http :access_log => :off do
      server :listen => 80 do
        location '/' do
          doc_root '/var/www/website'
        end
        location '~ .php$' do
          fcgi :port => 8877
          script_root '/var/www/website'
        end
      end
    end
    ohai
  end
  @@whatever = Whatever.output

  class MoarLispy
    extend Lispy
    acts_lispy

    setup
    setup do
      lol
      lol do
        hi
        hi
      end
    end
  end
  @@moar_lispy = MoarLispy.output

  class RetainBlocks
    extend Lispy
    acts_lispy :retain_blocks_for => [:Given, :When, :Then]

    Scenario "My first awesome scenario" do
      Given "teh shiznit" do
        #shiznit
      end

      When "I do something" do
        #komg.do_something
      end

      Then "this is pending"
    end
  end
  @@retain_blocks = RetainBlocks.output

  begin
    class OptInParsing
      extend Lispy
      acts_lispy :only => [:Foo]

      Foo "bar" do
        blech
      end
    end
  rescue
    @@opt_in_parsing_error = $!
  end

  begin
    class OptOutParsing
      extend Lispy
      acts_lispy :except => [:blech]

      Foo "bar" do
        blech
      end
    end
  rescue
    @@opt_out_parsing_error = $!
  end

  def test_lispy
    expected = [
      __FILE__,
      [
        Lispy::Expression.new(:setup, {:workers=>30, :connections=>1024}, "9"),
        Lispy::Expression.new(:http, {:access_log =>:off}, "10"),
        Lispy::Scope.new.tap { |s1| s1.expressions = [
          Lispy::Expression.new(:server, {:listen=>80}, "11"),
          Lispy::Scope.new.tap { |s2| s2.expressions = [
            Lispy::Expression.new(:location, '/', "12"),
            Lispy::Scope.new.tap { |s3| s3.expressions = [
              Lispy::Expression.new(:doc_root, '/var/www/website', "13")
            ]},
            Lispy::Expression.new(:location, '~ .php$', "15"),
            Lispy::Scope.new.tap { |s4| s4.expressions = [
              Lispy::Expression.new(:fcgi, {:port => 8877}, "16"),
              Lispy::Expression.new(:script_root, '/var/www/website', "17")
            ]}
          ]}
        ]},
        Lispy::Expression.new(:ohai, [], "21")
      ]
    ]
    assert_equal expected, @@whatever
  end

  def test_moar_lispy
    expected = [__FILE__, ["28", :setup, []], ["29", :setup, [], [["30", :lol, []], ["31", :lol, [], [["32", :hi, []], ["33", :hi, []]]]]]]

    assert_equal expected, @@moar_lispy
  end

  def test_conditionally_preserving_procs
    quasi_sexp = @@retain_blocks
    assert_equal :Scenario, quasi_sexp[1][1]
    assert_equal "My first awesome scenario", quasi_sexp[1][2]
    require 'awesome_print'
    assert_equal :Given, quasi_sexp[1][3][0][1]
    assert_instance_of Proc, quasi_sexp[1][3][0].last
  end

  def test_opt_in_parsing
    assert_instance_of NoMethodError, @@opt_in_parsing_error
    assert_match "blech", @@opt_in_parsing_error.message
  end

  def test_opt_out_parsing
    begin
      flunk if @@opt_out_parsing_fail
    rescue
      assert_instance_of NoMethodError, @@opt_out_parsing_error
      assert_match "blech", @@opt_out_parsing_error.message
    end
  end
end
