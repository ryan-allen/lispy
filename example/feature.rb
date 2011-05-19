load '../lib/lispy.rb'

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

Feature.class_eval do
  # manually execute "Given" and "Then" 
  def test_something
    instance_eval &Feature.output[0][2][0][2]
    instance_eval &Feature.output[0][2][1][2]
  end
end

# OUTPUTS:
# [
#     [0] [
#         [0] :Scenario,
#         [1] "this gets lispyified",
#         [2] [
#             [0] [
#                 [0] :Given,
#                 [1] "something",
#                 [2] #<Proc:0x000001010d8ea8@feature.rb:15>
#             ],
#             [1] [
#                 [0] :Then,
#                 [1] "test something exists",
#                 [2] #<Proc:0x000001010d8e08@feature.rb:19>
#             ]
#         ]
#     ]
# ]
# Loaded suite feature
# Started
# E
# Finished in 0.001703 seconds.
# 
#   1) Error:
# test_something(Feature):
# NoMethodError: undefined method `Factory' for #<Feature:0x000001008578b0>
#     feature.rb:16:in `block (2 levels) in <class:Feature>'
#     feature.rb:32:in `instance_eval'
#     feature.rb:32:in `test_something'
