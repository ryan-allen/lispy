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
    scenario = Feature.output.expressions.first
    steps = scenario.scope.expressions
    instance_eval &steps[0].proc
    instance_eval &steps[1].proc
  end
end

# OUTPUTS:
# ➜  example git:(no_more_last_last_last) ✗ ruby feature.rb
# {
#            :file => "feature.rb",
#     :expressions => [
#         [0] {
#             :symbol => :Scenario,
#               :args => "this gets lispyified",
#             :lineno => "14",
#               :proc => nil,
#              :scope => {
#                 :expressions => [
#                     [0] {
#                         :symbol => :Given,
#                           :args => "something",
#                         :lineno => "15",
#                           :proc => #<Proc:0x000001010e9140@feature.rb:15>,
#                          :scope => nil
#                     },
#                     [1] {
#                         :symbol => :Then,
#                           :args => "test something exists",
#                         :lineno => "18",
#                           :proc => #<Proc:0x000001010e8ec0@feature.rb:18>,
#                          :scope => nil
#                     }
#                 ]
#             }
#         }
#     ]
# }
# Loaded suite feature
# Started
# E
# Finished in 0.006305 seconds.
#
#   1) Error:
# test_something(Feature):
# RuntimeError: ohai
#     feature.rb:19:in `block (2 levels) in <class:Feature>'
#     feature.rb:34:in `instance_eval'
#     feature.rb:34:in `test_something'
#
# 1 tests, 0 assertions, 0 failures, 1 errors, 0 skips
#
