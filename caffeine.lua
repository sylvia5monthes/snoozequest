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
    
    if btn(0) then
        player.speed.x = -movespeed
    elseif btn(1) then
        player.speed.x = movespeed
    elseif btn(5) then
       print("hi")
    end

    applyphysics(player)
    animate(player)

end

function _draw()
    cls()
    map(0, 0, 0, 0, screensize.width, screensize.height)
    -- - 8 to center the sprite, accurate collision detection
    spr(player.anim[player.frame], player.x * tilesize, player.y * tilesize - 8, 1, 1, player.mirror)
    print(player.speed.x)
end

function applyphysics(entity)
    -- apply movement physics to entity
    local speed = entity.speed

    if not entity.onground then
        speed.y = min(speed.y + grav, maxgrav)
    end

    entity.y += speed.y
    entity.x += speed.x

    entity.onground = false

    for tile in gettiles(entity, "floor") do
        if tile.sprite > 0 then
            speed.y = 0
            entity.y = tile.y
            entity.onground = true
        end
    end

    updatecollisionbox(entity)
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
            left = entity.x - size.horizontal.width / 2,
            top = entity.y - size.vertical.height + (size.vertical.height - size.horizontal.height) / 2,
            right = entity.x + size.horizontal.width / 2,
            bottom = entity.y - (size.vertical.height - size.horizontal.height) / 2
        }, 

        floor = {
            left = entity.x + size.vertical.width / 5,
            top = entity.y - size.vertical.height / 2,
            right = entity.x + size.vertical.width,
            bottom = entity.y
        },

        ceiling = {
            left = entity.x - size.vertical.width / 2,
            top = entity.y - size.vertical.height,
            right = entity.x + size.vertical.width / 2,
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