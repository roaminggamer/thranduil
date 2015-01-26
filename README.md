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

#### Base attributes

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
| selected_enter | true on the frame the button enters selection |
| selected_exit | true on the frame the button exists selection |

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
  if button.selected_enter then print('button entered selection!') end
  if button.selected_exit then print('button exited selection!') end
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
| left-click | mouse1 | left mouse click |
| key-enter | return | when selected, the key pressed to press the button |

```lua
-- makes the button press with the keyboard be activated through space instead of enter
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

#### Basic button drawing

### Frame

<p align="center">
  <img src="https://github.com/adonaac/thranduil/blob/master/images/frame.png?raw=true" alt="button"/>
</p>

A frame is a container/panel/window that can contain other UI elements. It can be resized, dragged, closed, have elements added to it and those elements can be selected sequentially with a key (TAB for instance).

#### Base attributes

| Attribute | Description |
| :-------- | :---------- |
| x, y | the frame's top-left position |
| w, h | the frame's width and height |
| hot | true if the mouse is over this frame (inside its x, y, w, h rectangle) |
| selected | true if the frame is currently selected (if its being interacted with) |
| down | true when the frame is being held down after being pressed |
| enter | true on the frame the mouse enters this button's area |
| exit | true on the frame the mouse exits this button's area |
| selected_enter | true on the frame the button enters selection |
| selected_exit | true on the frame the button exists selection |
| elements | list of elements this frame holds |
| currently_focused_element | number of the element that is currently selected |

#### Close attributes

* If the `closeable` attribute is not set, then the close button logic for this frame won't happen. 
* If `closed` is set to true then the frame won't update nor be drawn. 
* The close button's theme is inherited from the frame by default, but can be changed via `frame.close_button.theme`.
* Default values are set if the attribute is omitted on the settings table on this frame's creation.

| Attribute | Description | Default Value |
| :-------- | :---------- | :------------ |
| closeable | if this frame can be closed or not | false |
| closed | if the frame is closed or not | false |
| closing | if the close button is being held down | |
| close_margin | top-right margin for close button | 5 |
| close_button_width | width of the close button | 10 |
| close_button_height | height of the close button | 10 |
| close_button | a reference to the close button | |

```lua
function init()
  frame = UI.Frame(0, 0, 100, 100, {closeable = true, close_margin = 10, 
                                    close_button_width = 10, close_button_height = 10})
end

function update(dt)
  frame:update(dt)
  if frame.close_button.pressed then print('close button pressed!') end
  if frame.closed then print('the frame is closed!') end
  if not frame.closed then print('the frame is not closed!') end
  frame.closed = not frame.closed
end
```

#### Drag attributes

* If the `draggable` attribute is not set, then the dragging logic for this frame won't happen. 
* Default values are set if the attribute is omitted on the settings table on this frame's creation.

| Attribute | Description | Default Value |
| :-------- | :---------- | :------------ |
| draggable | if this frame can be dragged or not | false |
| dragging | if this frame is being dragged | |
| drag_margin | top margin for drag bar | self.h/5 |
| drag_hot | true if the mouse is over this frame's drag area (inside its x, y, w, h rectangle) | |
| drag_enter | true on the frame the mouse enters this frame's drag area | |
| drag_exit | true on the frame the mouse exits this frame's exit area | |

```lua
function init()
  frame = UI.Frame(0, 0, 100, 100, {draggable = true, drag_margin = 20})
end

function update(dt)
  frame:update(dt)
  if frame.dragging then print('frame being dragged!') end
end
```

#### Resize attributes

* If the `resizable` attribute is not set, then the resizing logic for this frame won't happen. 
* Default values are set if the attribute is omitted on the settings table on this frame's creation.

| Attribute | Description | Default Value |
| :-------- | :---------- | :------------ |
| resizable | if this frame can be resized or not | false |
| resizing | if this frame is being resized | |
| resize_margin | top-left-bottom-right margin for resizing | 6 |
| resize_hot | true if the mouse is over this frame's resize area | |
| resize_enter | true on the frame the mouse enters this frame's resize area | |
| resize_exit | true on the frame the mouse exits this frame's resize area | |
| min_width | minimum frame width | 20 |
| min_height | minimum frame height | self.h/5 |

```lua
function init()
  frame = UI.Frame(0, 0, 100, 100, {resizable = true, resize_margin = 10, 
                                    min_width = 100, min_height = 100})
end

function update(dt)
  frame:update(dt)
  if frame.resizing then print('frame being resized!') end
end
```

#### Methods

---

**`new(x, y, w, h, settings):`** creates a new frame. The settings table is optional and default values will be used in case some attributes are omitted.

```lua
button = UI.Frame(0, 0, 100, 100, {draggable = true, resizable = true})
```

---

**`addElement(element):`** adds an element to the frame. Elements added must be specified with their positions in relation to the frame's top-left position. An `element_id` number is returned which can then be used with the `getElement` function to get a reference to an element inside a frame.

``` lua
-- the button is draw at position (5, 5) from the frame's top-left corner
local button_id = frame:addElement(UI.Button(5, 5, 100, 100))
```

---

**`bind(key, action):`** binds a key to a button action. Current actions are:

| Action | Default Key | Description |
| :----- | :---------- | :---------- |
| left-click | mouse1 | left mouse click |
| close | escape | if `closeable` is true, then this action closes the frame |
| focus-next | tab | selects the next element (sets its `.selected` attribute to true) |
| previous-modifier | lshift | modifier to select the previous element with `previous-modifier + focus-next` |

```lua
-- makes it so that pressing space selects the next element and lshift+space selects the previous
frame:bind(' ', 'focus-next')
```

---

**`destroy():`** destroys the frame and all the elements inside it as well. Nilling a UI element won't remove it from memory because the UI module also keeps a reference of each object created with it.

```lua
-- won't remove the button object from memory
frame = nil

-- removes the button object from memory
frame:destroy()
frame = nil
```

---

**`getElement(element_id):`** gets a reference to an element from the frame.

```lua
local button = frame:getElement(button_id)
```

---

### Textinput

A textinput is an UI element you can write to. It's a single line of text (not to be confused with a [Textarea](#textarea)) and supports scrolling, copying, deleting, pasting and selecting of text.
