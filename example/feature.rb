load 'lib/lispy.rb'

require 'test/unit'

class Feature < Test::Unit::TestCase
  PROC_KEYWORDS = [:Given, :When, :Then, :And]
  KEYWORDS = [:Scenario, :Tag] + PROC_KEYWORDS

  extend Lispy
  acts_lispy :only => KEYWORDS, :retain_blocks_for => PROC_KEYWORDS

  # Everything after this gets lispyified

  Scenario "this gets lispyified" do
    Given "something" do
      @something = Factory(:something)
    end

    Then "test something exists" do
      fail "ohai"
    end
  end
end

require 'rubygems'
require 'awesome_print'
ap Feature.output

# [
#     [0] [
#         [0] :Scenario,
#         [1] "this gets lispyified",
#         [2] [
#             [0] [
#                 [0] :Given,
#                 [1] "something",
#                 [2] #<Proc:0x00000100923758@feature.rb:15>
#             ],
#             [1] [
#                 [0] :Then,
#                 [1] "test something exists",
#                 [2] #<Proc:0x000001009236b8@feature.rb:19>
#             ]
#         ]
#     ]
# ]
# 
