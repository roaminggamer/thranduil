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

## Table of Contents

* [Introduction](#introduction)
* [Elements](#elements)
  * [Button](#button)
    * [Base attributes](#base-attributes-1)
    * [Methods](#methods-1)
    * [Basic button drawing](#basic-button-drawing)
  * [Frame](#frame)
    * [Base attributes](#base-attributes-2)
    * [Close attributes](#close-attributes)
    * [Drag attributes](#drag-attributes)
    * [Resize attributes](#resize-attributes)
    * [Methods](#methods-2)
    * [Basic frame drawing](#basic-frame-drawing)
  * [Textinput](#textinput)
    * [Base attributes](#base-attributes-3)
    * [Text attributes](text-attributes)
    * [Methods](#methods-3)
    * [Basic textinput drawing](#basic-textinput-drawing)
* [Extensions](#extensions)
* [Themes](#themes)

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

```lua
function init()
  frame = UI.Frame(0, 0, 100, 100)
end

function update(dt)
  frame:update(dt)
  if frame.enter then print('Focused element #: ' .. frame.currently_focused_element) end
  if frame.exit then print('# of elements: ' .. #frame.elements) end
  if frame.selected then print('frame is being interacted with!') end
end
```


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

<p align="center">
  <img src="https://github.com/adonaac/thranduil/blob/master/images/textinput.png?raw=true" alt="button"/>
</p>

A textinput is an UI element you can write to. It's a single line of text (not to be confused with a [Textarea](#textarea)) and supports scrolling, copying, deleting, pasting and selecting of text.

#### Base attributes

| Attribute | Description |
| :-------- | :---------- |
| x, y | the textinput's top-left position |
| w, h | the textinput's width and height |
| hot | true if the mouse is over this textinput (inside its x, y, w, h rectangle) |
| selected | true if the textinput is currently selected (if its being interacted with or selected with TAB) |
| pressed | true on the frame the textinput was pressed |
| down | true when the textinput is being held down after being pressed |
| released | true on the frame the textinput was released |
| enter | true on the frame the mouse enters this button's area |
| exit | true on the frame the mouse exits this button's area |
| selected_enter | true on the frame the button enters selection |
| selected_exit | true on the frame the button exists selection |

```lua
function init()
  textinput = UI.Textinput(0, 0, 100, 100)
end

function update(dt)
  textinput:update(dt)
  if frame.selected_enter then print('textinput selected!') end
  if frame.selected_exit then print('textinput unselected!') end
end
```

#### Text attributes

* Default values are set if the attribute is omitted on the settings table on this textinput's creation.

| Attribute | Description | Default Value |
| :-------- | :---------- | :------------ |
| text | the text as a string | |
| text_x, text_y | text's top-left position | |
| text_margin | top-left margin for the text | 5 |
| text_max_length | maximum number of characters this textinput holds | |
| selection_position.x, .y | selection's top-left position | |
| selection_size.w, .h | selection's width and height | |
| index | textinput's cursor index | |
| select_index | if text is being selected, textinput's second cursor index, otherwise nil| |
| string | the text string but represented as a table of characters | |
| font | the font to be used for this textinput object | currently set font |

```lua
function init()
  textinput = UI.Textinput(0, 0, 100, 100, {text_margin = 10, text_max_length = 10})
end

function update(dt)
  textinput:update(dt)
  print('text x, y: ', textinput.text_x, textinput.text_y)
  print('cursor index: ', textinput.index)
  print('cursor character: ', textinput.string[index])
  if textinput.select_index then
    print('text being selected: ', textinput.text:sub(index, select_index))
  end
  if textinput.selection_position then
    print('selection rectangle: ', textinput.selection_position.x, textinput.selection_position.y,
                                   textinput.selection_size.w, textinput.selection_size.h)
  end
end
```

#### Methods

---

**`new(x, y, w, h, settings):`** creates a new textinput. The settings table is optional and default values will be used in case some attributes are omitted.

```lua
textinput = UI.Textinput(0, 0, 100, 100, {font = love.graphics.newFont('.ttf', 24)})
```

---

**`bind(key, action):`** binds a key to a button action. Current actions are:

| Action | Default Key | Description |
| :----- | :---------- | :---------- |
| left-click | mouse1 | mouse's left click |
| move-left | left | moves the cursor to the left once |
| move-right | right | moves the cursor to the right once |
| first | up | moves the cursor to the start of the text |
| last | down | moves the cursor to the end of the text |
| lshift | lshift | shift modifier |
| backspace | backspace | deletes before the cursor |
| delete | delete | deletes after the cursor |
| lctrl | lctrl | ctrl modifier |
| cut | x | cuts the selected text with `lctrl + cut` |
| copy | c | copies the selected text with `lctrl + copy` |
| paste | p | pastes the copied or cut text with `lctrl + paste` |
| all | a | selects all text with `lctrl + all` |

```lua
-- makes it so that lctrl + m selects all text instead of lctrl + a
textinput:bind('m', 'all')
```

---

**`destroy():`** destroys the textinput. Nilling a UI element won't remove it from memory because the UI module also keeps a reference of each object created with it.

```lua
-- won't remove the textinput object from memory
textinput = nil

-- removes the textinput object from memory
textinput:destroy()
textinput = nil
```

---

**`setText(text):`** sets the textinput's text.

```lua
textinput:setText('text to be set')
```

---

## Extensions

All objects can be extended for additional functionality in a number of ways. The simpler one is by adding attributes to its settings table. Say you want to make a button have text:

```lua
function init()
  button = UI.Button(0, 0, 100, 100, {text = 'Button'})
  button.draw = function(self)
    if button.text then
      love.graphics.print(button.text, self.x, self.y)
    end
  end
end
```

In this simple example the `text` attribute is added to the settings table, and since internally all attributes added to the settings table are injected into the object, then on its draw function you can check that same attribute and do whatever you want with it.

The other way of extending objects is through the creation of extension files. Those files should be structured like this:

```lua
-- suppose this is the file CoolExtension.lua
local Extension = {}

Extension.Button = {}
Extension.Button.new = function(self) end
Extension.Button.update = function(self, dt, parent) end
Extension.Button.draw = function(self) end

-- repeat for all other UI elements that you want to extend

return Extension
```

And then to add an extension to an object:

```lua
SuperCoolExtension = require 'CoolExtension'

function init()
  button = UI.Button(0, 0, 100, 100, {extensions = {SuperCoolExtension}})
end
```

And so the functions defined on the `CoolExtension.lua` file will be injected into that button's constructor, update and draw functions. Multiple extensions can be applied to the same object and they'll be processed sequentially, so care must be taken in case one extensions adds attributes that conflict with another.

## Themes

Themes are just extensions that mostly care about the `draw` function (however they're not limited to that, for instance, if you want to tween colors for transitions on your UI elements you'll probably need to add state to the object's constructor and update it on the update function). To add a theme, assuming it's structured like extensions are supposed to be:

```lua
SuperCoolTheme = require 'CoolTheme'

function init()
  button = UI.Button(0, 0, 100, 100, {theme = SuperCoolTheme})
  -- this also works:
  -- button = UI.Button(0, 0, 100, 100, {extensions = {SuperCoolTheme}})
end
```
