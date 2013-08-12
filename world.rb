class World

  ALIVE = '*'
  EMPTY = DEAD = '.'

  attr_reader :max_row_number, :max_col_number

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
    @world_matrix[row][col] == ALIVE
  end

  def empty?(row, col)
    !alive?(row, col)
  end

  # def empty?(row, col) # maybe refactor to return !alive?
  #   return true if row < 0 || col < 0 || col > @max_col_number || row > @max_row_number
  #   @world_matrix[row][col] == EMPTY
  # end

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

      row.each_index do |col_num|
        new_world[row_num][col_num] = ( number_of_neighbours(row_num, col_num) < 2 ? DEAD : ALIVE )
      end

    end

    @world_matrix = new_world
    true #don't discover inside world
  end

private
  def parse(text_world)
    raise ArgumentError.new('Only . * \n allowed') if text_world =~ /[^\.\*\n]/
    raise ArgumentError.new('Number of lines < 2') unless text_world.lines.count > 1

    width = text_world.lines.first.delete("\n").size
    raise ArgumentError.new('Number of columns < 2') if width < 2
    @max_col_number = width - 1

    @world_matrix = []
    coord_y = 0

    text_world.lines.each do |line|
      line.delete!("\n")
      raise ArgumentError.new('Not rectangle') if line.size != width # not rectangle
      @world_matrix[coord_y] = line.split(//) # string to array of chars
      coord_y += 1
    end
    @max_row_number = coord_y - 1
  end

end