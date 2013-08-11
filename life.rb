require "./world"

class LifeWorld
  attr_reader :state

  def initialize
    @state ||= World.new
  end

  def turn
    @state = World.new
  end

end