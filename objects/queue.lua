return function() local self = {}
    self.events = {}
    self.time = 0
    self.queuetime = 0
    local events = self.events
    local time = self.time
    local queuetime = self.queuetime
    function self:queue(event)
        events[#events+1] = {queuetime, event}
    end
    function self:delayqueue(waittime)
        if queuetime < time then
            queuetime = time
        end
        queuetime = queuetime + waittime
    end
    function self:wait(waittime)
        self:delayqueue(waittime*60)
    end
    function self:update(dt)
        time = time + 1 * dt
        if queuetime < time then
            queuetime = time
        end
    end
return self end