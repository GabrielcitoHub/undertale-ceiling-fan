return function() local self = {}
    self.menu = 1
    self.real = 0
    self.timer = 0
    PLAYSOUND "mus_intronoise.ogg"
    local function getMusic(num)
        return MUSIC("menu" .. tostring(num) .. ".ogg")
    end
    self.music = getMusic(self.real)
    function self:update(dt)
        self.timer = self.timer + 1 * dt
        if ISPRESSED "CANCEL" then
            if DEBUG and self.menu < 3 then
                RELOAD()
            elseif self.menu > 2 then
                self.menu = self.menu - 1
                self.timer = 0
            end
        end
        if ISPRESSED "SELECT" then
            if self.menu == 1 then
                self.music:play()
                self.music:setLooping(true)
            end
            if self.menu < 3 then
                self.menu = self.menu + 1
                self.timer = 0
            end
        end
    end
    function self:draw()
        if self.menu == 1 then
            love.graphics.setColor(1,1,1)
            love.graphics.draw(IMAGE "title", 0, 0, 0, 2, 2)
            if self.timer > 4 then
                love.graphics.setColor(0.5,0.5,0.5)
                love.graphics.printf("[PRESS " .. string.upper(GETKEY "SELECT") .. " OR " .. string.upper(GETKEY("SELECT",1)) .. "]", 0, 400, 640, "center")
            end
        elseif self.menu == 2 then
            love.graphics.setColor(0.5,0.5,0.5)
            local instructionStrings = {
                "[" .. string.upper(GETKEY "SELECT") .. "] or [" .. string.upper(GETKEY("SELECT",1)) .. "] - Confirm\n",
                "[" .. string.upper(GETKEY "CANCEL") .. "] or [" .. string.upper(GETKEY("CANCEL",1)) .. "] - Cancel\n",
                "[" .. string.upper(GETKEY "MENU") .. "] or [" .. string.upper(GETKEY("MENU",1)) .. "] - Menu (In-game)\n",
                "[F4] - Fullscreen\n",
                "[Hold ESC] - Quit\n",
                "When HP is 0, you lose."
            }
            love.graphics.setFont(FONT "fnt_default")
            local x,y = 60,20
            love.graphics.printf("--- Instruction ---\n",x+10,y,640,"left",0,2.3,2)
            love.graphics.printf(table.concat(instructionStrings),x,y+40,640,"left",0,2,2)
        else
        end
    end
    function self:debugdraw()
        love.graphics.setFont(FONT "fnt_default")
        love.graphics.setColor(1,1,1)
		love.graphics.print("Menu "..self.menu.."\nReal: "..self.real.."\nTimer: "..self.timer)
	end
return self end