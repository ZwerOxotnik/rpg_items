if script.active_mods["gvv"] then require("__gvv__.gvv")() end

require("ITEMS")
require("rpg_framework")


local random = math.random
local floor = math.floor
local max = math.max
local min = math.min
local RED_COLOR = {r=1,g=0,b=0}


remote.add_interface("rpg-items", {
	get = function(field) return storage[field] end,
	set = function(field, value)
		storage[field] = value
	end,
	add_gold = function(force, value)
		local force_data = storage.forces[force.name]
		if not force_data then return false end
		force_data.money = max(0, force_data.money + value)
		return true
	end,
	get_gold = function(force)
		local force_data = storage.forces[force.name]
		if not force_data then return false end
		return force_data.money
	end,
	set_item = function(item, tbl) -- TODO: change
		storage.items[item] = tbl
		if storage.items[item].func then
			storage.items[item].func = load(storage.items[item].func)
			if not type(storage.items[item].func) == "function" then
				error("couldn't load function")
			end
		end
	end
})


local function refresh_forces()
	-- Init force data
	for _, force in pairs(game.forces) do
		local force_name = force.name
		if force.players then
			if not storage.forces[force_name] then
				storage.forces[force_name] = {
					players = {}, color = force, research = {}, money = 16000,
					bonuses = {
						income = 1, crit = 0, critdamage = 0, armor = 0, thorns = 0, regen = 1.5,
						chardamage = 0, chardamage_mult = 1, repair = 0, pctregen = 0, lifesteal = 0,
						pctlifesteal = 0, energy = 0, revive = 0, stun = 0, momentum = 0, immolation = 0
					},
					bonus_talents = 0, giveitem={}, modifiers = {},talent_modifiers = {}, items = {}, item_cooldowns = {}, bonus_slots = 0
				}
			end
		end

		if storage.forces[force_name] then
			storage.forces[force_name].players = force.players
			for _, player in pairs(force.players) do
				create_equipment_gui(player)
				local talents_data = storage.talents[force_name]
				if not talents_data or not talents_data.ready then
					talents_gui(player)
				end
			end
		end
	end

	-- Remove invalid force data
	for force_name in pairs(storage.forces) do
		local force = game.forces[force_name]
		if not (force and force.valid) then
			storage.forces[force_name] = nil
		end
	end
end

script.on_init( function()
	storage.indestructible_characters = storage.indestructible_characters or {}
	make_items()
	storage.all_talents = {
	r={
		["t1"] = {type = "force", modifier = "ammo_damage_modifier", value = 0.02},
		["t2"] = {type = "force", modifier = "ammo_damage_modifier", value = 0.0002, periodical = 0},
		["t3"] = {type = "force", modifier = "gun_speed_modifier", value = 0.03},
		["t4"] = {type = "other", modifier = "crit", value = 0.005},
		["t5"] = {type = "other", modifier = "critdamage", value = 0.015},
		--["t6"] = {type = "other", modifier = "chardamage", value = 2},
		--["t7"] = {type = "force", modifier = "turret_attack_modifier", value = 0.02},
		["t8"] = {type = "other", modifier = "thorns", value = 0.5},
		["t9"] = {type = "other", modifier = "thorns", value = 0.005, periodical = 0},
		["t27"] = {type = "other", modifier = "lifesteal", value = 0.05},
	},
	g={
		["t10"] = {type = "other", modifier = "income", value = 0.05},
		["t11"] = {type = "force", modifier = "character_health_bonus", value = 10},
		["t12"] = {type = "force", modifier = "character_health_bonus", value = 0.1, periodical = 0},
		["t13"] = {type = "other", modifier = "regen", value = 0.3},
		["t14"] = {type = "other", modifier = "regen", value = 0.003, periodical = 0},
		["t15"] = {type = "other", modifier = "armor", value = 1},
		["t16"] = {type = "other", modifier = "armor", value = 0.01, periodical = 0},
		["t17"] = {type = "force", modifier = "character_running_speed_modifier", value = 0.02},
	},
	b={
		["t18"] = {type = "force", modifier = "manual_mining_speed_modifier", value = 0.1},
		["t19"] = {type = "force", modifier = "manual_crafting_speed_modifier", value = 0.05},
		["t20"] = {type = "force", modifier = "character_inventory_slots_bonus", value = 1},
		["t26"] = {type = "force", modifier = "character_reach_distance_bonus", value = 1},
	},
}
	if script.active_mods["m-spell-pack"] then
		storage.use_spellpack = true
		--storage.all_talents.b["t21"] = {type = "other", modifier = "magic_resistance", value = 2}
		--storage.all_talents.b["t22"] = {type = "other", modifier = "magic_resistance", value = 0.06, periodical = 0}
		storage.all_talents.b["t23"] = {type = "spellpack", modifier = "max_mana", value = 2}
		storage.all_talents.b["t24"] = {type = "spellpack", modifier = "max_mana", value = 0.02, periodical = 0}
		storage.all_talents.b["t25"] = {type = "spellpack", modifier = "mana_reg", value = 0.05}
	end
	storage.talent_localizations = {
		["t1"]="+2% Damage",
		["t2"]="+0.2% Damage/hour",
		["t3"]="+3% Attackspeed",
		["t4"]="+0.5% Crit",
		["t5"]="+1.5% Critdamage",
		--["t6"]="+2 Melee Damage",
		--["t7"]="+2% Turret Damage",
		["t8"]="+0.5 Thorns Damage",
		["t9"]="+0.05 Thorns Damage/hour",
		["t10"]="+0.05 Gold/s",
		["t11"]="+10 Health",
		["t12"]="+1 Health/hour",
		["t13"]="+0.3 HP/s",
		["t14"]="+0.03 HP/s/hour",
		["t15"]="+1 Armor",
		["t16"]="+0.1 Armor/hour",
		["t17"]="+2% Running speed",
		["t18"]="+10% Mining Speed",
		["t19"]="+5% Crafting Speed",
		["t20"]="+1 Inventory Slot",
		--["t21"]="+2 Magic resistance",
		--["t22"]="+0.02 Magic resistance/hour",
		["t23"]="+2 Mana",
		["t24"]="+0.2 Mana/hour",
		["t25"]="+0.05 Manareg",
		["t26"]="+1 Reach Distance",
		["t27"]="+0.05% Lifesteal",
	}

	storage.initialized = true
	storage.giveitem_cache = {}
	storage.forces = {}
	storage.repairing = {}
	storage.momentum = {}
	storage.immolation = {}
	--storage.units = {}
	--storage.lobbys = {}
	--storage.eq_gui_clicks = {}
	storage.talents = {}
	refresh_forces()
	-- storage.version = 3
end)

script.on_event(defines.events.on_game_created_from_scenario, function()
	if remote.interfaces["rpgitems_dont_make_market"] then return end

	local surface = game.surfaces[1]
	local pos = surface.find_non_colliding_position("rocket-silo", {x=0,y=0}, 50, 0.5, true)
	if pos then
		local market = surface.create_entity{name = "rpgitems-market", position = pos, force = "player"}
		market.minable = false
	end
end)

script.on_configuration_changed(function()
	storage.indestructible_characters = storage.indestructible_characters or {}
	-- if not storage.version then
		-- storage.version = 1
		-- for _, data in pairs(storage.forces) do
		-- 	if data.bonuses.revive > 0 then
		-- 		data.bonuses.revive = 5
		-- 	end
		-- end
		-- if storage.items["rpgitems_crusader"].effects[6].modifier == "revive" then
		-- 	storage.items["rpgitems_crusader"].effects[6].value = 5
		-- else
		-- 	game.print("Error migrating the crusader buff, please report this issue to the author")
		-- end
		-- if storage.items["rpgitems_crusader_spepa"].effects[7].modifier == "revive" then
		-- 	storage.items["rpgitems_crusader_spepa"].effects[7].value = 5
		-- else
		-- 	game.print("Error migrating the crusader buff, please report this issue to the author")
		-- end
	-- end
	-- if storage.version < 2 then
	-- 	storage.version = 2
	-- 	for _, data in pairs(storage.forces) do
	-- 		data.bonus_talents = 0
	-- 	end
	-- 	if storage.items["rpgitems_amnesia_book"] then
	-- 		storage.items["rpgitems_amnesia_book"].description = "Allows you to reset your talents\nGrants +4 talent points (RGBW)\nChanged per hour bonuses will start from 0!"
	-- 		storage.items["rpgitems_amnesia_book"].price = 35000
	-- 	end
	-- end
	-- if storage.version <3 then
	-- 	storage.version = 3
	-- 	if remote.interfaces["spell-pack"] then
	-- 		for force_name, force_data in pairs(storage.forces) do
	-- 			for mod_id, modifier in pairs(force_data.modifiers) do
	-- 				if modifier.type == "spellpack" then
	-- 					local mult = 1
	-- 					if modifier.periodical then
	-- 						mult = modifier.periodical
	-- 					end
	-- 					local players =remote.call("spell-pack","get","players")
	-- 					for _, player in pairs(storage.forces[force_name].players) do
	-- 						local new_mod = players[player.index][modifier.modifier]- modifier.value*mult
	-- 						players[player.index][modifier.modifier] = new_mod
	-- 					end
	-- 					remote.call("spell-pack","set","players",players)

	-- 					if tonumber(script.active_mods["m-spell-pack"]:sub(-2)) >= 18 then
	-- 						remote.call("spell-pack", "modforce", game.forces[force_name],modifier.modifier, modifier.value*mult)
	-- 					else
	-- 						force_data.modifiers[mod_id] = nil
	-- 						game.print("Please update Spell-Pack")
	-- 					end
	-- 				end
	-- 			end
	-- 			for mod_id, modifier in pairs(force_data.talent_modifiers) do
	-- 				if modifier.type == "spellpack" then
	-- 					local mult = 1
	-- 					if modifier.periodical then
	-- 						mult = modifier.periodical
	-- 					end
	-- 					local players =remote.call("spell-pack","get","players")
	-- 					for _, player in pairs(storage.forces[force_name].players) do
	-- 						local new_mod = players[player.index][modifier.modifier]- modifier.value*mult
	-- 						players[player.index][modifier.modifier] = new_mod
	-- 					end
	-- 					remote.call("spell-pack","set","players",players)

	-- 					if tonumber(script.active_mods["m-spell-pack"]:sub(-2)) >= 18 then
	-- 						remote.call("spell-pack", "modforce", game.forces[force_name],modifier.modifier, modifier.value*mult)
	-- 					else
	-- 						force_data.modifiers[mod_id] = nil
	-- 						game.print("Please update Spell-Pack")
	-- 					end
	-- 				end
	-- 			end
	-- 		end
	-- 	end
		-- for _, data in pairs(storage.items) do
		-- 	if data.requires == "m-spell-pack" or data.conflicts == "m-spell-pack" then
		-- 		data.andversion = 18
		-- 	end
		-- end
	-- end
	if script.active_mods["m-spell-pack"] and tonumber(script.active_mods["m-spell-pack"]:sub(-2)) >= 18 and not storage.use_spellpack then
		storage.use_spellpack = true
		storage.all_talents.b["t23"] = {type = "spellpack", modifier = "max_mana", value = 2}
		storage.all_talents.b["t24"] = {type = "spellpack", modifier = "max_mana", value = 0.02, periodical = 0}
		storage.all_talents.b["t25"] = {type = "spellpack", modifier = "mana_reg", value = 0.05}
		for i, data in pairs(storage.forces) do
			for id, item in pairs(data.items) do
				if storage.items[item.item].conflicts and storage.items[item.item].conflicts == "m-spell-pack" then
					data.money = data.money + get_sell_price(item.item)*item.count
					data.items[id] = nil
				end
			end
			update_items(game.forces[i])
		end
		game.print("Added spellpack talents and items :)")
	end
	if (script.active_mods["m-spell-pack"] and tonumber(script.active_mods["m-spell-pack"]:sub(-2)) < 18) and storage.use_spellpack then
		storage.use_spellpack = false
		storage.all_talents.b["t23"] = nil
		storage.all_talents.b["t24"] = nil
		storage.all_talents.b["t25"] = nil
		for _, data in pairs(storage.talents) do
			if data.b["t23"] then
				data.b["t23"] = nil
			end
			if data.b["t24"] then
				data.b["t24"] = nil
			end
			if data.b["t25"] then
				data.b["t25"] = nil
			end
		end
		for i, force_data in pairs(storage.forces) do
			for id, item in pairs(force_data.items) do
				local item_data = storage.items[item.item]
				if item_data.requires and item_data.requires == "m-spell-pack" then
					force_data.money = force_data.money + get_sell_price(item.item)*item.count
					force_data.items[id] = nil
				end
			end
			for id, mod in pairs(force_data.talent_modifiers) do
				if mod.type == "spellpack" then
					force_data.talent_modifiers[id] = nil
				end
			end
			update_items(game.forces[i])
		end
		game.print("Removed spellpack talents and items :(")
		if script.active_mods["m-spell-pack"] then
			game.print("Please update Spell-Pack")
		end
	end

	refresh_forces()
end)

--function on_player_created(player)
--
--	refresh_forces()
--end

script.on_event({defines.events.on_player_created,defines.events.on_forces_merged,defines.events.on_player_changed_force}, refresh_forces)
--script.on_event(defines.events.on_console_chat, function(event)
--	if event.message == "gold" then
--		storage.forces[game.get_player(event.player_index).force.name].money = storage.forces[game.get_player(event.player_index).force.name].money+198000
--		game.print(storage.forces[game.get_player(event.player_index).force.name].bonuses.critdamage)
--	end
--end)

--	create_equipment_gui(player)
--	apply_talents(player)

script.on_event(defines.events.on_technology_effects_reset, function (event)
	local force = event.force
	local force_name = force.name
	if not storage.forces or not storage.forces[force_name] then return end
	for _, modifier in pairs(storage.forces[force_name].modifiers) do
		local mult = 1
		if modifier.periodical then
			mult = modifier.periodical
		end
		if modifier.type == "force" then
			add_modifier(force, modifier, mult)
		end
	end
	for _, modifier in pairs(storage.forces[force_name].talent_modifiers) do
		local mult = 1
		if modifier.periodical then
			mult = modifier.periodical
		end
		if modifier.type == "force" then
			add_modifier(force, modifier, mult)
		end
	end
end)

function remove_stickers(player)
	if player.character and player.character.valid then
		if not player.character.stickers then
			return
		end
		for _, sticker in pairs(player.character.stickers) do
			if sticker.name:sub(1,23) == "rpgitems-speed-sticker-" then
				sticker.destroy()
			end
		end
	end
end

-- TODO: optimize!
script.on_nth_tick(6, function(event)
	if not storage.forces then return end

	for _, data in pairs(storage.forces) do
		local bonuses = data.bonuses
		for _, player in pairs(data.players) do
			if player.valid then
				local character = player.character
				if character and character.valid then
					character.health = character.health + bonuses.regen/10
					if bonuses.pctregen > 0 then
						character.health = character.health + (character.max_health + character.character_health_bonus + character.force.character_health_bonus )/1000*bonuses.pctregen
						--game.print((character.max_health + character.character_health_bonus + character.force.character_health_bonus )/1000*bonuses.pctregen*10)
					end
				end
			end
		end
	end

	for _, player in pairs(game.connected_players) do
		if player.character and player.character.valid and storage.forces[player.force.name] and storage.forces[player.force.name].bonuses.energy then
			local target_entity = nil
			local vehicle = player.vehicle
			if vehicle and vehicle.grid and vehicle.grid.battery_capacity >0 and vehicle.grid.available_in_batteries < vehicle.grid.battery_capacity*0.98 then
				target_entity = vehicle
			elseif player.character.grid then
				target_entity = player.character
			end
			if target_entity then
				local batteries = 0
				for _, eq in pairs(target_entity.grid.equipment) do
					if eq.type == "battery-equipment" and eq.energy < eq.max_energy then
						batteries=batteries+1
					end
				end
				--game.print(i)
				local remaining_electricity = storage.forces[player.force.name].bonuses.energy*10^2 -- 1/10 KJ
				for _=1, 2 do
					local used_electricity = 0
					local temp_batteries = 0
					for _, eq in pairs(target_entity.grid.equipment) do
						if eq.type == "battery-equipment" and eq.energy < eq.max_energy then
							local charging = min(remaining_electricity/batteries, eq.max_energy-eq.energy)
							eq.energy = eq.energy + charging
							used_electricity = used_electricity + charging
							if eq.energy < eq.max_energy then
								temp_batteries = temp_batteries + 1
							end
						end
					end
					batteries = temp_batteries
					remaining_electricity = remaining_electricity - used_electricity
				end
			end
		end

		local player_index = player.index
		local force_name = player.force.name
		local force_data = storage.forces[force_name]
		local player_momentum = storage.momentum[player_index]
		local character = player.character
		if force_data and force_data.bonuses.momentum > 0 and character and character.valid then
			local position_x = player.position.x
			local position_y = player.position.y
			if not player_momentum then
				storage.momentum[player_index] = {
					position_x = position_x, position_y = position_y, momentum = 0
				}
				player_momentum = storage.momentum[player_index]
			end

			if position_x == player_momentum.position_x and position_y == player_momentum.position_y then
				remove_stickers(player)
				player_momentum.momentum = 0
			elseif event.tick % 60 == 0 and player_momentum.momentum < 5 then
				player_momentum.momentum = player_momentum.momentum + 1
				character.surface.create_entity{
					name = "rpgitems-speed-sticker-" .. player_momentum.momentum,
					position = player.position, target = character
				}
			end
			player_momentum.position_x = position_x
			player_momentum.position_y = position_y
		elseif player_momentum and player_momentum.momentum > 0 then
			remove_stickers(player)
			player_momentum.momentum = 0
		end
	end
end)

--TODO: refactor/remove
script.on_nth_tick(61, function()
	for _, player in pairs(game.connected_players) do
		local last = nil
		for _, g in pairs(player.gui.left.children) do
			last = g.name
		end
		if last ~= "rpgitems_item_gui" then
			create_equipment_gui(player)
		end
	end
end)

function disable_immolation(player)
	storage.immolation[player.index] = nil
	if player.character and player.character.valid and player.character.stickers then
		for _, sticker in pairs(player.character.stickers) do
			if sticker.name == "rpgitems-flamecloak-sticker" then
				sticker.destroy()
			end
		end
	end
end

local _entity_search_filter = {type = {"unit", "character"}, position = {}, radius = 6}
script.on_nth_tick(25, function()
	local immolations = storage.immolation
	local mod_forces_data = storage.forces
	for _, player in pairs(game.connected_players) do
		if immolations[player.index] then
			local player_force = player.force
			local player_force_name = player_force.name
			local immolation_bonus = mod_forces_data[player_force_name].bonuses.immolation -- TODO: Refactor?
			local character = player.character
			if immolation_bonus > 0 and character and character.valid then
				_entity_search_filter.position = player.position
				local enemies = player.surface.find_entities_filtered(_entity_search_filter)
				local damage_mult = player_force.get_ammo_damage_modifier("flamethrower") + 1
				for i=1, #enemies do
					local enemy = enemies[i]
					if enemy.valid then
						local enemy_force = enemy.force
						if enemy_force ~= player_force and not enemy_force.get_cease_fire(player_force) and not enemy_force.get_friend(player_force) then
							enemy.damage(immolation_bonus*25/60 *damage_mult, player_force_name, "fire")
						end
					end
				end
			else
				disable_immolation(player)
			end
		end
	end
end)

-- TODO: Refactor
local _stack_data = {name='', count=1}
script.on_nth_tick(60, function()
	for force_index, force_data in pairs(storage.forces) do
		--income
		--local player = game.players[id]
		force_data.money = force_data.money + force_data.bonuses.income
		local update = false
		local item_cooldowns= force_data.item_cooldowns
		for field, cd in pairs(item_cooldowns) do
			cd = cd - 1
			if cd <= 0 then
				cd = nil
			end
			item_cooldowns[field] = cd
			update = true
		end

		-- TODO: Refactor
		local giveitem_cache = storage.giveitem_cache
		for item, persec in pairs(force_data.giveitem) do
			for _, player in pairs(force_data.players) do
				local player_index = player.index
				local cashed_item_player_data = giveitem_cache[player_index]
				if cashed_item_player_data == nil then
					local data = {}
					giveitem_cache[player_index] = data
					cashed_item_player_data = data
				end
				cashed_item_player_data[item] = (cashed_item_player_data[item] or 0) + persec
			end
		end

		local force = game.forces[force_index]
		local money_caption = floor(force_data.money).."[img=rpgitems-coin]"
		for _, player in pairs(force_data.players) do
			if player.valid and player.connected then
				local rpgitems_item_gui = player.gui.left.rpgitems_item_gui
				if rpgitems_item_gui and rpgitems_item_gui.valid then
					rpgitems_item_gui.money.caption = money_caption
					--cooldowns
					if update then
						create_item_sprites(player)
					end
					--giveitem
					local cached_given_items = storage.giveitem_cache[player.index]
					local character = player.character
					local inventory = player.get_main_inventory()
					local player_insert = player.insert
					if inventory and character and character.valid and cached_given_items then
						local get_item_count = inventory.get_item_count
						for item, cached in pairs(cached_given_items) do
							local in_inventory = get_item_count(item)
							if cached >= 1 and in_inventory < 200 then
								_stack_data.name = item
								_stack_data.count = min(200-in_inventory,floor(cached))
								local inserted = player_insert(_stack_data)
								cached_given_items[item] = cached_given_items[item] - inserted
							end
						end
					end
				end
			end
		end
	end

	local forces = storage.forces
	local repairing_data = storage.repairing
	for id, entity in pairs(repairing_data) do
		if not entity or not entity.valid then
			repairing_data[id] = nil
		else
			local force_name = entity.force.name
			local force_data = forces[force_name]
			local repair_bonus = force_data.bonuses.repair
			if not force_data or repair_bonus == 0 or entity.get_health_ratio() == 1 then
				repairing_data[id] = nil
			else
				entity.health = entity.health + entity.max_health / 100 * repair_bonus
			end
		end
	end
end)

script.on_nth_tick(150, function(event)
	local tick = game.tick
	local indestructible_characters = storage.indestructible_characters
	for character, _tick in pairs(indestructible_characters) do
		if tick >= _tick then
			if character and character.valid then
				character.destructible = true
			end
			indestructible_characters[character] = nil
		end
	end
end)

script.on_event(defines.events.on_player_main_inventory_changed, function(event)
	if event.tick%60 == 0 then return end -- TODO: check

	local player_index = event.player_index
	local player = game.get_player(player_index)
	local player_items_cache = storage.giveitem_cache[player_index]
	if not (player.character and player.character.valid and player_items_cache) then return end

	local inventory = player.get_main_inventory()
	for item, cached in pairs(player_items_cache) do
		local in_inventory = inventory.get_item_count(item)
		if cached >= 1 and in_inventory < 200 then
			local inserted = player.insert{name = item, count = min(200-in_inventory,floor(cached))}
			player_items_cache[item] = player_items_cache[item] - inserted
		end
	end
end)

function dbg(str)
	if str == nil then
		str = "nil"
	elseif type(str) ~= "string" and type(str) ~= "number" then
		if type(str)=="boolean" then
			if str == true then
				str = "true"
			else
				str = "false"
			end
		else
			str=type(str)
		end
	end
	game.players[1].print(game.tick.. " "..str)
end

function distance(pos1,pos2)
	local xdiff = pos1.x - pos2.x
	local ydiff = pos1.y - pos2.y
	return (xdiff * xdiff + ydiff * ydiff)^0.5
end

function _print(str)
	for _, player in pairs(game.connected_players) do
		if player.valid and player.admin then
			player.print(str)
		end
	end
end

script.on_event(defines.events.on_gui_opened, function(event)
	local entity = event.entity
	if not (entity and entity.valid) then return end
	if entity.name =="rpgitems-market" then
		local player = game.get_player(event.player_index)
		open_market(player)
		unlock_items(player)
	end
	--if event.entity.name =="rpgitems-item-market" then
	--	local player = game.get_player(event.player_index)
	--	local gui = player.gui.center.add{type="frame", name = "rpgitems_item_market", direction = "vertical"}
	--	itemselector_gui(gui, player)
	--	player.opened = gui
	--end
end)
--script.on_event(defines.events.script_raised_built, function()
--
--end)
--script.on_event(defines.events.on_trigger_created_entity, function(event)
--	if not event.entity then return end
--end)
script.on_event(defines.events.on_gui_closed, function(event)
	if event.element and event.element.name =="rpgitems_market" then
		event.element.destroy()
		lock_items(game.get_player(event.player_index))
	--elseif event.element and event.element.name == "rpgitems_item_market" then
	--	event.element.destroy()
	end
end)


script.on_event(defines.events.on_entity_died, function(event)
	local force = event.force
	local entity = event.entity
	if not (force and entity and entity.valid) then return end
	if entity.force == force then return end
	local force_name = force.name
	local force_data = storage.forces[force_name]
	if not force_data then return end

	--local player_id = tonumber(force.name:sub(8))
	force_data.money = force_data.money + 1

	-- player.create_local_flying_text{
	-- 	position = entity.position,
	-- 	time_to_live = 120,
	-- 	text = "+1",
	--	color = {r=0,g=0.7,b=0}
	-- }
	local caption = floor(force_data.money).."[img=rpgitems-coin]"
	for _, player in pairs(force_data.players) do
		local items_gui = player.gui.left.rpgitems_item_gui
		if items_gui and items_gui.valid then
			items_gui.money.caption = caption
		end
	end
end, {
	{filter = "type", type = "tree", invert = true, mode = "and"},
	{filter = "type", type = "simple-entity", invert = true, mode = "and"},
})


script.on_event(defines.events.on_player_died, function(event)
	local player = game.get_player(event.player_index)
	if not (player and player.valid) then return end
	if player.gui.center.rpgitems_market then player.gui.center.rpgitems_market.destroy() end
end)

function apply_armor(event, armor)
	local grid = event.entity.grid
	local bonus_healing = 0
	if grid and grid.max_shield > 0 then
		local actual_damage = event.original_damage_amount
		local armor_inv = event.entity.get_inventory(defines.inventory.character_armor)
		if armor_inv[1].valid_for_read and armor_inv[1].prototype.resistances then
			local event_damage_type = event.damage_type.name
			if armor_inv[1].prototype.resistances[event_damage_type] then
				actual_damage = max(0, (event.original_damage_amount - armor_inv[1].prototype.resistances[event_damage_type].decrease) * (1-armor_inv[1].prototype.resistances[event_damage_type].percent))
			end
		end
		local shield_healing = (actual_damage - event.final_damage_amount) *armor
		bonus_healing = min(event.final_damage_amount, shield_healing)
		shield_healing = shield_healing - bonus_healing
		shield_healing = min(shield_healing,grid.max_shield - grid.shield)

		local missing_shield = grid.max_shield - grid.shield
		if missing_shield > 0 then
			for a, eq in pairs(grid.equipment) do
				if eq.type == "energy-shield-equipment" then
					eq.shield = eq.shield + (eq.max_shield - eq.shield)/missing_shield * shield_healing
				end
			end
		end
	--	event.entity.health = event.entity.health + healing - shield_healing
	--else
	--	event.entity.health = event.entity.health + actual_damage*armor
	end
	event.entity.health = event.entity.health + event.final_damage_amount*armor + bonus_healing
end

-- TODO: optimize
script.on_event(defines.events.on_entity_damaged, function(event)
	local cause = event.cause
	local entity = event.entity

	if entity then
		local force = entity.force
		local force_data = storage.forces[force.name]
		if force_data == nil then return end

		local force_bonuses = force_data.bonuses
		if entity.type == "character" then
			local damage = force_bonuses.thorns
			if cause and damage > 0 and cause.valid and cause.health then
				cause.damage(damage, force, event.damage_type.name)
			end
			-- local player = entity.player
			--if event.damage_type.name:sub(1,4)=="osp_" then
			--	local mres = storage.forces[player.force.name].bonuses.magic_resistance /(storage.forces[player.force.name].bonuses.magic_resistance+100)
			--	entity.health = entity.health + event.final_damage_amount*mres
			--else
				local armor = force_bonuses.armor
				apply_armor(event, armor / (armor+100))
			--end
		elseif force_data and force_bonuses.repair > 0 and entity.name ~= "RITEG-1" then
			storage.repairing[entity.unit_number] = entity
		end
	end

	if not (cause and cause.valid) then return end
	if not entity.valid then return end
	local force_data = storage.forces[cause.force.name]
	if force_data == nil then return end


	local force_bonuses = force_data.bonuses
	local extradamage = 0
	--if event.damage_type.name == "chardamage" then
	--	local mult = storage.forces[force].bonuses.chardamage_mult+cause.force.get_turret_attack_modifier("character")
	--	extradamage = storage.forces[force].bonuses.chardamage*mult + (mult-1)*8
	--	extradamage = entity.damage(extradamage, cause.force, "physical")
	--end
	if random() < force_bonuses.stun * (cause.type == "character" and 6 or 2) then
		--game.print(storage.forces[force].bonuses.stun * (cause.type == "character" and 2 or 1))
		if entity.type == "unit" or entity.type == "character" then
			entity.surface.create_entity{
				name="rpgitems-stun-sticker", position=entity.position, target=entity
			}
		end
	end

	if cause.type == "character" then
		if force_bonuses.pctlifesteal > 0 then
			cause.health = cause.health + (event.final_damage_amount + extradamage)/100*force_bonuses.pctlifesteal
		end
		if force_bonuses.lifesteal > 0 then
			cause.health = cause.health + force_bonuses.lifesteal
		end
	end

	if entity.has_flag("breaths-air") and random() < force_bonuses.crit then
		local pos =  entity.position
		local surface = entity.surface
		--local player_mult = 1
		--if event.
		extradamage = entity.damage((event.original_damage_amount+extradamage)*(1+force_bonuses.critdamage), cause.force, event.damage_type.name)
		local dmg = extradamage + event.final_damage_amount

		rendering.draw_text({
			text = tostring(floor(dmg)),
			time_to_live = 120,
			surface = surface,
			color = RED_COLOR,
			target = pos
		})
	end
end, {
	{filter = "final-damage-amount", comparison = ">", value = 0, mode = "and"},
	{filter = "final-health", comparison = ">", value = 0, mode = "and"},
	{filter = "damage-type", type = "fire", invert = true, mode = "and"},
	{filter = "damage-type", type = "acid", invert = true, mode = "and"},
})

script.on_event(defines.events.on_pre_player_died, function(event)
	local player = game.get_player(event.player_index)
	local force_name = player.force.name
	local force_data = storage.forces[force_name]
	if not (force_data and force_data.bonuses.revive > 0) then return end

	local item_cooldowns = force_data.item_cooldowns
	if not item_cooldowns["rpgitems_crusader"] and not item_cooldowns["rpgitems_crusader_spepa"] then
		local level = min(5, force_data.bonuses.revive)
		local cdr = 0
		if remote.interfaces["spell-pack"] then
			local players = remote.call("spell-pack","get","players")
			cdr = players[event.player_index].cdr / 2
		end
		local cooldown = 300 * (1-cdr)
		item_cooldowns["rpgitems_crusader"] = cooldown
		item_cooldowns["rpgitems_crusader_spepa"] = cooldown

		local character = player.character
		if character and character.valid then
			character.health = 1
			character.destructible = false
			character.surface.create_entity{name = "rpgitems-halo-sticker-"..level, position= player.position, target = character}
			storage.indestructible_characters[character] = event.tick+level*60
		end
	end
end)
