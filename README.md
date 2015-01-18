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

* [Creating an element](#creating-an-element)
* [Binding actions](#binding-actions)
* [Elements](#elements)
  * [Board](#board)

## Creating an element

For this example we'll a button object at position (10, 10) with width/height (90, 90):

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

Define the button's draw function and use its attributes to change how the button looks. For all UI elements created with this module you'll have to specify their draw functions (or use an already made [theme](#themes) if you need something quick). A big problem with UI modules for games is that they need to have really high customizability, because games can look very different from each other and so can their UIs. So a simple way to do this is to abstract away what can be abstracted away (the logic behind each UI element), and to just provide the user with all the information he needs to then draw those elements. 

## Elements

All elements currently implemented are described here, along with their creation methods and attributes.

### Board

An element that can contain other elements.

#### Methods

---

**new(x, y, w, h, settings):** creation method for a board. `x, y, w, h` are obligatory, while the settings table contains optional attributes such as `.draggable`or `.resizable`.

---

**addElement(element):** adds an element to the board. The added object will be drawn with its position relative to the board, meaning that its `.x, .y` attributes must not be global, but in relation to how far away they are from the board's `.x, .y` (top-left corner) attributes. For instance:

```lua
board = UI.Board(100, 100, 50, 50)
board:addElement(UI.Button(5, 5, 40, 40))
```

In this example the button will be drawn at position `(105, 105)`.

---

**bind(key, action):** binds a key to an action. Available actions are:

* `'left-click'`:
* `'focus-next'`: jumps to the next element in the board to focus on (set that element's `.selected` attribute to true), defaults to the `TAB` key
* `'focus-previous'`: jumps to the previous element in the board to focus on (set that element's `.selected` attribute to true), defaults to the `Q` key

---

#### Attributes

---

**x, y:** top-left corner position

---

**w, h:** width and height

---

**draggable (boolean):** if the board is draggable or not. Draggable boards will be dragged if the user clicks and holds the button bound to the action `'left-click'` while hovering a part of the board that isn't covered by another element.

---

**elements (table):** the table holding all added elements

---

**resizable (boolean):** if the board is resizable or not. Resizable boards will be resized if the user clicks and holds the button bound to the action `'left-click'` while hovering the board's resize margin.

---

**resize_margin_size:** the number of pixels from the outer border of the board where resizing can happen

---
