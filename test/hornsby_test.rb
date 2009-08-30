require File.dirname(__FILE__) + '/test_helper'

class HornsbyTest < ActiveSupport::TestCase
  test "apple" do
    hornsby_scenario :just_apple
    assert_not_nil @apple
    assert_equal 'apple', @apple.species
    assert_nil @orange
  end

  test "orange" do
    hornsby_scenario :just_orange
    assert_not_nil @orange
    assert_equal 'orange', @orange.species
    assert_nil @apple
  end
end