# Thranduil

An UI module for LÖVE. Facilitates the creation of game specific UI through UI elements that have all 
their logic abstracted away (anything having to do with input and the element's state), leaving the user (you) with the job of specifying only how those elements will be drawn (or if you want you can just use a [theme](#themes)).

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

## Introduction

For this example we'll create a button object at position `(10, 10)` with width/height `(90, 90)`:

```lua
button = UI.Button(10, 10, 90, 90)
```

This object can then be updated via `button:update(dt)` and it will automatically have its attributes changed as the user hovers, selects or presses it. Drawing however is handled by you (unless you use a [theme](#themes)), which means that the button's draw function has to be defined. 

This function will use the object's attributes to change how it looks under different states. The UI module is designed in this way so that you can have absolute control over how each UI element looks, which means that integration with a game (which usually needs random UI elements in the most unexpected places) is as straightforward as working with any other game object.

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

## Elements

### Button

<p align="center">
  <img src="https://github.com/adonaac/thranduil/blob/master/images/button.png?raw=true" alt="button"/>
</p>

A button is a rectangle that can be pressed.

#### Attributes

| Attribute | Description |
| :-------- | :---------- |
| x, y | the button's top-left position |
| w, h | the button's width and height |
| hot | true if the mouse is over this button (inside its x, y, w, h rectangle) |
| selected | true if the button is currently selected (with a TAB key for instance when inside a [Frame](#frame)) |
| pressed | true on the frame the button was pressed |
| down | true when the button is being held down after being pressed |
| released | true on the frame the button was released |
| enter | true on the frame the mouse enters this button's area |
| exit | true on the frame the mouse exits this button's area |

```lua
function init()
  button = UI.Button(0, 0, 100, 100)
end

function update(dt)
  button:update(dt)
  if button.pressed then print('button was pressed!') end
  if button.released then print('button was released!') end
  if button.down then print('button is down!') end
  if button.hot then print('button is hot!') end
  if button.enter then print('button entered hot!') end
  if button.exit then print('button exit hot!') end
  if button.selected then print('button is selected!') end
end
```

#### Methods

---

**`new(x, y, w, h, settings):`** creates a new button. The settings table is optional, see [Extensions](#extensions).

```lua
button = UI.Button(0, 0, 100, 100)
```

---

**`bind(key, action):`** binds a key to a button action. Current actions are:

| Action | Default Key | Description |
| :----- | :---------- | :---------- |
| left-click | mouse1 | Mouse click |
| key-enter | return | When selected, the key pressed to press the button |

```lua
-- Makes the button press with the keyboard be activated through space instead of enter
button:bind(' ', 'key-enter')
```

---

**`destroy():`** destroys the element. Nilling a UI element won't remove it from memory because the UI module also keeps a reference of each object created with it.

```lua
-- won't remove the button object from memory
button = nil

-- removes the button object from memory
button:destroy()
button = nil
```

---

### Frame

### Textinput
