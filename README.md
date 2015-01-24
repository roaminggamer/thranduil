# Thranduil

A UI module for LÖVE. Facilitates the creation of game specific UI through UI elements that have all 
their logic abstracted away (anything having to do with input, if this element has been pressed, is focused, etc), 
leaving the user (you) with the job of specifying only how those elements will be drawn.

## Usage

Require the [module]():

```lua
UI = require 'UI'
```

And register it to most of LÖVE's callbacks:

```lua
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

## Creating an element

For this example we'll create a button object at position `(10, 10)` with width/height `(90, 90)`:

```lua
button = UI.Button(10, 10, 90, 90)
```

This object can then be updated via `button:update(dt)` and it will automatically have its attributes changed as the user hovers, selects or presses it. Calling `button:draw()` won't do anything because by default all UI elements don't have a draw function defined.

You are then tasked with defining the button's draw function and using its attributes to change how the button looks under different states. This is so that you can have absolute control over how each UI element looks, which means that integration with a game (which usually needs random UI elements in the most unexpected places) is as easy as making any other game object work. However, if you need to just get something out quickly, a few [themes](#themes) have been created.

```lua
button.draw = function(self)
  love.graphics.setColor(64, 64, 64)
  love.graphics.rectangle('fill', self.x, self.y, self.w, self.h)
  if self.down then
    love.graphics.setColor(32, 32, 32)
    love.graphics.rectangle('fill', self.x, self.y, self.w, self.h)
  end
  love.graphics.setColor(255, 255, 255)
end
```
