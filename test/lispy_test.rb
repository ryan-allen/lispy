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
end
