UI = require 'ui/UI'

function love.load()
    love.window.setMode(800, 600, {display = 1})
    love.graphics.setBackgroundColor(255, 255, 255)

    button = UI.Button(50, 50, 100, 50)
    button.draw = function(self)
        love.graphics.setColor(64, 64, 64)
        if self.hot then love.graphics.setColor(96, 96, 96) end
        if self.down then love.graphics.setColor(32, 32, 32) end
        love.graphics.rectangle('fill', self.x, self.y, self.w, self.h)
    end
end

function love.update(dt)
    button:update(dt)
end

function love.draw()
    button:draw()
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
