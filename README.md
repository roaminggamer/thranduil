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
| x, y | The button's top-left position |
| w, h | The button's width and height |
| hot | True if the mouse is over this button (inside its x, y, w, h rectangle) |
| selected | True if the button is currently selected (with a TAB key for instance when inside a [Frame](#frame) |
| pressed | True on the frame the button was pressed |
| down | True when the button is being held down after being pressed |
| released | True on the frame the button was released |
| enter | True on the frame the mouse enters this button's area |
| exit | True on the frame the mouse exits this button's area |

#### Methods

| Name | Arguments | Description |
| :--- | :-------- | :---------- |
| bind | key[string], action[string] | binds a key to a button [action](#button-actions) |
| destroy | | destroys the element, nilling UI elements won't remove them from memory |

#### Button Actions

Actions are rebindable in case a button needs to be accessed through other keys. The current actions are:

| Action | Default Key | Description |
| :----- | :---------- | :---------- |
| left-click | mouse1 | Mouse click |
| key-enter | return | When selected, the key pressed to press the button |

### Frame

### Textinput
