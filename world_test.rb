require 'test/unit'
require 'turn/autorun'

require './world'

class WorldTest < Test::Unit::TestCase
  def setup
    @wstate = World.new
  end

  def test_world_state_class_exist
    assert_not_nil @wstate
  end

  def test_to_s_returns_text_of_dots_and_asterisks
    assert_kind_of String, @wstate.to_s
    assert_match /^[.*\n]*$/, @wstate.to_s
  end

end
