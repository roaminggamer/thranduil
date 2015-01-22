local Textinput = {}
Textinput.__index = Textinput

local stringJoin = function(table, index, select_index)
    local string = ''
    for i, c in ipairs(table) do 
        if i == index or i == select_index then string = string .. string.char(219)
        else string = string .. c end
    end
    return string
end

function Textinput.new(ui, x, y, w, h, settings)
    local self = {}

    self.ui = ui
    self.id = self.ui.addToElementsList(self)

    self.ix, self.iy = x, y
    self.x, self.y = x, y
    self.w, self.h = w, h
    local settings = settings or {}
    for k, v in pairs(settings) do self[k] = v end

    self.input = self.ui.Input()
    self.input:bind('mouse1', 'left-click')
    self.input:bind('left', 'move-left')
    self.input:bind('right', 'move-right')
    self.input:bind('up', 'first')
    self.input:bind('down', 'last')
    self.input:bind('lshift', 'lshift')
    self.input:bind('backspace', 'backspace')
    self.input:bind('delete', 'delete')
    self.input:bind('lctrl', 'lctrl')
    self.input:bind('x', 'cut')
    self.input:bind('c', 'copy')
    self.input:bind('v', 'paste')
    self.input:bind('a', 'all')

    self.hot = false -- true if the mouse is over the object (inside its x, y, w, h rectangle)
    self.selected = true -- true if currently selected with TAB (for instance) so it can be pressed with a key
    self.down = false -- true if currently being pressed
    self.pressed = false -- true on the frame it has been pressed
    self.released = false -- true on the frame it has been released
    self.enter = false -- true on the frame the mouse has entered the frame
    self.exit = false -- true on the frame the mouse has exited the frame

    self.previous_hot = false

    self.text = ''
    self.string = {}
    self.copy_buffer = {}
    self.index = 1
    self.select_index = nil

    self.pressed_time = 0
    self.mouse_selecting = false
    self.mouse_all_selected = false
    self.mouse_pressed_time = false
    self.last_mouse_pressed_time = false

    self.font = settings.font or love.graphics.getFont()
    self.text_margin = settings.text_margin or 5

    return setmetatable(self, Textinput)
end

function Textinput:update(dt, parent)
    if not self.selected then return end

    -- Move cursor left
    if not self.input:down('lshift') and self.input:pressed('move-left') then
        self.pressed_time = love.timer.getTime()
        self.index = self.index - 1
        self.select_index = nil
        if self.index < 1 then self.index = 1 end
        print(stringJoin(self.string, self.index, self.select_index), 'LEFT')
    end
    if not self.input:down('lshift') and self.input:down('move-left') then
        local d = love.timer.getTime() - self.pressed_time
        if d > 0.2 then 
            self.index = self.index - 1
            self.select_index = nil
            if self.index < 1 then self.index = 1 end
            print(stringJoin(self.string, self.index, self.select_index), 'LEFT')
        end
    end

    -- Move cursor right
    if not self.input:down('lshift') and self.input:pressed('move-right') then
        self.pressed_time = love.timer.getTime()
        self.index = self.index + 1
        self.select_index = nil
        if self.index > #self.string + 1 then self.index = #self.string + 1 end
        print(stringJoin(self.string, self.index, self.select_index), 'RIGHT')
    end
    if not self.input:down('lshift') and self.input:down('move-right') then
        local d = love.timer.getTime() - self.pressed_time
        if d > 0.2 then 
            self.index = self.index + 1
            self.select_index = nil
            if self.index > #self.string + 1 then self.index = #self.string + 1 end
            print(stringJoin(self.string, self.index, self.select_index), 'RIGHT')
        end
    end

    -- Move cursor to beginning
    if self.input:pressed('first') then
        self.index = 1
        self.select_index = nil
    end

    -- Move cursor to end
    if self.input:pressed('last') then
        self.index = #self.string + 1
        self.select_index = nil
    end

    -- Select right
    if self.input:down('lshift') and self.input:pressed('move-left') then
        self.pressed_time = love.timer.getTime()
        if not self.select_index then self.select_index = self.index - 1 
        else self.select_index = self.select_index - 1 end
        if self.select_index < 1 then self.select_index = 1 end
        print(stringJoin(self.string, self.index, self.select_index), 'SHIFT + LEFT')
    end
    if self.input:down('lshift') and self.input:down('move-left') then
        local d = love.timer.getTime() - self.pressed_time
        if d > 0.2 then 
            if not self.select_index then self.select_index = self.index - 1 
            else self.select_index = self.select_index - 1 end
            if self.select_index < 1 then self.select_index = 1 end
            print(stringJoin(self.string, self.index, self.select_index), 'SHIFT + LEFT')
        end
    end

    -- Select left
    if self.input:down('lshift') and self.input:pressed('move-right') then
        self.pressed_time = love.timer.getTime()
        if not self.select_index then self.select_index = self.index + 1
        else self.select_index = self.select_index + 1 end
        if self.select_index > #self.string + 1 then self.select_index = #self.string + 1 end
        print(stringJoin(self.string, self.index, self.select_index), 'SHIFT + RIGHT')
    end
    if self.input:down('lshift') and self.input:down('move-right') then
        local d = love.timer.getTime() - self.pressed_time
        if d > 0.2 then 
            if not self.select_index then self.select_index = self.index + 1
            else self.select_index = self.select_index + 1 end
            if self.select_index > #self.string + 1 then self.select_index = #self.string + 1 end
            print(stringJoin(self.string, self.index, self.select_index), 'SHIFT + RIGHT')
        end
    end

    -- Select all
    if self.input:down('lctrl') and self.input:pressed('all') then
        self.index = 1
        self.select_index = #self.string + 1
        print(stringJoin(self.string, self.index, self.select_index), 'CTRL + A')
    end

    -- Delete before cursor
    if self.input:pressed('backspace') then
        self.pressed_time = love.timer.getTime()
        if self.select_index then
            self:deleteSelected()
        else
            table.remove(self.string, self.index - 1)
            self.index = self.index - 1
            if self.index < 1 then self.index = 1 end
        end
        print(stringJoin(self.string, self.index, self.select_index), 'BACKSPACE')
    end
    if self.input:down('backspace') then
        local d = love.timer.getTime() - self.pressed_time
        if d > 0.2 then 
            if self.select_index then
                self:deleteSelected()
            else
                table.remove(self.string, self.index - 1)
                self.index = self.index - 1
                if self.index < 1 then self.index = 1 end
            end
            print(stringJoin(self.string, self.index, self.select_index), 'BACKSPACE')
        end
    end

    -- Delete after cursor
    if self.input:pressed('delete') then
        self.pressed_time = love.timer.getTime()
        if self.select_index then
            self:deleteSelected()
        else
            if self.index == #self.string + 1 then
                table.remove(self.string, self.index - 1)
                self.index = self.index - 1
                if self.index < 1 then self.index = 1 end
            else table.remove(self.string, self.index) end
        end
        print(stringJoin(self.string, self.index, self.select_index), 'DELETE')
    end
    if self.input:down('delete') then
        local d = love.timer.getTime() - self.pressed_time
        if d > 0.2 then 
            if self.select_index then
                self:deleteSelected()
            else
                if self.index == #self.string + 1 then
                    table.remove(self.string, self.index - 1)
                    self.index = self.index - 1
                    if self.index < 1 then self.index = 1 end
                else table.remove(self.string, self.index) end
            end
            print(stringJoin(self.string, self.index, self.select_index), 'DELETE')
        end
    end

    local x, y = love.mouse.getPosition()

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

    -- Cursor selection with mouse
    if self.hot and self.input:pressed('left-click') then
        self.select_index = nil
        self.mouse_all_selected = false
        self.mouse_pressing = true
        for i = 0, #self.string + 1 do
            local _x, _y = self.x + self.text_margin + self.font:getWidth(self.text:utf8sub(1, i)), self.y + self.text_margin
            local w, h = self.font:getWidth(self.text:utf8sub(i, i)), self.font:getHeight()
            if i == 0 then w, h = self.font:getWidth(self.text:utf8sub(1, 1)), self.font:getHeight() end
            if x >= _x and x <= _x + w and y >= _y and y <= _y + h then
                self.index = i + 1
            end
        end
    end
    if not self.mouse_all_selected and self.mouse_pressing and self.input:down('left-click') then
        for i = 0, #self.string + 1 do
            local _x, _y = self.x + self.text_margin + self.font:getWidth(self.text:utf8sub(1, i)), self.y + self.text_margin
            local w, h = self.font:getWidth(self.text:utf8sub(i, i)), self.font:getHeight()
            if i == 0 then w, h = self.font:getWidth(self.text:utf8sub(1, 1)), self.font:getHeight() end
            if x >= _x and x <= _x + w and y >= _y and y <= _y + h then
                self.select_index = i + 1
            end
            if self.index == self.select_index then self.select_index = nil end
        end
    end
    if self.mouse_pressing and self.input:released('left-click') then
        self.mouse_pressing = false
    end

    -- Cursor double click all selection
    if self.hot and self.input:pressed('left-click') then
        self.mouse_pressed_time = love.timer.getTime()
        if self.last_mouse_pressed_time then
            local d = self.mouse_pressed_time - self.last_mouse_pressed_time
            if d < 0.3 then self.mouse_all_selected = true end
        end
    end
    if self.mouse_all_selected then
        self.index = 1
        self.select_index = #self.string + 1
    end

    if self.input:down('lctrl') and self.input:pressed('copy') then self:copySelected() end
    if self.input:down('lctrl') and self.input:pressed('cut') then self:cutSelected() end
    if self.input:down('lctrl') and self.input:pressed('paste') then self:pasteCopyBuffer() end

    -- Set text as a string
    self.text = stringJoin(self.string)

    -- Figure out selection/cursor position in pixels
    local u, v, w
    u = self.font:getWidth(self.text:utf8sub(1, self.index - 1))
    v = self.font:getWidth(self.text:utf8sub(1, self.index))
    if self.select_index then v = self.font:getWidth(self.text:utf8sub(1, self.select_index - 1)) end
    if self.index == #self.string + 1 and not self.select_index then v = v + self.font:getWidth('a') end
    self.selection_position = {x = self.x + u + self.text_margin, y = self.y + self.text_margin}
    self.selection_size = {w = v - u, h = self.font:getHeight()}

    -- Last frame
    self.previous_hot = self.hot
    self.last_mouse_pressed_time = self.mouse_pressed_time
end

function Textinput:draw(parent)
    love.graphics.setColor(32, 32, 32)
    love.graphics.rectangle('fill', self.x, self.y, self.w, self.h)

    if self.hot then
        love.graphics.setColor(64, 64, 64)
        love.graphics.rectangle('fill', self.x, self.y, self.w, self.h)
    end

    love.graphics.setColor(128, 128, 128)
    love.graphics.print(self.text, self.x + self.text_margin, self.y + self.text_margin)

    love.graphics.setColor(192, 192, 192, 64)
    love.graphics.rectangle('fill', self.selection_position.x, self.selection_position.y, self.selection_size.w, self.selection_size.h)

    love.graphics.setColor(255, 255, 255, 255)
end

function Textinput:keypressed(key)
    self.input:keypressed(key)
end

function Textinput:keyreleased(key)
    self.input:keyreleased(key)
end

function Textinput:mousepressed(button)
    self.input:mousepressed(button)
end

function Textinput:mousereleased(button)
    self.input:mousereleased(button)
end

function Textinput:gamepadpressed(joystick, button)
    self.input:gamepadpressed(joystick, button)   
end

function Textinput:gamepadreleased(joystick, button)
    self.input:gamepadreleased(joystick, button)
end

function Textinput:gamepadaxis(joystick, axis, value)
    self.input:gamepadaxis(joystick, axis, value)
end

function Textinput:bind(key, action)
    self.input:bind(key, action)
end

function Textinput:textinput(text)
    if not self.selected then return end
    self:deleteSelected()
    table.insert(self.string, self.index, text)
    self.index = self.index + 1
    print(stringJoin(self.string, self.index, self.select_index), text)
end

function Textinput:destroy()
    self.ui.removeFromElementsList(self.id)
end

function Textinput:pasteCopyBuffer()
    for _, c in ipairs(self.copy_buffer) do
        table.insert(self.string, self.index, c)
        self.index = self.index + 1
    end
    print(stringJoin(self.string, self.index, self.select_index), 'CTRL + P: ' .. stringJoin(self.copy_buffer))
end

function Textinput:cutSelected()
    self:copySelected()
    self:deleteSelected()
    print(stringJoin(self.string, self.index, self.select_index), 'CTRL + X: ' .. stringJoin(self.copy_buffer))
end

function Textinput:copySelected()
    if self.select_index then
        if self.index == self.select_index then return end
        self.copy_buffer = {}
        local min, max = 0, 0
        if self.index < self.select_index then min = self.index; max = self.select_index - 1 
        elseif self.select_index < self.index then min = self.select_index; max = self.index - 1 end
        for i = min, max, 1 do
            table.insert(self.copy_buffer, self.string[i])
        end
    end
    print(stringJoin(self.string, self.index, self.select_index), 'CTRL + C: ' .. stringJoin(self.copy_buffer))
end

function Textinput:deleteSelected()
    if self.select_index then
        if self.index == self.select_index then return end
        local min, max = 0, 0
        if self.index < self.select_index then min = self.index; max = self.select_index - 1 
        elseif self.select_index < self.index then min = self.select_index; max = self.index - 1 end
        for i = max, min, -1 do
            table.remove(self.string, i)
        end
        self.index = min
        self.select_index = nil
    end
end

return setmetatable({new = new}, {__call = function(_, ...) return Textinput.new(...) end})
