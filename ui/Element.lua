local Element = {}
Element.__index = Element

function Element.new(ui, x, y, w, h, settings)
    local self = {}

    self.ui = ui
    self.id = self.ui.addToElementsList(self)

    self.x, self.y = x, y
    self.w, self.h = w, h
    local settings = settings or {}
    for k, v in pairs(settings) do self[k] = v end

    self.input = self.ui.Input()
    self.input:bind('tab', 'next_element')
    self.input:bind('[', 'previous_element')
    self.input:bind('mouse1', 'left_click')

    self.hot = false -- true if the mouse is over the object (inside its x, y, w, h rectangle)
    self.selected = true -- true if currently selected with TAB (for instance) so it can be pressed with a key
    self.down = false -- true if currently being pressed
    self.pressed = false -- true on the frame it has been pressed, false otherwise
    self.released = false -- true on the frame it has been released, false otherwise

    self.draggable = settings.draggable or false
    self.drag_hot = false
    self.drag_position = settings.drag_position or 'top'
    self.drag_size = settings.drag_size or 10

    -- Drag bar position, width, height
    local drag_positions = {}
    drag_positions.top = {x = self.x, y = self.y, w = self.w, h = self.drag_size}
    drag_positions.left = {x = self.x, y = self.y, w = self.drag_size, h = self.h}
    drag_positions.right = {x = self.x + self.w - self.drag_size, y = self.y, w = self.drag_size, h = self.h}
    drag_positions.bottom = {x = self.x, y = self.y + self.h - self.drag_size, w = self.w, h = self.drag_size}
    self.dx, self.dy = drag_positions[self.drag_position].x, drag_positions[self.drag_position].y
    self.dw, self.dh = drag_positions[self.drag_position].w, drag_positions[self.drag_position].h

    self.resizable = settings.resizable or false
    self.resize_hot = false
    self.resize_size = settings.resize_size or 10
    local resize_positions = {}

    self.elements = {}

    return setmetatable(self, Element)
end

function Element:update(dt)
    for _, element in ipairs(self.elements) do
        element:update(dt)
    end

    -- Check for hot
    local x, y = love.mouse.getPosition()
    if x >= self.x and x <= self.x + self.w and y >= self.y and y <= self.y + self.h then
        self.hot = true
    else self.hot = false end

    if self.draggable then
        -- Check for drag_hot
        if x >= self.dx and x <= self.dx + self.dw and y >= self.dy and y <= self.dy + self.dh then
            self.drag_hot = true
        else self.drag_hot = false end
    end

    if self.resizable then
        -- Check for resize_hot
        if (x >= self.x and x <= self.x + self.resize_size and y >= self.y and y <= self.y + self.h) or
           (x >= self.x and x <= self.x + self.w and y >= self.y and y <= self.y + self.resize_size) or
           (x >= self.x + self.w - self.resize_size and x <= self.x + self.w and y >= self.y and y <= self.y + self.h) or
           (x >= self.x and x <= self.x + self.w and y >= self.y + self.h - self.resize_size and y <= self.y + self.h) then
            self.resize_hot = true 
        else self.resize_hot = false end
    end
end

function Element:draw()
    for _, element in ipairs(self.elements) do
        element:draw()
    end

    love.graphics.setColor(64, 64, 64)
    love.graphics.rectangle('fill', self.x, self.y, self.w, self.h)
    if self.hot then
        love.graphics.setColor(200, 50, 50)
        love.graphics.rectangle('line', self.x, self.y, self.w, self.h)
        love.graphics.setColor(255, 255, 255)
    end
    if self.drag_hot then
        love.graphics.setColor(50, 200, 50)
        love.graphics.rectangle('line', self.x, self.y, self.w, self.h)
        love.graphics.setColor(255, 255, 255)
    end
    if self.resize_hot then
        love.graphics.setColor(50, 50, 200)
        love.graphics.rectangle('line', self.x, self.y, self.w, self.h)
        love.graphics.setColor(255, 255, 255)
    end
end

function Element:keypressed(key)
    self.input:keypressed(key)
end

function Element:keyreleased(key)
    self.input:keyreleased(key)
end

function Element:mousepressed(button)
    self.input:mousepressed(button)
end

function Element:mousereleased(button)
    self.input:mousereleased(button)
end

function Element:gamepadpressed(joystick, button)
    self.input:gamepadpressed(joystick, button)
end

function Element:gamepadreleased(joystick, button)
    self.input:gamepadreleased(joystick, button)
end

function Element:gamepadaxis(joystick, axis, value)
    self.input:gamepadaxis(joystick, axis, value)
end

function Element:add(element)
    table.insert(self.elements, element)
end

function Element:bind(key, action)
    self.input:bind(key, action)
end

function Element:destroy()
    self.ui.removeFromElementsList(self.id)
end

return setmetatable({new = new}, {__call = function(_, ...) return Element.new(...) end})
