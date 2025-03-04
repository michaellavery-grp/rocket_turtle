  # --- Turtle Neck and Head ---
  neck_width = 8
  neck_height = 12
  neck_x = cx - neck_width / 2.0
  neck_y = shell_y - neck_height  # position neck directly above shell
  $turtle_decorations << Rectangle.new(
    x: neck_x,
    y: neck_y,
    width: neck_width,
    height: neck_height,
    color: 'green'
  )

  head_radius = 6
  head_x = cx
  head_y = neck_y - head_radius  # head sits above the neck
  $turtle_decorations << Circle.new(
    x: head_x,
    y: head_y,
    radius: head_radius,
    color: 'green'
  )



# Update neck_head position
update do
    neck_x = cx - neck_width / 2.0
    neck_y = shell_y - neck_height  # position neck directly above shell
    head_x = cx
    head_y = neck_y - head_radius  # head sits above the neck
  
    # Adjust rotation
    case direction
    when :up
        neck_x = cx - neck_width / 2.0
        neck_y = shell_y - neck_height  # position neck directly above shell
        head_x = cx
        head_y = neck_y - head_radius  # head sits above the neck
    when :down
        neck_x = cx - neck_width / 2.0
        neck_y = shell_y + shell_size neck_height  # position neck directly below shell
        head_x = cx
        head_y = neck_y + shell_size + head_radius  # head sits below the neck
    when :left
        neck_x = turtle_center_x - neck_length
        neck_y = shell_y + shell_size neck_height  # position neck directly below shell
        head_x = cx
        head_y = neck_y + shell_size + head_radius  # head sits below the neck
      nose.x1 = turtle.x - 10
      nose.y1 = turtle.y + TURTLE_SIZE / 2
      nose.x2 = turtle.x
      nose.y2 = turtle.y
      nose.x3 = turtle.x
      nose.y3 = turtle.y + TURTLE_SIZE
    when :right
      nose.x1 = turtle.x + TURTLE_SIZE + 10
      nose.y1 = turtle.y + TURTLE_SIZE / 2
      nose.x2 = turtle.x + TURTLE_SIZE
      nose.y2 = turtle.y
      nose.x3 = turtle.x + TURTLE_SIZE
      nose.y3 = turtle.y + TURTLE_SIZE
    end
  end    
    
    
# Update nose position
nose.x1 = turtle.x + TURTLE_SIZE / 2
nose.y1 = turtle.y - 10
nose.x2 = turtle.x
nose.y2 = turtle.y
nose.x3 = turtle.x + TURTLE_SIZE
nose.y3 = turtle.y

# Adjust rotation
case direction
when :up
  nose.x1 = turtle.x + TURTLE_SIZE / 2
  nose.y1 = turtle.y - 10
  nose.x2 = turtle.x
  nose.y2 = turtle.y
  nose.x3 = turtle.x + TURTLE_SIZE
  nose.y3 = turtle.y
when :down
  nose.x1 = turtle.x + TURTLE_SIZE / 2
  nose.y1 = turtle.y + TURTLE_SIZE + 10
  nose.x2 = turtle.x
  nose.y2 = turtle.y + TURTLE_SIZE
  nose.x3 = turtle.x + TURTLE_SIZE
  nose.y3 = turtle.y + TURTLE_SIZE
when :left
  nose.x1 = turtle.x - 10
  nose.y1 = turtle.y + TURTLE_SIZE / 2
  nose.x2 = turtle.x
  nose.y2 = turtle.y
  nose.x3 = turtle.x
  nose.y3 = turtle.y + TURTLE_SIZE
when :right
  nose.x1 = turtle.x + TURTLE_SIZE + 10
  nose.y1 = turtle.y + TURTLE_SIZE / 2
  nose.x2 = turtle.x + TURTLE_SIZE
  nose.y2 = turtle.y
  nose.x3 = turtle.x + TURTLE_SIZE
  nose.y3 = turtle.y + TURTLE_SIZE
end
end