class World

  ALIVE = '*'
  EMPTY = DEAD = '.'

  attr_reader :max_row_number, :max_col_number

  class << self
    def create_random(rows, columns)
      #
    end
  end

  def initialize(text_world = "..\n..")
    parse(text_world)
  end

  def to_s
    "World #{max_row_number+1}x#{max_col_number+1}"
  end

  def to_text
    res = ''
    @world_matrix.each do |line|
      res += line * '' # array to string of concatenated chars ['.','*'] => ".*"
      res += "\n"
    end
    res.chop # delete last \n (i.e. empty raw)
  end

  def alive?(row, col)
    return false if row < 0 || col < 0 || col > @max_col_number || row > @max_row_number
    case @world_matrix[row][col]
    when ALIVE
      return true
    when EMPTY
      return false
    else
      raise ArgumentError.new('inner world_matrix has wrong data')
    end
    #@world_matrix[row][col] == ALIVE
  end

  def empty?(row, col)
    !alive?(row, col)
  end

  alias_method :dead?, :empty?

  def number_of_neighbours(row, col)
    res = 0
    res +=1 if alive?(row-1, col-1)
    res +=1 if alive?(row-1, col)
    res +=1 if alive?(row-1, col+1)
    res +=1 if alive?(row,   col+1)
    res +=1 if alive?(row+1, col+1)
    res +=1 if alive?(row+1, col)
    res +=1 if alive?(row+1, col-1)
    res +=1 if alive?(row,   col-1)
    res
  end

  def turn
    new_world = []

    @world_matrix.each_index do |row_num|

      new_world[row_num] = []

      @world_matrix[row_num].each_index do |col_num|
        new_world[row_num][col_num] = next_cell_state_by_life_logic(row_num, col_num)
      end

    end

    @world_matrix = new_world
    true #don't discover inside world
  end

private
  def parse(text_world) # do refactoring with index
    raise ArgumentError.new('Only . * \n allowed') if text_world =~ /[^\.\*\n]/
    raise ArgumentError.new('Number of lines < 2') unless text_world.lines.count > 1

    width = text_world.lines.first.delete("\n").size
    raise ArgumentError.new('Number of columns < 2') if width < 2
    @max_col_number = width - 1
    @max_row_number = text_world.lines.count - 1
    @world_matrix = []

    text_world.lines.each_with_index do |line, coord_y|
      line.delete!("\n")
      raise ArgumentError.new('Not rectangle') if line.size != width # not rectangle
      @world_matrix[coord_y] = line.split(//) # string to array of chars
    end
  end

  def next_cell_state_by_life_logic(row, col)
    # Any live cell with fewer than two live neighbours dies, as if caused by underpopulation.
    return DEAD if number_of_neighbours(row, col) < 2

    # Any live cell with more than three live neighbours dies, as if by overcrowding.
    return DEAD if number_of_neighbours(row, col) > 3

    # Any live cell with two or three live neighbours lives on to the next generation.
    return ALIVE if alive?(row, col) && ( [2,3].member? number_of_neighbours(row, col) )

    # Any dead cell with exactly three live neighbours becomes a live cell.
    return ALIVE if dead?(row, col) && (number_of_neighbours(row, col) == 3)

    # other: without changes
    return alive?(row, col) ? ALIVE : EMPTY
  end

end