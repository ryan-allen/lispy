require 'test/unit'
require 'lispy'

class LispyTest < Test::Unit::TestCase
  def teardown
    Lispy.reset
  end

  Lispy.reset
  class Whatever
    extend Lispy

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

  def test_lispy
    expected = [[:setup, {:workers=>30, :connections=>1024}],
                 [:http,
                  {:access_log=>:off},
                  [[:server,
                    {:listen=>80},
                    [[:location, "/", [[:doc_root, "/var/www/website"]]],
                     [:location,
                      "~ .php$",
                      [[:fcgi, {:port=>8877}], [:script_root, "/var/www/website"]]]]]]]]

     assert_equal expected, @@whatever
  end

  Lispy.reset
  class MoarLispy
    extend Lispy

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

  def test_moar_lispy
    expected = [[:setup, []], [:setup, [], [[:lol, []], [:lol, [], [[:hi, []], [:hi, []]]]]]]

    assert_equal expected, @@moar_lispy
  end

  Lispy.reset
  Lispy.configure(:retain_blocks_for => [:Given, :When, :Then])
  class RetainBlocks
    extend Lispy

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

  def test_conditionally_preserving_procs
    quasi_sexp = @@retain_blocks
    assert_equal :Scenario, quasi_sexp[0][0]
    assert_equal "My first awesome scenario", quasi_sexp[0][1]
    assert_equal :Given, quasi_sexp[0][2][0][0]
    assert_instance_of Proc, quasi_sexp[0][2][0].last
  end

  Lispy.reset
  Lispy.configure(:only => [:Foo])
  begin
    class OptInParsing
      extend Lispy

      Foo "bar" do
        blech
      end
    end
  rescue 
    @@opt_in_parsing_error = $!
  end

  def test_opt_in_parsing
    assert_instance_of NoMethodError, @@opt_in_parsing_error
    assert_match "blech", @@opt_in_parsing_error.message
  end

  Lispy.reset
  Lispy.configure(:except => [:bar])
  begin
    @@opt_out_parsing_fail = false
    class OptOutParsing
      extend Lispy 

      foo "bar" do
        blech
      end

      bar
    end
    @@opt_out_parsing_fail = true
  rescue
    @@opt_out_parsing_error = $!
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
