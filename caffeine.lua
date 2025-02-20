pico-8 cartridge // http://www.pico-8.com
version 16
__lua__

function _init()
    tilesize = 8 -- size of tile in pixels

    player = {
        -- player position in terms of tilesize
        x = 9,
        y = 9
    }
    player.speed = {
        -- speed in terms of tilesize in x and y direction
        x = 0,
        y = 0
    }
    player.collision = {
        -- collision boxes in terms of tilesize
        size = {
            horizontal = {
                -- TODO
                width = 8 / tilesize,
                height = 6 / tilesize
            },
            vertical = {
                -- TODO
                width = 6 / tilesize,
                height = 8 / tilesize
            }
        }
    }
    player.anims = {
        -- types of animations mapped to frame numbers that make up the animation
        idle = {1, 2, 3},
        floating_up = {6, 7},
        floating_down = {8, 9}, -- player is not pressing down key
        floating_upper_diag = {}, -- tbd
        floating_lower_diag = {}, -- tbd
        move_horizontal = {4, 5},
        move_down = {24, 25}, --  player is pressing down key
        smush_down = {17, 18},
        medidate = {11, 12}
    }

    updatecollisionbox(player)

    screensize = {
        width = 128,
        height = 128
    }
    mapsize = {
        -- TODO: need to figure out
    }

    grav = 0.5 / tilesize -- gravity, sprite is floating down
    maxgrav = 1.0 / tilesize -- maximum gravity
    movespeed = 1.0 / tilesize -- speed of player movement, horizontal or vertical
    floatspeed = 1.0 / tilesize -- speed of player movement, floating
    
    camerasnap = { -- TODO: figure out exact coordinates
        left = 40,
        top = 16,
        right = screensize.width - 40,
        bottom = screensize.height - 48
    }
    cam = {
        x = 0,
        y = 0
    }

end

function _update()
    player.speed.x = 0 
    
    if btn(0) or btn(1) or btn(2) then
        if btn(0) then -- move left
            player.speed.x = -movespeed
        end
        if btn(1) then -- move right
            player.speed.x = movespeed
        end
        if btn(2) then -- move up
            float(player)
        end
    end
   
    if btn(5) then
       print("hi")
    end

    applyphysics(player)
    animate(player)

end

function _draw()
    cls()
    map(0, 0, 0, 0, screensize.width, screensize.height)

    -- debug hitboxes
    -- local hbox = player.collision.box.horizontal
    -- rect(hbox.left*tilesize, hbox.top*tilesize, hbox.right*tilesize, hbox.bottom*tilesize, 8)  -- Red for horizontal

    -- local cbox = player.collision.box.ceiling
    -- rect(cbox.left*tilesize, cbox.top*tilesize, cbox.right*tilesize, cbox.bottom*tilesize, 9)  -- orange for ceiling

    -- local fbox = player.collision.box.floor
    -- rect(fbox.left*tilesize, fbox.bottom*tilesize, fbox.right*tilesize, fbox.bottom*tilesize, 10)  -- Green for floor

    -- - 8 to center the sprite, accurate collision detection
    spr(player.anim[player.frame], player.x * tilesize, player.y * tilesize - 8, 1, 1, player.mirror)
    print(player.speed.x)
end

function float(entity)
    entity.onground = false
    entity.speed.y = -floatspeed
end

function applyphysics(entity)
    -- apply movement physics to entity
    local speed = entity.speed

    if not entity.onground then
        speed.y = min(speed.y + grav, maxgrav)
    end

    entity.onground = false

    local steps = 1
    local highestspeed = max(abs(speed.x), abs(speed.y))

    if highestspeed >= 0.25 then
        steps = ceil(highestspeed / 0.25)
    end

    for i = 1, steps do
        entity.y += speed.y
        entity.x += speed.x

        updatecollisionbox(entity)


        -- check for collision with walls
        for tile in gettiles(entity, "horizontal") do
            if tile.sprite > 0 then
                if entity.x < tile.x then
                    entity.x = tile.x - 1
                else
                    entity.x = tile.x + 1 
                end
            end
        end

        updatecollisionbox(entity)

        -- check for collision with floor
        for tile in gettiles(entity, "floor") do
            if tile.sprite > 0 then
                speed.y = 0
                entity.y = tile.y
                entity.onground = true
            end
        end

        updatecollisionbox(entity)

        -- check for collision with ceiling
        for tile in gettiles(entity, "ceiling") do
            if tile.sprite > 0 then
                entity.y = tile.y + 1 + entity.collision.size.vertical.height
            end
        end
    end
    
end

function gettiles(entity, boxtype)
    local box = entity.collision.box[boxtype]
    local left, top, right, bottom = 
        flr(box.left), flr(box.top), flr(box.right), flr(box.bottom)
    
    local x, y = left, top

    -- return iterator function that returns the next tile in the box 
    -- that the entity is colliding with
    return function()
        -- check if exceeded bottom bound
        if y > bottom then
            return nil
        end

        local sprite = mget(x, y) -- get sprite number at x, y in terms of tilesize
       
        local ret = {
            sprite = sprite, -- sprite number
            x = x, -- x position of sprite that we collide with
            y = y -- y position of sprite that we collide with
        }

        -- TODO: check flags if necessary to identify the 
        -- type of tile (e.g. ground, sound particle, caffeine item)
        
        -- move on to next tile
        x += 1
        -- if x exceeds right bound, reset x to left bound and increment y
        if x > right then
            x = left
            y += 1
        end
        return ret

    end

end

function updatecollisionbox(entity)
    -- update collision box based on entity's position
    local size = entity.collision.size

    entity.collision.box = {
        horizontal = {
            left = entity.x, -- left bound of entity
            top = entity.y - 1 + size.horizontal.height / 2,
            right = entity.x + 1, -- right bound of entity
            bottom = entity.y - size.horizontal.height / 3
        }, 

        floor = {
            left = entity.x + size.vertical.width / 3,
            top = entity.y - size.vertical.height / 2,
            right = entity.x + size.vertical.width / 1.1,
            bottom = entity.y
        },

        ceiling = {
            left = entity.x + size.vertical.width / 5,
            top = entity.y - 1,
            right = entity.x + 1 - size.vertical.width / 3,
            bottom = entity.y - size.vertical.height / 2
        }

    }
end

function animate(entity)
    -- which animation to play
    if not entity.onground then 
        if entity.speed.y < 0 then
            setanim(entity, "floating_up")
        else
            setanim(entity, "floating_down")
        end
    elseif entity.speed.x ~= 0 then 
        setanim(entity, "move_horizontal")
    else
        setanim(entity, "idle")
    end

    entity.animframes += 1 
    entity.frame = (flr(entity.animframes / 8) % #entity.anim) + 1

    if entity.speed.x < 0 then
        entity.mirror = true
    elseif entity.speed.x > 0 then 
        entity.mirror = false
    end

end

function setanim(entity, name)
    -- if the current animation is not the same as the new animation, switch 
    if entity.anim ~= entity.anims[name] then
        entity.anim = entity.anims[name]
        entity.animframes = 0
    end
end