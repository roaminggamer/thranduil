UI = require 'ui/UI'
FlatUI = require 'ui/themes/FlatUI'

function love.load()
    love.window.setMode(800, 600, {display = 1})
    frame = UI.Frame(0, 0, 100, 100, {draggable = true, resizable = true})
    frame:addElement(UI.Button(5, 25, 70, 30))
    frame:addElement(UI.Button(5, 60, 70, 30))

    textinput = UI.Textinput(100, 100, 500, 46, {font = love.graphics.newFont('FreePixel.ttf', 32)})
end

function love.update(dt)
    frame:update(dt)
    textinput:update(dt)

    UI.update(dt)
end

function love.draw()
    frame:draw()
    textinput:draw()
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
