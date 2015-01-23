local Button = {}
Button.__index = Button

function Button.new(ui, x, y, w, h, settings)
    local self = {}

    self.ui = ui
    self.id = self.ui.addToElementsList(self)

    self.ix, self.iy = x, y
    self.x, self.y = x, y
    self.w, self.h = w, h
    local settings = settings or {}
    for k, v in pairs(settings) do self[k] = v end

    self.input = self.ui.Input()
    self.input:bind('return', 'key-enter')
    self.input:bind('mouse1', 'left-click')

    self.hot = false -- true if the mouse is over the object (inside its x, y, w, h rectangle)
    self.selected = false -- true if currently selected with TAB (for instance) so it can be pressed with a key
    self.down = false -- true if currently being pressed
    self.pressed = false -- true on the frame it has been pressed
    self.released = false -- true on the frame it has been released
    self.enter = false -- true on the frame the mouse has entered the frame
    self.exit = false -- true on the frame the mouse has exited the frame

    self.pressing = false
    self.previous_hot = false
    self.previous_selected = false

    return setmetatable(self, Button)
end

function Button:update(dt, parent)
    local x, y = love.mouse.getPosition()
    if parent then self.x, self.y = parent.x + self.ix, parent.y + self.iy end

    -- Check for hot
    if x >= self.x and x <= self.x + self.w and y >= self.y and y <= self.y + self.h then
        self.hot = true
    else self.hot = false end

    -- Check for enter 
    if self.hot and not self.previous_hot then
        self.enter = true
    else self.enter = false end

    -- Check for exit
    if not self.hot and self.previous_hot then
        self.exit = true
    else self.exit = false end

    -- Check for selected_enter
    if self.selected and not self.previous_selected then
        self.selected_enter = true
    else self.selected_enter = false end

    -- Check for selected_exit
    if not self.selected and self.previous_selected then
        self.selected_exit = true
    else self.selected_exit = false end

    -- Check for pressed/released/down on mouse hover
    if self.hot and self.input:pressed('left-click') then
        self.pressed = true
        self.pressing = true
    end
    if self.pressing and self.input:down('left-click') then
        self.down = true
    end
    if self.pressing and self.input:released('left-click') then
        self.released = true
        self.pressing = false
        self.down = false
    end

    -- Check for pressed/released/down on key press
    if self.selected and self.input:pressed('key-enter') then
        self.pressed = true
        self.pressing = true
    end
    if self.pressing and self.input:down('key-enter') then
        self.down = true
    end
    if self.pressing and self.input:released('key-enter') then
        self.released = true
        self.pressing = false
        self.down = false
    end

    if self.pressed and self.previous_pressed then self.pressed = false end
    if self.released and self.previous_released then self.released = false end

    -- Set previous frame state
    self.previous_hot = self.hot
    self.previous_pressed = self.pressed
    self.previous_released = self.released
    self.previous_selected = self.selected
end

function Button:draw(parent)
    love.graphics.setColor(32, 32, 32)
    love.graphics.rectangle('fill', self.x, self.y, self.w, self.h)

    if self.hot then
        love.graphics.setColor(48, 48, 48)
        love.graphics.rectangle('fill', self.x, self.y, self.w, self.h)
    end

    if self.selected then
        love.graphics.setColor(48, 48, 64)
        love.graphics.rectangle('fill', self.x, self.y, self.w, self.h)
    end

    if self.down then
        love.graphics.setColor(16, 16, 16)
        love.graphics.rectangle('fill', self.x, self.y, self.w, self.h)
    end
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
