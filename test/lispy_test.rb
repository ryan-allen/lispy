require 'test/unit'
require 'lispy'

class LispyTest < Test::Unit::TestCase
  def test_lispy
    output = Lispy.new.to_data do 
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
    

    expected = [[:setup, {:workers=>30, :connections=>1024}],
                 [:http,
                  {:access_log=>:off},
                  [[:server,
                    {:listen=>80},
                    [[:location, "/", [[:doc_root, "/var/www/website"]]],
                     [:location,
                      "~ .php$",
                      [[:fcgi, {:port=>8877}], [:script_root, "/var/www/website"]]]]]]]]

     assert_equal expected, output
  end

  def test_moar_lispy
    output = Lispy.new.to_data do
      setup
      setup do
        lol
        lol do
          hi
          hi
        end
      end
    end

    expected = [[:setup, []], [:setup, [], [[:lol, []], [:lol, [], [[:hi, []], [:hi, []]]]]]]

    assert_equal expected, output
  end

  def lispy_but_conditionally_preserving_procs
    Lispy.new.to_data(:retain_blocks_for => [:Given, :When, :Then]) do
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
  end

  def test_conditionally_preserving_procs
    quasi_sexp = lispy_but_conditionally_preserving_procs
    assert_equal :Scenario, quasi_sexp[0][0]
    assert_equal "My first awesome scenario", quasi_sexp[0][1]
    assert_equal :Given, quasi_sexp[0][2][0][0]
    assert_instance_of Proc, quasi_sexp[0][2][0].last
  end

  def test_opt_in_parsing
    l = Lispy.new
    begin
      l.to_data(:only => [:Foo]) do
        Foo "bar" do
          blech
        end
      end
    rescue 
      assert_instance_of NoMethodError, $!
      assert_match "blech", $!.message
    end
  end

  def test_opt_out_parsing
    l = Lispy.new
    begin
      l.to_data(:except => [:bar]) do
        foo "bar" do
          blech
        end

        bar
      end
      flunk
    rescue
      assert_instance_of NoMethodError, $!
      assert_match "bar", $!.message
    end
  end
end
