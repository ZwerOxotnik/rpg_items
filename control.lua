require("ITEMS")
require("rpg_framework")

remote.add_interface("rpg-items", {
		get = function(field) return global[field] end,
		set = function(field, value) 
			global[field] = value 
		end,
		add_gold = function(force, value)
			if not global.forces[force.name] then return false end
			global.forces[force.name].money = math.max(0,global.forces[force.name].money + value)
			return true
		end,
		get_gold = function(force)
			if not global.forces[force.name] then return false end
			return global.forces[force.name].money
		end,
		set_item = function(item, tbl)
			global.items[item] = tbl
			if global.items[item].func then
				global.items[item].func = load(global.items[item].func)
				if not type(global.items[item].func) == "function" then
					error("couldn't load function")
				end
			end
		end
	  })
	  
function refresh_forces()
	for _, force in pairs(game.forces) do
		if force.players then
			if not global.forces[force.name] then
				global.forces[force.name] = {players = {}, color = force, research = {}, money = 16000, bonuses = {income = 1, crit = 0, critdamage = 0, armor = 0, thorns = 0, regen = 1.5, chardamage = 0, chardamage_mult = 1, repair = 0, pctregen = 0, lifesteal = 0, pctlifesteal = 0, energy = 0, revive = 0, stun = 0, momentum = 0,immolation = 0}, bonus_talents = 0, giveitem={}, modifiers = {},talent_modifiers = {}, items = {}, item_cooldowns = {}, bonus_slots = 0}
			end
		end
		
		if global.forces[force.name] then
			global.forces[force.name].players = force.players
			for _, player in pairs(global.forces[force.name].players) do
				create_equipment_gui(player)
				if not global.talents[player.force.name] or not global.talents[player.force.name].ready then
					talents_gui(player)
				end
			end
		end
	end
end

script.on_init( function()
	global.on_tick = {}
	make_items()
	global.all_talents = {
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
	if game.active_mods["spell-pack"] then
		global.use_spellpack = true
		--global.all_talents.b["t21"] = {type = "other", modifier = "magic_resistance", value = 2}
		--global.all_talents.b["t22"] = {type = "other", modifier = "magic_resistance", value = 0.06, periodical = 0}
		global.all_talents.b["t23"] = {type = "spellpack", modifier = "max_mana", value = 2}
		global.all_talents.b["t24"] = {type = "spellpack", modifier = "max_mana", value = 0.02, periodical = 0}
		global.all_talents.b["t25"] = {type = "spellpack", modifier = "mana_reg", value = 0.05}
	end
	global.talent_localizations = {
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

	global.initialized = true
	global.giveitem_cache = {}
	global.forces = {}
	global.repairing = {}
	global.momentum = {}
	global.immolation = {}
	--global.units = {}
	--global.lobbys = {}
	--global.eq_gui_clicks = {}
	global.talents = {}
	refresh_forces()
	if game.tick < 10 and not remote.interfaces["rpgitems_dont_make_market"] then
		if not global.on_tick[game.tick+2] then
			global.on_tick[game.tick+2] = {}
		end
		table.insert(global.on_tick[game.tick+2], {
			func = function(vars)
				local surface = game.surfaces[1]
				local pos = surface.find_non_colliding_position("rocket-silo", {x=0,y=0}, 50, 0.5, true)
				if pos then
					local market = surface.create_entity{name = "rpgitems-market", position = pos, force = "player"}
					market.minable = false
				end
			end,
			vars = {}
		})
	end
	global.version = 3
end)

script.on_configuration_changed(function()
	if not global.version then
		global.version = 1
		for _, data in pairs(global.forces) do
			if data.bonuses.revive > 0 then
				data.bonuses.revive = 5
			end
		end
		if global.items["rpgitems_crusader"].effects[6].modifier == "revive" then
			global.items["rpgitems_crusader"].effects[6].value = 5
		else
			game.print("Error migrating the crusader buff, please report this issue to the author")
		end
		if global.items["rpgitems_crusader_spepa"].effects[7].modifier == "revive" then
			global.items["rpgitems_crusader_spepa"].effects[7].value = 5
		else
			game.print("Error migrating the crusader buff, please report this issue to the author")
		end
	end
	if global.version < 2 then
		global.version = 2
		for _, data in pairs(global.forces) do
			data.bonus_talents = 0
		end
		if global.items["rpgitems_amnesia_book"] then
			global.items["rpgitems_amnesia_book"].func = function(player)
				global.talents[player.force.name].ready = nil
				global.forces[player.force.name].bonus_talents = global.forces[player.force.name].bonus_talents +1
				for _, p in pairs(global.forces[player.force.name].players) do
					talents_gui(p)
				end
			end
			global.items["rpgitems_amnesia_book"].description = "Allows you to reset your talents\nGrants +4 talent points (RGBW)\nChanged per hour bonuses will start from 0!"
			global.items["rpgitems_amnesia_book"].price = 35000
		end
	end
	if global.version <3 then
		global.version = 3
		if remote.interfaces["spell-pack"] then
			for force_name, force_data in pairs(global.forces) do
				for mod_id, modifier in pairs(force_data.modifiers) do
					if modifier.type == "spellpack" then
						local mult = 1
						if modifier.periodical then
							mult = modifier.periodical
						end
						local players =remote.call("spell-pack","get","players")
						for _, player in pairs(global.forces[force_name].players) do
							local new_mod = players[player.index][modifier.modifier]- modifier.value*mult
							players[player.index][modifier.modifier] = new_mod
						end
						remote.call("spell-pack","set","players",players)
						
						if tonumber(game.active_mods["spell-pack"]:sub(-2)) >= 18 then
							remote.call("spell-pack", "modforce", game.forces[force_name],modifier.modifier, modifier.value*mult)
						else
							force_data.modifiers[mod_id] = nil
							game.print("Please update Spell-Pack")
						end
					end
				end
				for mod_id, modifier in pairs(force_data.talent_modifiers) do
					if modifier.type == "spellpack" then
						local mult = 1
						if modifier.periodical then
							mult = modifier.periodical
						end
						local players =remote.call("spell-pack","get","players")
						for _, player in pairs(global.forces[force_name].players) do
							local new_mod = players[player.index][modifier.modifier]- modifier.value*mult
							players[player.index][modifier.modifier] = new_mod
						end
						remote.call("spell-pack","set","players",players)
						
						if tonumber(game.active_mods["spell-pack"]:sub(-2)) >= 18 then
							remote.call("spell-pack", "modforce", game.forces[force_name],modifier.modifier, modifier.value*mult)
						else
							force_data.modifiers[mod_id] = nil
							game.print("Please update Spell-Pack")
						end
					end
				end
			end
		end
		for _, data in pairs(global.items) do
			if data.requires == "spell-pack" or data.conflicts == "spell-pack" then
				data.andversion = 18
			end
		end
	end
	if game.active_mods["spell-pack"] and tonumber(game.active_mods["spell-pack"]:sub(-2)) >= 18 and not global.use_spellpack then
		global.use_spellpack = true
		global.all_talents.b["t23"] = {type = "spellpack", modifier = "max_mana", value = 2}
		global.all_talents.b["t24"] = {type = "spellpack", modifier = "max_mana", value = 0.02, periodical = 0}
		global.all_talents.b["t25"] = {type = "spellpack", modifier = "mana_reg", value = 0.05}
		for i, data in pairs(global.forces) do
			for id, item in pairs(data.items) do
				if global.items[item.item].conflicts and global.items[item.item].conflicts == "spell-pack" then
					data.money = data.money + get_sell_price(item.item)*item.count
					data.items[id] = nil
				end
			end
			update_items(game.forces[i])
		end
		game.print("Added spellpack talents and items :)")
	end
	if (not game.active_mods["spell-pack"] or tonumber(game.active_mods["spell-pack"]:sub(-2)) < 18) and global.use_spellpack then
		global.use_spellpack = false
		global.all_talents.b["t23"] = nil
		global.all_talents.b["t24"] = nil
		global.all_talents.b["t25"] = nil
		for i, data in pairs(global.talents) do
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
		for i, data in pairs(global.forces) do
			for id, item in pairs(data.items) do
				if global.items[item.item].requires and global.items[item.item].requires == "spell-pack" then
					data.money = data.money + get_sell_price(item.item)*item.count
					data.items[id] = nil
				end
			end
			for id, mod in pairs(data.talent_modifiers) do
				if mod.type == "spellpack" then
					data.talent_modifiers[id] = nil
				end
			end
			update_items(game.forces[i])
		end
		game.print("Removed spellpack talents and items :(")
		if game.active_mods["spell-pack"] then
			game.print("Please update Spell-Pack")
		end
	end

end)

--function on_player_created(player)
--	
--	refresh_forces()
--end
--
--script.on_event(defines.events.on_player_created, function(event)
--	if not global.on_tick[event.tick + 1] then global.on_tick[event.tick + 1] = {} end
--	local player = game.players[event.player_index]
--	table.insert(global.on_tick[event.tick + 1], function () on_player_created(player) end)
--
--end)
--
script.on_event({defines.events.on_player_created,defines.events.on_forces_merged,defines.events.on_player_changed_force} , function(event)
	refresh_forces()
end)
--script.on_event(defines.events.on_console_chat, function(event)
--	if event.message == "gold" then
--		global.forces[game.players[event.player_index].force.name].money = global.forces[game.players[event.player_index].force.name].money+198000
--		game.print(global.forces[game.players[event.player_index].force.name].bonuses.critdamage)
--	end
--end)

--	create_equipment_gui(player)
--	apply_talents(player)

script.on_event(defines.events.on_technology_effects_reset, function (event)
	local force = event.force
	local force_name = force.name
	if not global.forces or not global.forces[force_name] then return end
	for _, modifier in pairs(global.forces[force_name].modifiers) do
		local mult = 1
		if modifier.periodical then
			mult = modifier.periodical
		end
		if modifier.type == "force" then
			add_modifier(force, modifier, mult)
		end
	end
	for _, modifier in pairs(global.forces[force_name].talent_modifiers) do
		local mult = 1
		if modifier.periodical then
			mult = modifier.periodical
		end
		if modifier.type == "force" then
			add_modifier(force, modifier, mult)
		end
	end
end)



--script.on_configuration_changed(function()
--
--end)
script.on_event(defines.events.on_tick, function(event)
	if global.on_tick[event.tick] then
		for _, tbl in pairs(global.on_tick[event.tick]) do
			tbl.func(tbl.vars)
		end
		global.on_tick[event.tick]=nil
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

script.on_nth_tick(6, function(event)
	if not global.forces then return end
	for id, data in pairs(global.forces) do
		for _, player in pairs(data.players) do
			local character = player.character
			if character then
				character.health = character.health + data.bonuses.regen/10
				if data.bonuses.pctregen > 0 then
					character.health = character.health + (character.prototype.max_health + character.character_health_bonus + character.force.character_health_bonus )/1000*data.bonuses.pctregen
					--game.print((character.prototype.max_health + character.character_health_bonus + character.force.character_health_bonus )/1000*data.bonuses.pctregen*10)
				end
			end
		end
	end
	for _, player in pairs ( game.players) do
		if player.character and player.character.valid and global.forces[player.force.name] and global.forces[player.force.name].bonuses.energy then
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
				local remaining_electricity = global.forces[player.force.name].bonuses.energy*10^2 -- 1/10 KJ
				for i=1, 2 do
					local used_electricity = 0
					local temp_batteries = 0
					for _, eq in pairs(target_entity.grid.equipment) do
						if eq.type == "battery-equipment" and eq.energy < eq.max_energy then
							local charging = math.min(remaining_electricity/batteries, eq.max_energy-eq.energy)
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

		local force_name = player.force.name
		if global.forces[force_name] and global.forces[force_name].bonuses.momentum > 0 and player.character and player.character.valid then
			local position_x = player.position.x
			local position_y = player.position.y
			if not global.momentum[player.index] then
				global.momentum[player.index] = {position_x = position_x, position_y = position_y, momentum = 0}
			end
			if position_x == global.momentum[player.index].position_x and position_y == global.momentum[player.index].position_y then
				remove_stickers(player)
				global.momentum[player.index].momentum = 0
			elseif event.tick % 60 == 0 and global.momentum[player.index].momentum < 5 then
				global.momentum[player.index].momentum = global.momentum[player.index].momentum + 1
				player.surface.create_entity{name = "rpgitems-speed-sticker-"..global.momentum[player.index].momentum, position=player.position, target= player.character}
			end
			global.momentum[player.index].position_x = position_x
			global.momentum[player.index].position_y = position_y
		elseif global.momentum[player.index] and global.momentum[player.index].momentum > 0 then
			remove_stickers(player)
			global.momentum[player.index].momentum = 0
		end
	end
end)

script.on_nth_tick(61, function(event)
	for _, player in pairs(game.players) do
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
	global.immolation [player.index] = nil
	if player.character and player.character.valid and player.character.stickers then
		for _, sticker in pairs(player.character.stickers) do
			if sticker.name == "rpgitems-flamecloak-sticker" then
				sticker.destroy()
			end
		end
	end
end
script.on_nth_tick(25, function(event)
	for _, player in pairs(game.players) do
		if global.immolation [player.index] then
			local immolation_bonus = global.forces[player.force.name].bonuses.immolation 
			if immolation_bonus > 0 and player.character and player.character.valid then
				local enemies = player.surface.find_entities_filtered{type = {"unit", "character"}, position = player.position, radius = 6}
				local damage_mult = player.force.get_ammo_damage_modifier("flamethrower")+1
				for _, enemy in pairs(enemies) do
					if enemy.valid and enemy.force ~= player.force and not enemy.force.get_cease_fire(player.force) and not enemy.force.get_friend(player.force)then
						enemy.damage(immolation_bonus*25/60 *damage_mult, player.force.name, "fire")
					end
				end
			else
				disable_immolation(player)
			end
		end
	end
end)

script.on_nth_tick(60, function(event)

	for id, data in pairs(global.forces) do
		--income
		--local player = game.players[id]
		data.money = data.money + data.bonuses.income
		local update = false
		for field, cd in pairs(data.item_cooldowns) do
			cd = cd -1
			if cd <= 0 then
				cd = nil
			end
			data.item_cooldowns[field] = cd
			update = true
		end
		for item, persec in pairs(data.giveitem) do
			for _, player in pairs(data.players) do
				if not global.giveitem_cache[player.index] then
					global.giveitem_cache[player.index] = {}
				end
				global.giveitem_cache[player.index][item] = (global.giveitem_cache[player.index][item] or 0) + persec
			end
		end
		for _, player in pairs(data.players) do
			player.gui.left.rpgitems_item_gui.money.caption = math.floor(global.forces[id].money).."[img=rpgitems-coin]"
			--cooldowns
			if update then
				update_items(game.forces[id])
			end
			--giveitem
			if player.character and player.character.valid and global.giveitem_cache[player.index] then
				for item, cached in pairs(global.giveitem_cache[player.index]) do
					local in_inventory = player.get_main_inventory().get_item_count(item)
					if cached >= 1 and in_inventory < 200 then
						local inserted = player.insert{name=item, count = math.min(200-in_inventory,math.floor(cached))}
						global.giveitem_cache[player.index][item] = global.giveitem_cache[player.index][item] - inserted
					end
				end
			end
			
		end
	end
	for id, entity in pairs(global.repairing) do
		
		if not entity or not entity.valid then
			global.repairing[id] = nil
		else
			local force_name = entity.force.name
			if not global.forces[force_name] or global.forces[force_name].bonuses.repair == 0 or entity.get_health_ratio() == 1 then
				global.repairing[id] = nil
			else
				entity.health = entity.health + entity.prototype.max_health/100*global.forces[force_name].bonuses.repair
			end
		end	
	end
end)

script.on_event(defines.events.on_player_main_inventory_changed, function(event)
	if event.tick%60 ~=0 then
		local player = game.players[event.player_index]
		if player.character and player.character.valid and global.giveitem_cache[player.index] then
			for item, cached in pairs(global.giveitem_cache[player.index]) do
				local in_inventory = player.get_main_inventory().get_item_count(item)
				if cached >= 1 and in_inventory < 200 then
					local inserted = player.insert{name=item, count = math.min(200-in_inventory,math.floor(cached))}
					global.giveitem_cache[player.index][item] = global.giveitem_cache[player.index][item] - inserted
				end
			end
		end
	end
end)

function table_length(tbl)
	local i=0
	for _ in pairs(tbl) do
		i=i+1
	end
	return i
end

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
	local x=(pos1.x-pos2.x)^2
	local y=(pos1.y-pos2.y)^2
	return(x+y)^0.5
end

function print(str)
game.players[1].print(str)
end

script.on_event(defines.events.on_gui_opened, function(event)
	if not event.entity  then return end
	if event.entity.name =="rpgitems-market" then
		local player = game.players[event.player_index]
		open_market(player)
		unlock_items(player)
	end
	--if event.entity.name =="rpgitems-item-market" then
	--	local player = game.players[event.player_index]
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
		lock_items(game.players[event.player_index])
	--elseif event.element and event.element.name == "rpgitems_item_market" then
	--	event.element.destroy()
	end
end)

script.on_event(defines.events.on_entity_died, function(event)
	if not event.force or not event.entity or not event.entity.valid or event.entity.type == "tree" then return end
	local force = event.force.name
	if global.forces[force] then
		--local player_id = tonumber(event.force.name:sub(8))
		global.forces[force].money = global.forces[force].money + 1
		--event.entity.surface.create_entity{name= "flying-text", color = {r=0,g=0.7,b=0}, position = event.entity.position, render_player_index = player_id, text = "+1"}
		for _, player in pairs(global.forces[force].players) do
			player.gui.left.rpgitems_item_gui.money.caption = math.floor(global.forces[force].money).."[img=rpgitems-coin]"
		end
	end
	
end)


script.on_event(defines.events.on_player_died, function(event)
	local player=game.players[event.player_index]
	if player.gui.center.rpgitems_market then player.gui.center.rpgitems_market.destroy() end
end)

function apply_armor (event, armor)
	local grid = event.entity.grid
	local bonus_healing = 0
	if grid and grid.max_shield > 0 then
		local actual_damage = event.original_damage_amount
		local armor_inv = event.entity.get_inventory(defines.inventory.character_armor)
		if armor_inv[1].valid_for_read and armor_inv[1].prototype.resistances then
			local event_damage_type = event.damage_type.name
			if armor_inv[1].prototype.resistances[event_damage_type] then
				actual_damage = math.max(0, (event.original_damage_amount - armor_inv[1].prototype.resistances[event_damage_type].decrease) * (1-armor_inv[1].prototype.resistances[event_damage_type].percent))
			end
		end
		local shield_healing = (actual_damage - event.final_damage_amount) *armor
		bonus_healing = math.min(event.final_damage_amount, shield_healing)
		shield_healing = shield_healing - bonus_healing
		shield_healing = math.min(shield_healing,grid.max_shield - grid.shield)
		
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
script.on_event(defines.events.on_entity_damaged, function(event)
	--print("orig: "..event.original_damage_amount)
	--print("final: "..event.final_damage_amount )
	if event.entity and event.entity.health >0 then
		local force = event.entity.force
		if event.entity.type == "character" then
			local player = event.entity.player
			if event.cause and global.forces[force.name].bonuses.thorns > 0 and event.damage_type.name ~="acid" and event.damage_type.name ~="fire" then
				event.cause.damage(global.forces[force.name].bonuses.thorns, event.entity.force, event.damage_type.name)
			end
			--if event.damage_type.name:sub(1,4)=="osp_" then
			--	local mres = global.forces[player.force.name].bonuses.magic_resistance /(global.forces[player.force.name].bonuses.magic_resistance+100)
			--	event.entity.health = event.entity.health + event.final_damage_amount*mres	
			--else
				local armor = global.forces[force.name].bonuses.armor /(global.forces[force.name].bonuses.armor+100)
				apply_armor(event,armor)
			--end
		elseif global.forces[force.name] and global.forces[force.name].bonuses.repair > 0 and event.entity.name ~="RITEG-1" then
			global.repairing[event.entity.unit_number] = event.entity
		end
	end
	if event.cause and event.cause.valid then
		local force = event.cause.force.name
		if not global.forces[force] then return end
		if event.entity.valid then
			local extradamage = 0
			--if event.damage_type.name == "chardamage" then
			--	local mult = global.forces[force].bonuses.chardamage_mult+event.cause.force.get_turret_attack_modifier("character")
			--	extradamage = global.forces[force].bonuses.chardamage*mult + (mult-1)*8
			--	extradamage = event.entity.damage(extradamage, event.cause.force, "physical")
			--end
			if event.entity.valid and math.random() < global.forces[force].bonuses.stun * (event.cause.type == "character" and 6 or 2) then
				--game.print(global.forces[force].bonuses.stun * (event.cause.type == "character" and 2 or 1))
				if event.entity.type == "unit" or event.entity.type == "character" then
					event.entity.surface.create_entity{ name="rpgitems-stun-sticker", position=event.entity.position, target=event.entity }
				end
			end
			if event.entity.valid and event.entity.has_flag("breaths-air") and math.random() < global.forces[force].bonuses.crit then
				local pos =  event.entity.position
				local surface = event.entity.surface
				--local player_mult = 1
				--if event.
				extradamage = event.entity.damage((event.original_damage_amount+extradamage)*(1+global.forces[force].bonuses.critdamage), event.cause.force, event.damage_type.name)
				local dmg = extradamage + event.final_damage_amount
				surface.create_entity{name="flying-text", position = pos, color = {r=1,g=0,b=0}, text = math.floor(dmg)}
			end
			if event.cause.type == "character" then
				if global.forces[force].bonuses.pctlifesteal > 0 then
					event.cause.health = event.cause.health + (event.final_damage_amount + extradamage)/100*global.forces[force].bonuses.pctlifesteal
				end
				if global.forces[force].bonuses.lifesteal > 0 then
					event.cause.health = event.cause.health + global.forces[force].bonuses.lifesteal
				end
			end
		end
	
	
	end
end)

script.on_event(defines.events.on_pre_player_died, function(event)
	local player = game.players[event.player_index]
	local force_name = player.force.name
	if global.forces[force_name] and global.forces[force_name].bonuses.revive >0 and not global.forces[force_name].item_cooldowns["rpgitems_crusader"] and not global.forces[force_name].item_cooldowns["rpgitems_crusader_spepa"] then
		local level = math.min(5,global.forces[force_name].bonuses.revive)
		local cdr = 0
		if remote.interfaces["spell-pack"] then
			local players =remote.call("spell-pack","get","players")
			cdr = players[event.player_index].cdr / 2
		end
		global.forces[force_name].item_cooldowns["rpgitems_crusader"] = 300 * (1-cdr)
		global.forces[force_name].item_cooldowns["rpgitems_crusader_spepa"] = 300 * (1-cdr)
		
		player.character.health = 1
		player.character.destructible = false
		player.surface.create_entity{name = "rpgitems-halo-sticker-"..level, position= player.position, target = player.character}
		if not global.on_tick[event.tick+level*60] then
			global.on_tick[event.tick+level*60] = {}
		end
		table.insert(global.on_tick[event.tick+level*60], {
			func = function(vars)
				vars.char.destructible = true
			end,
			vars = {char = player.character}
		})
	end
end)