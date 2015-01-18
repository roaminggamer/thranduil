# Thranduil

A UI module for LÖVE. Facilitates the creation of game specific UI through UI elements that have all 
their logic abstracted away (anything having to do with input, if this element has been pressed, is focused, etc), 
leaving the user (you) with the job of specifying only how those elements will be drawn. 

## Usage

The [module]() should be dropped on your project and required like so:

```lua
UI = require 'UI'
```

After that, register the UI module to most of LÖVE's callbacks, like this:

```lua
function love.update(dt)
  -- add your stuff here!!!
  -- UI's update call must come after everything
  UI.update(dt)
end

function love.keypressed(key)
  UI.keypressed(key)
end

function love.keyreleased(key)
  UI.keyreleased(key)
end

function love.mousepressed(x, y, button)
  UI.mousepressed(button)
end

function love.mousereleased(x, y, button)
  UI.mousereleased(button)
end

function love.gamepadpressed(joystick, button)
  UI.gamepadpressed(joystick, button)
end

function love.gamepadreleased(joystick, button)
  UI.gamepadreleased(joystick, button)
end

function love.gamepadaxis(joystick, axis, value)
  UI.gamepadaxis(joystick, axis, value)
end

function love.textinput(text)
  UI.textinput(text)
end
```

## Table of Contents

* [Creating an element](#Creating an element)
* [Elements](#Elements)
  * [Board](#Board)

## Creating an element

This creates a button object at position (10, 10) with width/height (90, 90):

```lua
button = UI.Button(10, 10, 90, 90)
```

This object can then be updated via `button:update(dt)` and it will automatically have its attributes changed as the user hovers, selects or presses it. However, calling `button:draw()` won't do anything because by default all UI elements don't have a draw function defined. To do that:

```lua
button.draw = function(button)
  love.graphics.setColor(64, 64, 64)
  love.graphics.rectangle('fill', button.x, button.y, button.w, button.h)
  if button.down then
    love.graphics.setColor(32, 32, 32)
    love.graphics.rectangle('fill', button.x, button.y, button.w, button.h)
  end
  love.graphics.setColor(255, 255, 255)
end
```

Simply define the button's draw function and use its attributes to change how the button looks. In this example I draw the button normally as a rectangle with the color (64, 64, 64). Then, on top of that, if the button is down (pressed and being held) I draw a rectangle of a slightly darker color (32, 32, 32), to give visual feedback that the button is changed somehow.

In any case, for all UI elements created with this module you'll have to do this and specify their draw functions. A big problem with UI modules for games is that they need to have really high customizability, because games can look very different from each other and so can their UIs. So a simple way to do this is to abstract away what can be abstracted away (the logic behind each UI element), and to just provide the user with all the information he needs to then draw those elements. 

The rest of this page will focus on describing each UI element and its attributes.

## Elements

### Board

An element that can contain other elements.


