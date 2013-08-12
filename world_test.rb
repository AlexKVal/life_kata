require 'test/unit'
require 'turn/autorun'

Turn.config.format = :dot

require './world'

class WorldTest < Test::Unit::TestCase
  def setup
    @world = World.new("..\n..")
  end

  def test_initializing_with_text_of_dots_and_asterisks
    assert_nothing_raised( ArgumentError ) {World.new("..*\n**.")}
    assert_raise( ArgumentError ) {World.new("..\n34")}
  end

  def test_to_text_returns_text_of_dots_and_asterisks
    assert_kind_of String, @world.to_text
    assert_match /^[.*\n]*$/, @world.to_text
  end

  def test_minimal_world_is_2x2_dot_cells
    assert_equal( World.new.to_text, "..\n.." )
  end

  def test_initial_text_world_has_to_be_rectangle
    assert_raise( ArgumentError ) {World.new("**")}
    assert_raise( ArgumentError ) {World.new("**\n*")}
    assert_raise( ArgumentError ) {World.new("**\n*.\n***...***")}
    assert_nothing_raised( ArgumentError ) {World.new("..***\n.....\n*****")}
  end

  def test_initial_text_world_cant_end_with_a_new_line
    assert_nothing_raised( ArgumentError ) {World.new("..*\n...\n")}
  end

  def test_initial_text_world_has_to_be_at_least_2x2_or_bigger
    assert_raise( ArgumentError ) {World.new(".")}
    assert_raise( ArgumentError ) {World.new(".\n*")}
    assert_nothing_raised( ArgumentError ) {World.new(".*\n*.")}
  end

  def test_what_we_put_that_we_get
    assert_equal( World.new(".*\n*.").to_text, ".*\n*." )
    assert_equal( World.new(".*.\n*.*").to_text, ".*.\n*.*" )
    assert_equal( World.new(".*..\n*...\n....").to_text, ".*..\n*...\n...." )
  end

  def test_world_has_max_row_number
    assert_respond_to @world, 'max_row_number'
  end

  def test_world_has_max_col_number
    assert_respond_to @world, 'max_col_number'
  end

  def test_max_row_number_method_counts_right
    assert_equal( 2, World.new(".*..\n*...\n....").max_row_number )
    assert_equal( 1, World.new(".*..\n*...").max_row_number )
    assert_equal( 1, World.new(".*..\n*...\n").max_row_number )
  end

  def test_max_col_number_method_counts_right
    assert_equal( 3, World.new(".*..\n*...\n....").max_col_number )
    assert_equal( 2, World.new(".*.\n*..").max_col_number )
  end

  def test_we_can_check_cell_is_alive
    assert_respond_to @world, 'alive?'
  end

  def test_we_can_check_particular_cell_is_alive
    example_world = World.new(".*.\n*.*")
    # alive?(row, col) begins from 0,0
    assert example_world.alive?(0,1), "but it isn't alive 0,1"
    assert example_world.alive?(1,0), "but it isn't alive 1,0"
    assert example_world.alive?(1,2), "but it isn't alive 1,2"
    assert !example_world.alive?(0,0), "but it's alive 0,0"
    assert !example_world.alive?(0,2), "but it's alive 0,2"
    assert !example_world.alive?(1,1), "but it's alive 1,1"
  end

  def test_cell_above_the_world_matrix_is_not_alive
    assert !World.new("**\n**").alive?(-1,0)
  end

  def test_cell_left_of_the_world_matrix_is_not_alive
    assert !World.new("**\n**").alive?(0,-1)
  end

  def test_cell_right_of_the_world_matrix_is_not_alive
    @ex_world = World.new("**\n**")
    assert !@ex_world.alive?(0, @ex_world.max_col_number + 1)
  end

  def test_cell_under_the_world_matrix_is_not_alive
    @ex_world = World.new("**\n**")
    assert !@ex_world.alive?(@ex_world.max_row_number + 1, 0)
  end

  def test_we_can_check_cell_is_empty
    assert_respond_to @world, 'empty?'
  end

  def test_we_can_check_particular_cell_is_empty
    example_world = World.new(".*.\n*.*")
    # empty?(row, col) begins from 0,0
    assert example_world.empty?(0,0), "but it isn't empty 0,0"
    assert example_world.empty?(0,2), "but it isn't empty 0,2"
    assert example_world.empty?(1,1), "but it isn't empty 1,1"
    assert !example_world.empty?(0,1), "but it's empty 0,1"
    assert !example_world.empty?(1,0), "but it's empty 1,0"
    assert !example_world.empty?(1,2), "but it's empty 1,2"
  end

  def test_we_can_check_number_of_neighbours_of_cell
    assert_respond_to @world, 'number_of_neighbours'
  end

  def test_case_with_no_neighbours
    txtwrld = <<EOS
...
...
...
EOS
    example_world = World.new(txtwrld)
    assert_equal 0, example_world.number_of_neighbours(1,1)
  end

  def test_case_with_8_neighbours
    txtwrld = <<EOS
***
*.*
***
EOS
    example_world = World.new(txtwrld)
    assert_equal 8, example_world.number_of_neighbours(1,1)
  end

  def test_upper_left_edges_of_the_grid_is_empty
    txtwrld = <<EOS
*.*
.*.
EOS
    example_world = World.new(txtwrld)
    assert_equal 1, example_world.number_of_neighbours(0,0)
  end

  def test_bottom_right_edges_of_the_grid_is_empty
    txtwrld = <<EOS
*.*
.*.
EOS
    example_world = World.new(txtwrld)
    assert_equal 2, example_world.number_of_neighbours(1,2)
  end

  def test_just_check_complex_neighbours_count
    txtwrld = <<EOS
*.**.*
.*.*..
*..**.
EOS
    example_world = World.new(txtwrld)
    assert_equal 5, example_world.number_of_neighbours(1,2)
  end

#======= Life's logic =========

  def test_has_a_turn_method
    assert_respond_to @world, 'turn'
  end

  def test_Any_live_cell_with_fewer_than_two_live_neighbours_dies__underpopulation
    txtwrld = <<EOS
*.*
.*.
*..
EOS
    ex_world = World.new(txtwrld)
    assert ex_world.alive?(0,0), 'before turn 0,0'
    assert ex_world.alive?(0,2), 'before turn 0,2'
    assert ex_world.alive?(2,0), 'before turn 2,0'

    ex_world.turn
    assert !ex_world.alive?(0,0), 'after turn 0,0'
    assert !ex_world.alive?(0,2), 'after turn 0,2'
    assert !ex_world.alive?(2,0), 'after turn 2,0'
  end

#   def test_Any_live_cell_with_more_than_three_live_neighbours_dies__overcrowding
#     txtwrld = <<EOS
# *.*
# .*.
# *..
# EOS
#     ex_world = World.new(txtwrld)
#   end
end
