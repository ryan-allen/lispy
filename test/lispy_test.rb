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

  def test_lispy
    expected = [__FILE__, [__LINE__.to_s, :setup, {:workers=>30, :connections=>1024}],
                 [__LINE__.to_s, :http,
                  {:access_log=>:off},
                  [[__LINE__.to_s, :server,
                    {:listen=>80},
                    [[__LINE__.to_s, :location, "/", [[__LINE__.to_s, :doc_root, "/var/www/website"]]],
                     [__LINE__.to_s, :location,
                      "~ .php$",
                      [[__LINE__.to_s, :fcgi, {:port=>8877}], [__LINE__.to_s, :script_root, "/var/www/website"]]]]]]]]

     assert_equal expected, @@whatever
  end

  def test_moar_lispy
    expected = [__FILE__, [[__LINE__.to_s, :setup, []], [__LINE__.to_s, :setup, [], [[__LINE__.to_s, :lol, []], [__LINE__.to_s, :lol, [], [[__LINE__.to_S, :hi, []], [__LINE__.to_s, :hi, []]]]]]]]

    assert_equal expected, @@moar_lispy
  end

  def test_conditionally_preserving_procs
    quasi_sexp = @@retain_blocks
    assert_equal :Scenario, quasi_sexp[1][0]
    assert_equal "My first awesome scenario", quasi_sexp[1][1]
    assert_equal :Given, quasi_sexp[1][2][0][0]
    assert_instance_of Proc, quasi_sexp[1][2][0].last
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
      assert_match "bar", @@opt_out_parsing_error.message
    end
  end
end
