return function() local self = {}
    self.dialogue = require "objects.dialogue" (nil, "fnt_default_big", 52, 272)
    self.queue = require "objects.queue" ()
    self.dialoguetext = {}
    function self:nextdialogue()
        local text = table.remove(self.dialoguetext, 1)
        if type(text) == "table" then
            local func = text[2]
            text = text[1]
            if func then func() end
        end
        if text then self.dialogue:settext(text) end
    end
    function self:endturn(dialogue)
        self.dialogue:settext("")
        self.dialoguetext = {unpack(dialogue or {})}
        self:nextdialogue()
    end
    function self:onupdate(dt) end
    function self:update(dt)
        self.dialogue:update()
        self.queue:update(dt)
        if ISPRESSED "CANCEL" then
            if DEBUG and self.dialogue.text == self.dialogue.targettext then
                RELOAD()
            end
        end
        if ISPRESSED "SELECT" and self.dialogue.text == self.dialogue.targettext then
            self:nextdialogue()
        end
        self:onupdate(dt)
    end
    function self:draw()
        self.dialogue:draw()
    end
    local dialogue = {"* (Ring Ring...)","* Hello? is anyone there?", "* Welp, i guess i'll leave a message"}
    if love.math.random(1,100) == 1 then
        table.insert(dialogue,{"* Thanks for playing my little Undertale fan game!",function() MUSIC("z_ending.ogg"):play() MUSIC("z_ending.ogg"):setLooping(true) end})
        table.insert(dialogue,"* Made with Love2D and a lot of coffee :D")
        table.insert(dialogue,"* See you next time!")
        table.insert(dialogue,"(No coffe was harmed on the production of this software\n  i hate coffe)")
    else
        table.insert(dialogue, {"* This is an ending scene test text",function() MUSIC("z_ending.ogg"):play() MUSIC("z_ending.ogg"):setLooping(true) end})
        table.insert(dialogue, "* You can use this to make other\n  endings")
        table.insert(dialogue, "* ererer er")
        table.insert(dialogue, "* look at this shiny code, its soo\n  cool wow")
        table.insert(dialogue, "* ererer er, ererer er er er")
        table.insert(dialogue, "* this might be innacurate...")
        table.insert(dialogue, "* where is the dialogue at :(?")
        table.insert(dialogue, "* ending text")
        table.insert(dialogue, "")
        table.insert(dialogue, "* You though that was the last text?\n  no lol")
        table.insert(dialogue, "* The underground has got a lot\n  quieter since you came here...")
        table.insert(dialogue, "* what did you do?")
        table.insert(dialogue, "* i can't go to hell, im out of\n  vacation days ;)")
        table.insert(dialogue, "* real ending text")
        table.insert(dialogue, "")
    end
    self:endturn(dialogue)
return self end