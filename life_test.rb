require 'test/unit'
require 'turn/autorun'

require './life'

class LifeWorldTest < Test::Unit::TestCase
  def setup
    @lworld = LifeWorld.new
  end

  def test_world_class_exist
    assert_not_nil @lworld
  end

  def test_has_a_turn_method
    assert_respond_to @lworld, 'turn'
  end

  def test_has_a_state_of_the_world
    assert_respond_to @lworld, 'state'
  end

  def test_state_is_World_object
    assert_instance_of World, @lworld.state
  end

  def test_state_is_World_object_after_turn_also
    @lworld.turn
    assert_instance_of World, @lworld.state
  end

  def test_state_changes_in_turn
    state_before = @lworld.state
    @lworld.turn
    state_after  = @lworld.state
    assert_not_equal(state_before, state_after)
  end
end