local Frame = {}
Frame.__index = Frame

function Frame.new(ui, x, y, w, h, settings)
    local self = {}

    self.ui = ui
    self.id = self.ui.addToElementsList(self)
    self.type = 'Frame'

    self.x, self.y = x, y
    self.w, self.h = w, h
    local settings = settings or {}
    for k, v in pairs(settings) do self[k] = v end

    self.input = self.ui.Input()
    self.input:bind('tab', 'focus-next')
    self.input:bind('lshift', 'previous-modifier')
    self.input:bind('mouse1', 'left-click')
    self.input:bind('escape', 'close')

    self.hot = false -- true if the mouse is over the object (inside its x, y, w, h rectangle)
    self.selected = false -- true if currently selected with TAB (for instance) so it can be pressed with a key
    self.down = false -- true if currently being pressed
    self.enter = false -- true on the frame the mouse has entered the frame
    self.exit = false -- true on the frame the mouse has exited the frame
    self.selected_enter = false -- true on the frame the button was selected
    self.selected_exit = false -- true on the frame the button was unselected

    self.closeable = settings.closeable or false
    self.closing = false
    self.closed = settings.closed or false
    self.close_margin = settings.close_margin or 5
    self.close_button_width = settings.close_button_width or 10
    self.close_button_height = settings.close_button_height or 10
    self.close_button = self.ui.Button(self.w - self.close_margin - self.close_button_width, self.close_margin,
                                       self.close_button_width, self.close_button_height, {theme = self.theme})

    self.draggable = settings.draggable or false
    self.drag_hot = false
    self.drag_enter = false
    self.drag_exit = false
    self.dragging = false
    self.drag_margin = settings.drag_margin or self.h/5

    self.resizable = settings.resizable or false
    self.resize_hot = false
    self.resizing = false
    self.resize_margin = settings.resize_margin or 6
    self.min_width = settings.min_width or 20
    self.min_height = settings.min_height or self.h/5

    self.elements = {}
    self.currently_focused_element = nil

    self.previous_mouse_position = nil
    self.previous_hot = false
    self.previous_selected = false
    self.previous_drag_hot = false

    -- Initialize extesions
    for _, extension in ipairs(self.extensions or {}) do
        if extension.Frame and extension.Frame.new then
            extension.Frame.new(self)
        end
    end

    -- Initialize theme
    if self.theme and self.theme.Frame and self.theme.Frame.new then
        self.theme.Frame.new(self)
    end

    return setmetatable(self, Frame)
end

function Frame:update(dt)
    if self.closed then return end

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

    -- Set focused or not
    if self.hot and self.input:pressed('left-click') then
        self.selected = true
    elseif not self.hot and self.input:pressed('left-click') then
        self.selected = false
    end

    -- Check for selected_enter
    if self.selected and not self.previous_selected then
        self.selected_enter = true
    else self.selected_enter = false end

    -- Check for selected_exit
    if not self.selected and self.previous_selected then
        self.selected_exit = true
    else self.selected_exit = false end

    if self.draggable then
        -- Check for drag_hot
        if self.hot and x >= self.x and x <= self.x + self.w and y >= self.y and y <= self.y + self.drag_margin then
            self.drag_hot = true
        else self.drag_hot = false end

        -- Check for drag_enter
        if self.drag_hot and not self.previous_drag_hot then
            self.drag_enter = true
        else self.drag_enter = false end

        -- Check for drag_exit
        if not self.drag_hot and self.previous_drag_hot then
            self.drag_exit = true
        else self.drag_exit = false end
    end

    if self.resizable then
        -- Check for resize_hot
        if (x >= self.x and x <= self.x + self.resize_margin and y >= self.y and y <= self.y + self.h) or
           (x >= self.x and x <= self.x + self.w and y >= self.y and y <= self.y + self.resize_margin) or
           (x >= self.x + self.w - self.resize_margin and x <= self.x + self.w and y >= self.y and y <= self.y + self.h) or
           (x >= self.x and x <= self.x + self.w and y >= self.y + self.h - self.resize_margin and y <= self.y + self.h) then
            self.resize_hot = true 
        else self.resize_hot = false end
    end

    -- Close
    if self.close_button.pressed then
        self.closing = true
    end
    if self.closing and self.close_button.released then
        self.closed = true
        self.closing = false
    end
    if self.selected and self.input:pressed('close') then
        self.closed = true
    end

    -- Drag
    if self.drag_hot and self.input:pressed('left-click') then
        self.dragging = true
    end
    -- Resizing has precedence over dragging
    if self.dragging and not self.resizing and self.input:down('left-click') then
        local dx, dy = x - self.previous_mouse_position.x, y - self.previous_mouse_position.y
        self.x, self.y = self.x + dx, self.y + dy
    end
    if self.dragging and self.input:released('left-click') then
        self.dragging = false
    end

    -- Resize
    if self.resize_hot and self.input:pressed('left-click') then
        self.resizing = true
    end
    if self.resizing and self.input:down('left-click') then
        local dx, dy = x - self.previous_mouse_position.x, y - self.previous_mouse_position.y
        self.w, self.h = math.max(self.w + dx, self.min_width), math.max(self.h + dy, self.min_height)
    end
    if self.resizing and self.input:released('left-click') then
        self.resizing = false
    end

    -- Focus on elements
    if not self.input:down('previous-modifier') and self.input:pressed('focus-next') then self:focusNext() end
    if self.input:down('previous-modifier') and self.input:pressed('focus-next') then self:focusPrevious() end
    for i, element in ipairs(self.elements) do
        if not element.selected or not i == self.currently_focused_element then
            element.selected = false
        end
        if i == self.currently_focused_element then
            element.selected = true
        end
    end

    if self.closeable then 
        self.close_button:update(dt, self) 
    end

    -- Update extensions
    for _, extension in ipairs(self.extensions or {}) do
        if extension.Frame and extension.Frame.update then
            extension.Frame.update(self, dt, parent)
        end
    end

    -- Update theme
    if self.theme and self.theme.Frame and self.theme.Frame.update then
        self.theme.Frame.update(self, dt, parent)
    end

    for _, element in ipairs(self.elements) do element:update(dt, self) end

    -- Set previous frame state
    self.previous_hot = self.hot
    self.previous_selected = self.selected
    self.previous_drag_hot = self.drag_hot
    self.previous_mouse_position = {x = x, y = y}

    self.input:update(dt)
end

function Frame:draw()
    if self.closed then return end

    -- Draw extensions
    for _, extension in ipairs(self.extensions or {}) do
        if extension.Frame and extension.Frame.draw then
            extension.Frame.draw(self)
        end
    end

    -- Draw theme
    if self.theme and self.theme.Frame and self.theme.Frame.draw then 
        self.theme.Frame.draw(self) 
    end

    if self.closeable then self.close_button:draw() end
    for _, element in ipairs(self.elements) do element:draw() end
end

function Frame:addElement(element)
    element.parent = self
    table.insert(self.elements, element)
    return element.id
end

function Frame:getElement(id)
    for _, element in ipairs(self.elements) do
        if element.id == id then return element end
    end
end

function Frame:bind(key, action)
    self.input:bind(key, action)
end

function Frame:destroy()
    self.ui.removeFromElementsList(self.id)
end

function Frame:focusNext()
    for i, element in ipairs(self.elements) do 
        if element.selected then self.currently_focused_element = i end
        element.selected = false 
    end
    if self.currently_focused_element then
        self.currently_focused_element = self.currently_focused_element + 1
        if self.currently_focused_element > #self.elements then
            self.currently_focused_element = 1
        end
    else self.currently_focused_element = 1 end
end

function Frame:focusPrevious()
    for i, element in ipairs(self.elements) do 
        if element.selected then self.currently_focused_element = i end
        element.selected = false 
    end
    if self.currently_focused_element then
        self.currently_focused_element = self.currently_focused_element - 1
        if self.currently_focused_element < 1 then
            self.currently_focused_element = #self.elements
        end
    else self.currently_focused_element = #self.elements end
end

return setmetatable({new = new}, {__call = function(_, ...) return Frame.new(...) end})
