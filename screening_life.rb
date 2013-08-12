require "./world"

world = World.create_random(30,100)

while true
  system "clear"
  puts world.to_text
  world.turn
  sleep 0.2
end