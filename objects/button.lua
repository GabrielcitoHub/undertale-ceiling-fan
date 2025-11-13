return function() local self = {}
    self.buttons = {}
    function self:new(id,x,y,width,height)
        width = width or 30
        height = height or 30
        x = x or 0
        y = y or 0
        self.buttons[id] = {
            id = id,
            x = x,
            y = y,
            width = width,
            height = height,
            pressed = false,
            presses = 0
        }
        return self.buttons[id]
    end
    function self:updatebuttons(dt)
        for id,button in pairs(self.buttons) do
            local mx,my = MOUSEX(), MOUSEY()
            if mx >= button.x and mx <= button.x + button.width and
               my >= button.y and my <= button.y + button.height then
                button.pressed = love.mouse.isDown(1)
            else
                button.pressed = false
            end
        end
    end
    function self:drawbuttons()
        for id,button in pairs(self.buttons) do
            love.graphics.setColor(1, 1, button.pressed and 0 or 1,button.pressed and 1 or 0.4)
            love.graphics.rectangle("line", button.x, button.y, button.width, button.height)
            love.graphics.print(button.id, button.x, button.y, 0, button.width / 45, button.height / 45)
            if DEBUG then
                love.graphics.print(tostring(button.pressed), button.x, button.y + 10, 0, button.width / 45, button.height / 45)
                love.graphics.print(tostring(button.presses), button.x, button.y + 20, 0, button.width / 45, button.height / 45)
            end
            love.graphics.setColor(1, 1, 1,1)
        end
    end
    function self:update(dt)
        self:updatebuttons(dt)
    end
    function self:draw()
        love.graphics.setFont(FONT "fnt_default")
        self:drawbuttons()
    end
    --Utils functions
    function self:getButton(id)
        if type(id) == "string" then
            return self.buttons[id]
        end
        return id
    end
    function self:isDown(id)
        local button = self:getButton(id)
        if button.pressed == true then
            return true
        else
            return false
        end
    end
    function self:getID(id)
        local button = self:getButton(id)
        if button then
            return button.id
        end
    end
return self end