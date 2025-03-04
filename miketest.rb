#!/usr/bin/env ruby
require 'ruby2d'

# Window setup
set title: "Rocket Turtle", width: 800, height: 600
set background: 'black'

# Game variables and states
@game_state = :paused  # Possible states: :running, :paused, :game_over
@score = 0
@poop_hits = 0
@blink_timer = 0
@turtle_inside_blackhole = false

# Create game objects using shapes
# Turtle represented by a green square (50x50)
@turtle = Square.new(
  x: 400, y: 300,
  size: 50,
  color: 'green'
)

# Poop represented by a brown square (30x30)
@poop = Square.new(
  x: rand(800 - 30), y: rand(600 - 30),
  size: 30,
  color: 'brown'
)

# Blackhole represented by a purple square (60x60)
@blackhole = Square.new(
  x: rand(800 - 60), y: rand(600 - 60),
  size: 60,
  color: 'purple'
)

# Display text for game over state with blinking final score
def draw_game_over_screen
  @blink_timer += 1

  if (@blink_timer / 20) % 2 == 0
    Text.new("Final Score: #{@score}", x: 200, y: 300, size: 40, color: 'white')
  end

  Text.new("Gross!!!", x: 250, y: 200, size: 50, color: 'red')
  Text.new("Game OVER!", x: 230, y: 250, size: 60, color: 'red')
  Text.new("Hit SPACE to begin a new game", x: 180, y: 400, size: 30, color: 'yellow')
end

# Display text for paused state
def draw_paused_screen
  Text.new("Hit SPACE to begin", x: 220, y: 300, size: 40, color: 'white')
end

# Reset game to start fresh
def reset_game
  @score = 0
  @poop_hits = 0
  @turtle_inside_blackhole = false
  @game_state = :running
  @blink_timer = 0

  # Reset positions
  @turtle.x = 400
  @turtle.y = 300

  @poop.x = rand(800 - 30)
  @poop.y = rand(600 - 30)

  @blackhole.x = rand(800 - 60)
  @blackhole.y = rand(600 - 60)
end

# Transition to game over state
def end_game
  @game_state = :game_over
  @blink_timer = 0
end

# Handle turtle movement with arrow keys (only in running state)
on :key_held do |event|
  if @game_state == :running
    case event.key
    when 'left'
      @turtle.x -= 5 if @turtle.x > 0
    when 'right'
      @turtle.x += 5 if @turtle.x < (800 - @turtle.size)
    when 'up'
      @turtle.y -= 5 if @turtle.y > 0
    when 'down'
      @turtle.y += 5 if @turtle.y < (600 - @turtle.size)
    end
  end
end

# Main game loop for collision detection and state updates
update do
  if @game_state == :running
    # Check collision with poop (using AABB collision detection)
    if @turtle.x < @poop.x + @poop.size &&
       @turtle.x + @turtle.size > @poop.x &&
       @turtle.y < @poop.y + @poop.size &&
       @turtle.y + @turtle.size > @poop.y
      @score += 10
      @poop_hits += 1
      # Reposition poop randomly
      @poop.x = rand(800 - @poop.size)
      @poop.y = rand(600 - @poop.size)
    end

    # Check collision with blackhole
    if @turtle.x < @blackhole.x + @blackhole.size &&
       @turtle.x + @turtle.size > @blackhole.x &&
       @turtle.y < @blackhole.y + @blackhole.size &&
       @turtle.y + @turtle.size > @blackhole.y
      @turtle_inside_blackhole = true
      end_game
    end

    # End game if too many poop hits
    end_game if @poop_hits >= 3
  end

  # Render the appropriate screen based on the game state
  if @game_state == :game_over
    draw_game_over_screen
  elsif @game_state == :paused
    draw_paused_screen
  end
end

# Keyboard Controls
on :key_down do |event|
  if event.key == 'space'
    if @game_state == :paused || @game_state == :game_over
      reset_game  # Restart game logic
    end
  elsif event.key == 'escape'
    end_game  # Trigger game over instead of exiting
  end
end

show