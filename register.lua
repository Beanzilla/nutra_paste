local S = minetest.get_translator("nutra_paste")

-- The meal / paste
minetest.register_craftitem("nutra_paste:meal", {
    description = "Nutra Paste",
    inventory_image = "nutra_paste_meal.png",
    stack_max = 99,
    on_use = minetest.item_eat(1)
})
minetest.register_craft({
    type = "fuel",
    recipe = "nutra_paste:meal",
    burntime = 1
})

nutra_paste.update = function (pos, elapsed)
    local meta=minetest.get_meta(pos)
    local inv=meta:get_inventory()
    local gen="nutra_paste:meal" -- The item to be produced
    local process=meta:get_int("proc")

    if meta:get_string("owner") == "" then
        minetest.swap_node(pos, {name ="air"})
        return false
    end

    if inv:room_for_item("done",gen) == false then
        --minetest.get_node_timer(pos):stop()
        meta:set_int("proc", 0)
        nutra_paste.inv_update(pos) -- Update the formspec for the new percent
        local reported = false
        if inv:room_for_item("done",gen) == false and not reported then
            meta:set_string("infotext", "Nutra Paste Machine [Full] (" .. meta:get_string("owner") .. ")")
            reported = true
        end
        --minetest.swap_node(pos, {name ="nutra_paste:machine"})
        --return false
    end
    process=process+1
    if process>=nutra_paste.settings.time_per_production then
        process=0
        for i=1,nutra_paste.settings.amount_per_production,1 do
            if inv:room_for_item("done",gen)==true then -- Only works if there is room
                inv:add_item("done",gen)
            end
        end
        if nutra_paste.settings.log_production then
            nutra_paste.tools.log("nutra_paste:machine at "..minetest.pos_to_string(pos).." by '"..meta:get_string("owner").."' has produced '"..gen.."' x "..tostring(nutra_paste.settings.amount_per_production))
        end
    end
    meta:set_int("proc",process)
    -- Let's really use a percent rather than some made up stuff.
    local percent = ((process/nutra_paste.settings.time_per_production) * 100)
    local percent_format = string.format("%.0f", percent)
    nutra_paste.inv_update(pos) -- Update the formspec for the new percent
    meta:set_string("infotext", "Nutra Paste Machine " .. percent_format  .."% (" .. meta:get_string("owner") .. ")")
    return true
end

-- Attempt to get the MCL formspec to build a formspec able to be shown via their stuff
local mclform = rawget(_G, "mcl_formspec") or nil

-- This formspec will auto-change if MCL detected
nutra_paste.inv_update = function(pos)
    local meta=minetest.get_meta(pos)
    local inv=meta:get_inventory()
    local names=meta:get_string("names")
    local op=meta:get_int("open")
    local open=""
    if op==0 then
        open="Only U"
    elseif op==1 then
        open="Members"  
    else
        open="Public"
    end
    local proc = meta:get_int("proc")
    local percentage = ""
    local percent = ((proc/nutra_paste.settings.time_per_production) * 100)
    local percent_format = string.format("%.0f", percent)
    percentage = ""..percent_format.."%"
    if nutra_paste.GAMEMODE == "MTG" then
        meta:set_string("formspec",
            "size[8,11]" ..
            "label[0.3,0.3;"..minetest.formspec_escape(percentage).."]" ..
            "button[0,1; 1.5,1;save;Save]" ..
            "button[0,2; 1.5,1;open;" .. open .."]" ..
            "textarea[2.2,1.3;6,1.8;names;Members List (Inventory access);" .. names  .."]"..
            "list[context;done;0,2.9;8,4;]" ..
            "list[current_player;main;0,7;8,4;]" ..
            "listring[current_player;main]"  ..
            "listring[current_name;done]"
        )
    elseif (nutra_paste.GAMEMODE == "MCL" or nutra_paste.GAMEMODE == "MCL2" or nutra_paste.GAMEMODE == "MCL5") and mclform ~= nil then
        meta:set_string("formspec",
            "size[9, 10.5]"..
            "label[0.3,0.3;"..minetest.formspec_escape(percentage).."]"..
            "button[0,1; 1.9,1;save;Save]"..
            "button[0,2; 1.9,1;open;" .. open .."]" ..
            "label[2.16, 0.9;Members List (Inventory Access)]"..
            "textarea[2.2,1.3;6,1.8;names;;" .. names  .."]"..
            "list[context;done;0,2.9;9,3;]" ..
            mclform.get_itemslot_bg(0, 2.9, 9, 3)..
            "label[0,5.85;"..minetest.formspec_escape("Inventory").."]"..
--            "list[current_player;main;0,6.5;9,4;]" ..
--            mclform.get_itemslot_bg(0, 6.5, 9, 4)..
		    "list[current_player;main;0,6.5;9,3;9]"..
		    mclform.get_itemslot_bg(0,6.5,9,3)..
		    "list[current_player;main;0,9.74;9,1;]"..
		    mclform.get_itemslot_bg(0,9.74,9,1)..
            "listring[current_player;main]"  ..
            "listring[current_name;done]"
        )
    end
end

nutra_paste.inv = function (placer, pos)
    local meta=minetest.get_meta(pos)
    nutra_paste.inv_update(pos)
    meta:set_string("infotext", "Nutra Paste Machine (" .. placer:get_player_name() .. ")")
end

-- Now we use all this to make our machine
local mod_name = "nutra_paste_"
local extent = ".png"
local grouping = nil
local sounding = nil
if nutra_paste.GAMEMODE == "MCL" or nutra_paste.GAMEMODE == "MCL2" or nutra_paste.GAMEMODE == "MCL5" then
    local mcl_sounds = rawget(_G, "mcl_sounds") or nutra_paste.tools.error("Failed to obtain MCL Sounds")
    grouping = {handy=1}
    sounding = mcl_sounds.node_sound_metal_defaults()
elseif nutra_paste.GAMEMODE == "MTG" then
    local default = rawget(_G, "default") or nutra_paste.tools.error("Failed to obtain MTG Sounds")
    grouping = {crumbly = 3}
    sounding = default.node_sound_metal_defaults()
else
    grouping = {crumbly = 3, handy=1}
end
minetest.register_node("nutra_paste:machine", {
    description = "Nutra Paste Machine",
    _doc_items_long_desc = S("While Nutra Paste tastes horrible and isn't very efficent as food it is freely made."),
    _dock_items_usagehelp = S("Place the machine down and wait till it produces Nutra Paste Meals."),
    _dock_items_hidden=false,
    tiles = {
        mod_name.."block"..extent,
    },
    groups = grouping,
    sounds = sounding,
    paramtype2 = "facedir",
    light_source = 1,
    drop = "nutra_paste:machine",
    on_construct = function(pos)
        local meta = minetest.get_meta(pos)
        meta:set_string("infotext", "Nutra Paste Machine")
        meta:set_string("owner", "")
        meta:set_int("open", 0)
        meta:set_string("names", "")
        meta:set_int("proc", 0)
        local inv = meta:get_inventory()
        if nutra_paste.GAMEMODE == "MTG" then
            inv:set_size("done", 32) -- 4*8
        elseif nutra_paste.GAMEMODE == "MCL" or nutra_paste.GAMEMODE == "MCL2" or nutra_paste.GAMEMODE == "MCL5" then
            inv:set_size("done", 27) -- 3*9
        end
        minetest.get_node_timer(pos):start(1)
    end,
    after_place_node = function(pos, placer, itemstack)
        local meta = minetest.get_meta(pos)
        meta:set_string("owner", (placer:get_player_name() or ""))
        local inv = meta:get_inventory()
        nutra_paste.inv(placer,pos)
    end,
    allow_metadata_inventory_put = function(pos, listname, index, stack, player)
        local meta=minetest.get_meta(pos)
        local open=meta:get_int("open")
        local name=player:get_player_name()
        local owner=meta:get_string("owner")
        if name==owner then return stack:get_count() end
        if open==2 and listname=="done" then return stack:get_count() end
        if open==1 and listname=="done" then
            local names=meta:get_string("names")
            local txt=names.split(names,"\n")
            for i in pairs(txt) do
                if name==txt[i] then
                    return stack:get_count()
                end
            end
        end
        return 0
    end,
    allow_metadata_inventory_take = function(pos, listname, index, stack, player)
        local meta=minetest.get_meta(pos)
        local open=meta:get_int("open")
        local name=player:get_player_name()
        local owner=meta:get_string("owner")
        if name==owner then return stack:get_count() end
        if open==2 and listname=="done" then return stack:get_count() end
        if open==1 and listname=="done" then
            local names=meta:get_string("names")
            local txt=names.split(names,"\n")
            for i in pairs(txt) do
                if name==txt[i] then
                    return stack:get_count()
                end
            end
        end
        return 0
    end,
    can_dig = function(pos, player)
        local meta=minetest.get_meta(pos)
        local owner=meta:get_string("owner")
        local inv=meta:get_inventory()
        if (player:get_player_name()==owner) and owner ~= "" then
            minetest.get_node_timer(pos):stop()
        end
        -- Only check it's the owner
        return (player:get_player_name()==owner and
                owner~="")
    end,
    allow_metadata_inventory_move = function(pos, from_list, from_index, to_list, to_index, count, player)
        local meta = minetest.get_meta(pos)
        if meta:get_int("open")==0 and player:get_player_name()~=meta:get_string("owner") then
            return 0
        end
        return count
        --[[if (from_list=="gen" and to_list=="gen" and player:get_player_name()==meta:get_string("owner")) then
            return count
        end]]
        -- return 0
    end,
    on_receive_fields = function(pos, formname, fields, sender)
        local meta = minetest.get_meta(pos)
        if sender:get_player_name() ~= meta:get_string("owner") then
            return false
        end

        if fields.save then
            meta:set_string("names", fields.names)
            nutra_paste.inv(sender,pos)
        end

        if fields.open then
            local open=meta:get_int("open")
            open=open+1
            if open>2 then open=0 end
            meta:set_int("open",open)
            nutra_paste.inv(sender,pos)
        end
    end,
    on_timer = function(pos, elapsed)
        return nutra_paste.update(pos, elapsed)
    end
})

if nutra_paste.settings.craft then
    minetest.register_craft({
        output = "nutra_paste:machine",
        recipe = {
            {"", "group:wood", ""},
            {"group:wood", "group:sapling", "group:wood"},
            {"", "group:wood", ""},
        }
    })
end

-- Allow a "recycle" feature
minetest.register_craft({
    type = "fuel",
    recipe = "nutra_paste:machine",
    burntime = 60
})
