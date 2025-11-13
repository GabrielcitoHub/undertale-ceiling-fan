return function(x, y, width, height, rotation, scale) local self = {}
    self.x = x
    self.y = y
    self.width = width
    self.height = height
    self.rotation = rotation or 0
    self.scale = scale or 1
    self.time = 0
    self.curframe = 1
    self.playing = false
    self.speed = 1

    function self:play(anim, speed, loop)
        if not anim then return false end
        self.animation = anim
        self.curframe = 1
        self.time = 0
        self.frame = anim.frames[self.curframe]
        self.speed = speed
        self.loop = loop
        self.playing = true
        return true
    end

    function self:pause()
        self.playing = false
    end

    function self:stop(frame)
        self.curframe = frame or 1
        self:_update()
        self.playing = false
    end

    function self:_update()
        if not self.animation then return end
        if self.time > self.animation.speed then
            self.time = 0
            self.curframe = self.curframe + 1

            if self.curframe > #self.animation.frames then
                if self.animation.loop or self.loop then
                    self.curframe = 1
                else
                    self.curframe = #self.animation.frames
                end
            end

            self.frame = self.animation.frames[self.curframe]
        end
    end

    function self:update(dt)
        self.time = self.time + dt * (self.speed or 1)
        if not self.playing then return end
        self:_update()
    end

    function self:draw(x, y, w, h, r, s)
        if self.frame then
            -- Use defaults if not provided
            x = x or self.x or 0
            y = y or self.y or 0
            w = w or self.width or self.frame:getWidth()
            h = h or self.height or self.frame:getHeight()
            s = s or self.scale or 1

            -- Calculate scale factors
            local sx = (w / self.frame:getWidth()) * s
            local sy = (h / self.frame:getHeight()) * s

            -- Draw the frame
            love.graphics.draw(self.frame, x, y, r, sx, sy)
        end
    end

    return self
end