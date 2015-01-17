local Button = {}
Button.__index = Button

function Button.new(ui, x, y, w, h, settings)
    local self = {}

    self.ui = ui
    self.id = self.ui.addToElementsList(self)

    self.x, self.y = x, y
    self.w, self.h = w, h
    local settings = settings or {}
    for k, v in pairs(settings) do self[k] = v end

    self.input = self.ui.Input()
    self.input:bind('return', 'key_enter')
    self.input:bind('mouse1', 'left_click')

    self.hot = false -- true if the mouse is over the object (inside its x, y, w, h rectangle)
    self.selected = true -- true if currently selected with TAB (for instance) so it can be pressed with a key
    self.down = false -- true if currently being pressed
    self.pressed = false -- true on the frame it has been pressed, false otherwise
    self.released = false -- true on the frame it has been released, false otherwise

    return setmetatable(self, Button)
end

function Button:update(dt)
    -- Check for hot
    local x, y = love.mouse.getPosition()
    if x >= self.x and x <= self.x + self.w and y >= self.y and y <= self.y + self.h then
        self.hot = true
    else self.hot = false end

    -- Check for pressed/released/down on mouse hover
    if self.hot then
        if self.input:pressed('left_click') then
            self.pressed = true
        end
        if self.input:released('left_click') then
            self.released = true
        end
        if self.input:down('left_click') then
            self.down = true
        end
    end

    -- Check for pressed/released/down on key press
    if self.selected then
        if self.input:pressed('key_enter') then
            self.pressed = true
        end
        if self.input:released('key_enter') then
            self.released = true
        end
        if self.input:down('key_enter') then
            self.down = true
        end
    end

    -- Undo previous frame's pressed/released/down
    if not self.input:pressed('left_click') and not self.input:pressed('key_enter') then
        self.pressed = false
    end
    if self.input:released('left_click') and self.down then
        self.released = true
    end
    if not self.input:released('left_click') and not self.input:released('key_enter') then
        self.released = false
    end
    if not self.input:down('left_click') and not self.input:down('key_enter') then
        self.down = false
    end
end

function Button:draw()

end

function Button:keypressed(key)
    self.input:keypressed(key)
end

function Button:keyreleased(key)
    self.input:keyreleased(key)
end

function Button:mousepressed(button)
    self.input:mousepressed(button)
end

function Button:mousereleased(button)
    self.input:mousereleased(button)
end

function Button:gamepadpressed(joystick, button)
    self.input:gamepadpressed(joystick, button)   
end

function Button:gamepadreleased(joystick, button)
    self.input:gamepadreleased(joystick, button)
end

function Button:gamepadaxis(joystick, axis, value)
    self.input:gamepadaxis(joystick, axis, value)
end

function Button:bind(key, action)
    self.input:bind(key, action)
end

function Button:destroy()
    self.ui.removeFromElementsList(self.id)
end

return setmetatable({new = new}, {__call = function(_, ...) return Button.new(...) end})
