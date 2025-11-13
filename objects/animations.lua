return function(spritespath) local self = {}
    self.paths = {
        sprites = spritespath or "assets/sprites/characters/"
    }
    function self:newAnim(name, speed, frames, loop)
        return {
            name = name,
            speed = speed or 32,
            frames = frames,
            loop = loop or true
        }
    end
    function self:getCharacterAnimations(charName)
        local path = self.paths.sprites .. charName
        local files = love.filesystem.getDirectoryItems(path)

        -- sort alphabetically (so frame order is consistent)
        table.sort(files)

        local animations = {}

        for _, file in ipairs(files) do
            -- remove prefix and extension (e.g. "spr_mainchara_walk_000.png" → "walk_000")
            local base = file:gsub("^spr_mainchara", ""):gsub("%..+$", "")

            -- separate animation name and frame number (e.g. "walk_000" → "walk", "000")
            local animName, frameNum = base:match("(.+)_([%d]+)$")
            if not animName then
                animName = base
                frameNum = "000"
            end

            -- make sure the animation table exists
            animations[animName] = animations[animName] or {}

            -- load the frame image
            local image = love.graphics.newImage(path .. "/" .. file)
            table.insert(animations[animName], image)
        end

        -- now convert all gathered frames into animation objects using self:newAnim()
        for name, frames in pairs(animations) do
            --self.debug:print(name.." "..#frames)
            -- you can tweak the default speed here if needed
            animations[name] = self:newAnim(name, 0.1, frames)
        end

        return animations
    end
return self end
