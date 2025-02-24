pico-8 cartridge // http://www.pico-8.com
version 16
__lua__

-- linear interpolation function
function lerp(v0, v1, t)
    return v0 + t * (v1 - v0)
end

function init_player()
    player = {
        -- player position in terms of tilesize
        x = 4,
        y = 4
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
                width = 8 / tilesize,
                height = 6 / tilesize
            },
            vertical = {
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
        meditate = {11, 12}
    }
    player.drowsiness = 0 -- TODO: implement
end

function init_time()
    game_time = {
        hour = 0, -- 0-10, 0 is 12am, 10 is 10am
        minute = 0, -- 0-59
        second = 0, -- 0-59
        increment_speed = 50, -- speed of incrementing time; TODO: figure out best speed
        time_counter = 0
    }
end

function _init()
    tilesize = 8 -- size of tile in pixels

    init_player()
    updatecollisionbox(player)

    init_time()
    iteration = 0
    game_over = false 

    -- types of objects 
    objects = {
        terrain = { [49] = true, [52] = true, [53] = true, [54] = true, [55] = true,
                    [56] = true, [57] = true, [58] = true, [59] = true, [60] = true
        },
        disposal = { [34] = true, [35] = true, [50] = true, [51] = true },
        matcha = {
            tile = 38, 
            spill_locations = {
                -- location 1
                {x = 8, y = 7}, {x = 9, y = 7}, {x = 10, y = 7}, {x = 11, y = 7},
                {x = 7, y = 8}, {x = 8, y = 8}, {x = 9, y = 8}, {x = 10, y = 8}, {x = 11, y = 8},
                -- location 2
                {x = 17, y = 11},
                {x = 16, y = 12}, {x = 17, y = 12}, {x = 18, y = 12},
                {x = 16, y = 13},
                -- location 3
                {x = 4, y = 23}, {x = 5, y = 23}, {x = 7, y = 23}, {x = 8, y = 23}
            }
        },
        coffee = {
            tile = 39,
            spill_locations = {
                -- location 1
                {x = 23, y = 23},
                {x = 22, y = 24}, {x = 23, y = 24}, {x = 24, y = 24},
                {x = 20, y = 25}, {x = 21, y = 25}, {x = 22, y = 25}, {x = 23, y = 25}, {x = 24, y = 25}, {x = 25, y = 25},
                -- location 2
                {x = 30, y = 21}, {x = 31, y = 21},
                {x = 33, y = 23}
            }
        },
        boba = {
            tile = 40, 
            spill_locations = {
                -- location 1
                {x = 26, y = 5}, {x = 27, y = 5},
                -- location 2
                {x = 13, y = 14},
                -- location 3
                {x = 3, y = 15},
                {x = 3, y = 16},
                {x = 4, y = 17}, {x = 5, y = 17},
                {x = 3, y = 18}, {x = 4, y = 18}, {x = 5, y = 18},
                {x = 4, y = 19}, {x = 5, y = 19}, {x = 6, y = 19},
            }
        }
    }

    screensize = {
        width = 128,
        height = 128
    }
    mapsize = {
        -- TODO: need to figure out
        width = 35,
        height = 27
    }

    grav = 0.5 / tilesize -- gravity, sprite is floating down
    maxgrav = 50.0 / tilesize -- maximum gravity
    movespeed = 1.0 / tilesize -- speed of player movement, horizontal or vertical
    floatspeed = 1.0 / tilesize -- speed of player movement, floating
    downspeed = 2.0 / tilesize -- speed of player movement, going down
    
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
    if game_over then
        iteration = min(iteration + 0.3, 17)
        return
    end

    player.speed.x = 0 
    
    -- player actions / input
    if btn(0) or btn(1) or btn(2) or btn(3) then
        if btn(0) then -- move left
            player.speed.x = -movespeed
            player.moving_left = true
        end
        if btn(1) then -- move right
            player.speed.x = movespeed
            player.moving_left = false
        end
        if btn(2) then -- move up
            float(player)
        end
        if btn(3) then -- move down
            go_down(player)
        else
            player.godown = false
        end
        player.meditating = false
    elseif btn(5) then -- this is the 
       -- TODO: medidation
       if player.onground then
            meditate(player)
       end
       player.godown = false
    else 
        player.godown = false
        player.meditating = false
    end

    applyphysics(player)
    animate(player)
    update_collectible(player.item)
    update_time()
    check_game_state()

    -- camera follow player
    local screenx, screeny = player.x * tilesize - cam.x, player.y * tilesize - cam.y
    if screenx < camerasnap.left then
        cam.x += screenx - camerasnap.left
    elseif screenx > camerasnap.right then
        cam.x += screenx - camerasnap.right
    else 
        local center = player.x * tilesize - screensize.width / 2
        cam.x += (center - cam.x) / 6
    end

    if screeny < camerasnap.top then
        cam.y += screeny - camerasnap.top
    elseif screeny > camerasnap.bottom then
        cam.y += screeny - camerasnap.bottom
    else
        local center = player.y * tilesize - screensize.height / 2
        cam.y += (center - cam.y) / 6
    end

    maxcamx, maxcamy = 
    max(0, mapsize.width * tilesize - screensize.width),
    max(0, mapsize.height * tilesize - screensize.height)
    
    cam.x = mid(0, cam.x, maxcamx)
    cam.y = mid(0, cam.y, maxcamy)

end

function _draw()
    camera(cam.x, cam.y)
    cls()
    -- clip(32, 32, 64, 64)
    map(0, 0, 0, 0, screensize.width, screensize.height)

    -- debug hitboxes
    -- local hbox = player.collision.box.horizontal
    -- rect(hbox.left*tilesize, hbox.top*tilesize, hbox.right*tilesize, hbox.bottom*tilesize, 8)  -- horizontal

    -- local cbox = player.collision.box.ceiling
    -- rect(cbox.left*tilesize, cbox.top*tilesize, cbox.right*tilesize, cbox.bottom*tilesize, 9)  -- ceiling

    -- local fbox = player.collision.box.floor
    -- rect(fbox.left*tilesize, fbox.top*tilesize, fbox.right*tilesize, fbox.bottom*tilesize, 12)  -- floor

    -- local obox = player.collision.box.collectible
    -- rect(obox.left*tilesize, obox.top*tilesize, obox.right*tilesize, obox.bottom*tilesize, 11)  -- collectible

    -- - 8 to center the sprite, accurate collision detection
    spr(player.anim[player.frame], player.x * tilesize, player.y * tilesize - 8, 1, 1, player.mirror)
    -- draw collectible if player is holding one
    if player.item then
        local item = player.item
        spr(item.sprite, item.x * tilesize, item.y * tilesize - 8, 1, 1, false)
    end

    camera(0, 0)
    print("drowsiness: " .. player.drowsiness .. "%", 0, 0, 7) -- print player consciousness level 
    
    print(format_time(), 0, 8, 7) -- print time

    -- ending screen
    if game_over then 
        if iteration < 16 then
            draw_game_over()
        else 
            cls(0)
            pal()
            print("game over", 40, 40, 7)
            if game_win then
                -- TODO: TEST
                print("you win", 40, 50, 7)
            else
                print("you lose", 40, 50, 7)
            end
        end
    end
    
end

function draw_game_over()
    -- credit: http://kometbomb.net/pico8/fadegen.html
    local fadetable = {
        {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
        {1,1,129,129,129,129,129,129,129,129,0,0,0,0,0},
        {2,2,2,130,130,130,130,130,128,128,128,128,128,0,0},
        {3,3,3,131,131,131,131,129,129,129,129,129,0,0,0},
        {4,4,132,132,132,132,132,132,130,128,128,128,128,0,0},
        {5,5,133,133,133,133,130,130,128,128,128,128,128,0,0},
        {6,6,134,13,13,13,141,5,5,5,133,130,128,128,0},
        {7,6,6,6,134,134,134,134,5,5,5,133,130,128,0},
        {8,8,136,136,136,136,132,132,132,130,128,128,128,128,0},
        {9,9,9,4,4,4,4,132,132,132,128,128,128,128,0},
        {10,10,138,138,138,4,4,4,132,132,133,128,128,128,0},
        {11,139,139,139,139,3,3,3,3,129,129,129,0,0,0},
        {12,12,12,140,140,140,140,131,131,131,1,129,129,129,0},
        {13,13,141,141,5,5,5,133,133,130,129,129,128,128,0},
        {14,14,14,134,134,141,141,2,2,133,130,130,128,128,0},
        {15,143,143,134,134,134,134,5,5,5,133,133,128,128,0}
       }
    
    for c = 0, 15 do 
        if flr(iteration+1) == 16 then
            pal(c, 0)
        else
            pal(c, fadetable[c+1][flr(iteration+1)])
        end
    end

end

function float(entity)
    entity.onground = false
    entity.speed.y = -floatspeed
end

function go_down(entity)
    entity.godown = true
    entity.speed.y = floatspeed
end

function meditate(entity)
    entity.meditating = true
end

function check_game_state()
    if player.drowsiness >= 100 then
        game_over = true --TODO
        game_win = true --TODO
    end
end

function update_collectible(item)
    -- collectible 
    if not item then 
        return
    end

    local target_x = player.x + (player.moving_left and 1 or -1)*0.8
    local target_y = player.y 
    item.x += (target_x - item.x)/6
    item.y += (target_y - item.y)/6

    updatecollisionbox(item)

    -- check for collisions
    check_terrain_collisions(item)

    -- check for collision with disposal area
    for tile in gettiles(item, "horizontal") do
        if objects.disposal[tile.sprite] and item.sprite then
            remove_spill()
            player.drowsiness += 20
        end
    end

end

function remove_spill()
    for i = 1, #objects.matcha.spill_locations do
        local spill = objects.matcha.spill_locations[i]
        mset(spill.x, spill.y, 0)
    end
    player.item = nil
end

function update_time()
    game_time.time_counter += 1
    if game_time.time_counter >= game_time.increment_speed then
        increment_time()
        game_time.time_counter = 0
    end
end

function increment_time()
    game_time.second += 1
    if game_time.second >= 60 then
        game_time.second = 0
        game_time.minute += 1
    end
    if game_time.minute >= 60 then
        game_time.minute = 0
        game_time.hour += 1
    end
    if game_time.hour == 11 then
        game_over = true --TODO
        game_win = false --TODO
    end
end

function format_time()
    local hour = game_time.hour
    local minute = game_time.minute
    local second = game_time.second
    local ampm = "am"
    if minute < 10 then
        minute = "0" .. minute
    end
    if second < 10 then
        second = "0" .. second
    end
    return hour .. ":" .. minute .. ":" .. second .. " " .. ampm
end

function applyphysics(entity)
    -- apply movement physics to entity
    local speed = entity.speed
    
    -- for floating
    if not entity.onground then
        if entity.godown then 
            speed.y = min(speed.y + grav, maxgrav)
        else 
            speed.y = min(speed.y + grav, floatspeed)
        end
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

        for tile in gettiles(entity, "floor") do
            if objects.terrain[tile.sprite] then
                local tiletop = tile.y
            
                if tile.slope then
                    local slope = tile.slope

                    local xoffset = abs(entity.x - tile.x)
                    
                    if xoffset < 0 or xoffset > 1 then
                        -- only do slopes if the entity's center x coordinate is inside the tile space
                        -- otherwise ignore this tile
                        tiletop = nil
                    else
                        local slopeheight
                        if slope.reversed then
                            slopeheight = lerp(slope.offset + slope.height, slope.offset, xoffset)
                        else
                            slopeheight = lerp(slope.offset, slope.offset + slope.height, 1 - xoffset)
                        end
                        
                        -- local slopeheight = lerp(slope.offset, slope.offset + slope.height, alpha)
                        tiletop = tile.y + 1 - slopeheight
                        
                        -- only snap the entity down to the slope's height if it wasn't jumping or on the ground
                        if entity.y < tiletop then
                            tiletop = nil
                        end
                    end
                else
                    tiletop = nil
                end
                    
                if tiletop then
                    entity.y = tiletop
                    entity.onground = true
                end
            end
        end
        
        check_terrain_collisions(entity)

        -- check for collision with collectibles
        for tile in gettiles(entity, "collectible") do
            if tile.sprite == objects.matcha.tile or tile.sprite == objects.coffee.tile or tile.sprite == objects.boba.tile then
                pickup_item(tile)
            end
        end
        
    end
    
end


function check_terrain_collisions(entity)
    -- check for collision with walls
    for tile in gettiles(entity, "horizontal") do
        if objects.terrain[tile.sprite] and not tile.slope then
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
        if objects.terrain[tile.sprite] and not tile.slope then
            entity.y = tile.y
            entity.onground = true
        end
    end

    updatecollisionbox(entity)

    -- check for collision with ceiling
    for tile in gettiles(entity, "ceiling") do
        if objects.terrain[tile.sprite] and not tile.slope then
            entity.y = tile.y + 1 + entity.collision.size.vertical.height
        end
    end

end

function pickup_item(tile)
    if not player.item then 
        player.item = {
            x = tile.x,
            y = tile.y,
            sprite = tile.sprite,
            collision = {
                size = {
                    horizontal = {
                        width = 8 / tilesize,
                        height = 6 / tilesize
                    },
                    vertical = {
                        width = 6 / tilesize,
                        height = 8 / tilesize
                    }
                }
            }
        }
        mset(tile.x, tile.y, 0) -- remove item from map
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

        local flags = fget(sprite)
        
        if band(flags, 128) == 128 then -- if flag 7 is set, then it's a slope
            touching_slope = true
            ret.slope = {
                reversed = band(flags, 64) == 64, -- if flag 6 is set, slope is reversed
                height = (band(flags, 7) + 1) / tilesize,
                offset = band(lshr(flags, 3), 7) / tilesize
            }
        end
        
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
            right = entity.x + 1 - size.horizontal.width / 8, -- right bound of entity
            bottom = entity.y - size.horizontal.height / 1.5
        }, 

        floor = {
            left = entity.x + size.vertical.width / 7,
            top = entity.y - size.vertical.height / 3,
            right = entity.x + 1 - size.vertical.width / 7,
            bottom = entity.y
        },

        ceiling = {
            left = entity.x + size.vertical.width / 5,
            top = entity.y - 1,
            right = entity.x + 1 - size.vertical.width / 3,
            bottom = entity.y - size.vertical.height / 2
        },

        collectible = {
            left = entity.x + size.horizontal.width / 3,
            top = entity.y - 1 + size.horizontal.height / 3,
            right = entity.x + 1 - size.horizontal.width / 3,
            bottom = entity.y - size.horizontal.height / 3
        }

    }
end

function animate(entity)
    -- which animation to play
    if not entity.onground then 
        if entity.speed.y < 0 then
            setanim(entity, "floating_up")
        else
            if entity.godown then
                setanim(entity, "move_down")
            else
                setanim(entity, "floating_down")
            end
        end
    elseif entity.godown then
        setanim(entity, "smush_down")
    elseif entity.meditating then
        setanim(entity, "meditate")
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