local ui_path = tostring(...):sub(1, -3)
local UI = {}
require(ui_path .. 'utf8')

UI.update = function(dt) 
    for _, t in ipairs(UI.elements) do
        t.input:update(dt)
    end
end
UI.keypressed = function(key) 
    for _, t in ipairs(UI.elements) do
        t.input:keypressed(key)
    end
end
UI.keyreleased = function(key) 
    for _, t in ipairs(UI.elements) do
        t.input:keyreleased(key)
    end
end
UI.mousepressed = function(button) 
    for _, t in ipairs(UI.elements) do
        t.input:mousepressed(button)
    end
end
UI.mousereleased = function(button) 
    for _, t in ipairs(UI.elements) do
        t.input:mousereleased(button)
    end
end
UI.gamepadpressed = function(joystick, button) 
    for _, t in ipairs(UI.elements) do
        t.input:gamepadpressed(joystick, button)
    end
end
UI.gamepadreleased = function(joystick, button) 
    for _, t in ipairs(UI.elements) do
        t.input:gamepadreleased(joystick, button)
    end
end
UI.gamepadaxis = function(joystick, axis, value)
    for _, t in ipairs(UI.elements) do
        t.input:gamepadaxis(joystick, axis, value)
    end
end 
UI.textinput = function(text)
    for _, t in ipairs(UI.elements) do
        if t.textinput then
            t:textinput(text)
        end
    end
end

UI.elements = {}
UI.addToElementsList = function(element)
    table.insert(UI.elements, element)
    return #UI.elements
end
UI.removeFromElementsList = function(id)
    table.remove(UI.elements, id)
end

UI.Input = require(ui_path .. 'Input/Input')

local Button = require(ui_path .. 'Button')
UI.Button = function(...) return Button(UI, ...) end
local Frame = require(ui_path .. 'Frame')
UI.Frame = function(...) return Frame(UI, ...) end
local Textinput = require(ui_path .. 'Textinput')
UI.Textinput = function(...) return Textinput(UI, ...) end

return UI
