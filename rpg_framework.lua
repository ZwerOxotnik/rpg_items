require "json"
require "LibDeflate"
require "base64"

script.on_event(defines.events.on_gui_click, function(event)
	local element = event.element
	if not (element and element.valid) then return end

	local player_id = element.player_index
	local player = game.players[player_id]
	local force_data = global.forces[player.force.name]
	local gui_name = element.name
	local parent_name = element.parent.name
	local items = nil
	if element.type == "sprite-button" then
	 items = global.items[element.sprite]
	end
	local item = global.items[gui_name]

	if gui_name == "rpgitems_bonus_slot" then
		if event.button == defines.mouse_button_type.right then
			if force_data.money >= 50000+force_data.bonus_slots*10000*(global.price_mult or settings.global["rpgitems_price_mult"].value) then
				force_data.money = force_data.money-(50000+force_data.bonus_slots*10000*(global.price_mult or settings.global["rpgitems_price_mult"].value))
				force_data.bonus_slots = force_data.bonus_slots + 1
				element.number = 50000+force_data.bonus_slots*10000*(global.price_mult or settings.global["rpgitems_price_mult"].value)
				for _, p in pairs(force_data.players) do
					create_equipment_gui(p)
					if p.gui.center.rpgitems_market then
						unlock_items(p)
					end
				end
			end
		end
	elseif item and parent_name == "market_buy_item" and force_data.money >= element.number then
		buy_item(player.force, gui_name)
		player.gui.left.rpgitems_item_gui.money.caption = math.floor(force_data.money).."[img=rpgitems-coin]"
		open_market(player)
	elseif item and parent_name == "market_table" then
		if event.button == defines.mouse_button_type.right and force_data.money >= element.number then
			buy_item(player.force, gui_name)
			player.gui.left.rpgitems_item_gui.money.caption = math.floor(force_data.money).."[img=rpgitems-coin]"
			open_market(player)
		else
			open_market(player, gui_name)
		end
	elseif items and parent_name == "equipment_table" and event.button == defines.mouse_button_type.right and player.gui.center.rpgitems_market then
		--if force_data.money > item.price and table_length(force_data) < 6 then
			local once = false
			for i, data in pairs( force_data.items ) do
				if not once then
					if data.item ==element.sprite then
						if data.count == 1 then
							force_data.items[i] = nil
						else
							data.count = data.count - 1
						end
						once = true
					end
				end
			end
			if once then
				force_data.items = sort_items(force_data.items)
				force_data.money = force_data.money + get_sell_price(element.sprite) * 0.8
				player.gui.left.rpgitems_item_gui.money.caption = math.floor(force_data.money).."[img=rpgitems-coin]"
				update_items(player.force)
				open_market(player)
			end
		--end
	elseif items and parent_name == "equipment_table" and not player.gui.center.rpgitems_market and (not force_data.item_cooldowns[element.sprite]) then
		if items.cooldown then
			if items.cooldown > 0 then
				force_data.item_cooldowns[element.sprite] = items.cooldown
			end
			items.func(player)
			if items.consumed then
				local once = false
				for i, data in pairs(force_data.items) do
					if not once then
						if data.item == element.sprite then
							if data.count == 1 then
								force_data.items[i] = nil
							else
								force_data.items[i].count = data.count-1
							end
							once = true
						end
					end
				end
				update_items(player.force)
			end
		end
	end
	talents_gui_click(event)
end)


script.on_event(defines.events.on_gui_text_changed, function(event)
	if event.element.name == "rpgitems_talents_copypaste" then
--		local player = game.players[event.player_index]
--		--local unbased,err = pcall(base64.decode,event.element.text)
--		local unbased = base64.decode(event.element.text)
--		game.print(unbased)
--		game.print(err)
--		if unbased then
--			--local decompressed = LibDeflate:DecompressZlib(err)
--			local decompressed = LibDeflate:DecompressZlib(unbased)
--			if decompressed then
--				--local talents_status, talents = pcall(decode,decompressed)
--				local talents =decode(decompressed)
--				if talents_status then
--					--global.talents[player.index] = talents
--					talents_gui(player)
--				else
--					player.print("JSON failed")
--				end
--			else
--				player.print("decompress failed")
--			end
--		else
--			player.print("base64 failed")
--		end
--
--
--	--local talents_string = encode(global.talents[player.index])
--	--local compressed =  LibDeflate:CompressZlib(talents_string,{strategy="fixed"})
--	--local b64 = base64.encode( compressed)
--	--copypaste.text = b64
		local player = game.players[event.player_index]
		local unbased,unbased_ret = pcall(base64.decode,event.element.text)
		--local unbased = base64.decode(event.element.parent.rpgitems_talents_copypaste.text)
		--local unbased =event.element.parent.rpgitems_talents_copypaste.text
		if unbased then
			local decompressed,decompressed_ret = pcall(LibDeflate_DecompressZlib,unbased_ret)
			--local decompressed = LibDeflate:DecompressZlib(unbased)
			if decompressed then
				local talents_status, talents = pcall(decode,decompressed_ret)
				--local talents =decode(decompressed)
				--local talents =decode(unbased)
				if talents_status then
					global.talents[player.force.name] = talents
					for _, p in pairs(global.forces[player.force.name].players) do
						talents_gui(p)
					end
				else
					--player.print("JSON failed")
				end
			else
				player.print("decompress failed")
			end
		else
			player.print("base64 failed")
		end
	end
end)
function remove_margin_padding(elem)
		elem.style.top_margin = 0
		elem.style.right_margin = 0
		elem.style.left_margin = 0
		elem.style.bottom_margin = 0
		elem.style.top_padding = 0
		elem.style.right_padding = 0
		elem.style.left_padding = 0
		elem.style.bottom_padding = 0
end
function apply_talents(force)
	--if not global.forces[force.name] then return end
	--if not global.talents[player.force.name].ready then return end
	local store_periodical = {}
	for _, mod in pairs(global.forces[force.name].talent_modifiers) do
		local mult = 1
		if mod.periodical then
			mult = mod.periodical
			store_periodical[mod.modifier] = {type = mod.type, value = mod.value, periodical = mult}
		end
		remove_modifier(force,mod,mult)
	end
	global.forces[force.name].talent_modifiers = {}
	local talent_modifiers = {}
	for rgb, data in pairs(global.talents[force.name]) do
		if rgb ~="ready" then
		for id, amount in pairs(data) do
			local temp_mod = deepcopy(global.all_talents[rgb][id])
			if temp_mod.value then
				temp_mod.value = temp_mod.value * amount
			elseif temp_mod.per_second then
				temp_mod.per_second = temp_mod.per_second * amount
			end
			table.insert(talent_modifiers, temp_mod)
		end
		end
	end
	for _, modifier in pairs(talent_modifiers) do
		local mult = 1
		if modifier.periodical then
			if store_periodical[modifier.modifier] and store_periodical[modifier.modifier].type == modifier.type and store_periodical[modifier.modifier].value == modifier.value then
				mult = store_periodical[modifier.modifier].periodical
			else
				mult = modifier.periodical
			end
		end
		add_modifier(force,modifier,mult)
		table.insert(global.forces[force.name].talent_modifiers, modifier)
	end
end
function talents_gui_click(event)
	if not event.element or not event.element.valid then return end
	if event.element.parent and event.element.parent.name:sub(1,23) == "rpgitems_talent_choice_" then
		local player = game.players[event.player_index]
		local BONUS_TALENTS = global.forces[player.force.name].bonus_talents
		if event.button == defines.mouse_button_type.left then
			if event.shift then
				for i=1, 5 do
					local verified_talents = verify_talents(player.force)
					if verified_talents[event.element.parent.name:sub(24,24)].spent>= 8+BONUS_TALENTS and verified_talents.total_spent >= 27+BONUS_TALENTS*4 and verified_talents.a == 4+BONUS_TALENTS or verified_talents.total_spent >= 28+BONUS_TALENTS*4 then
					else
						global.talents[player.force.name][event.element.parent.name:sub(24,24)][event.element.name] = (global.talents[player.force.name][event.element.parent.name:sub(24,24)][event.element.name] or 0) + 1
					end

				end
			else
				local verified_talents = verify_talents(player.force)
				if verified_talents[event.element.parent.name:sub(24,24)].spent>= 8+BONUS_TALENTS and verified_talents.total_spent >= 27+BONUS_TALENTS*4 and verified_talents.a == 4+BONUS_TALENTS or verified_talents.total_spent >= 28+BONUS_TALENTS*4 then
				else
					global.talents[player.force.name][event.element.parent.name:sub(24,24)][event.element.name] = (global.talents[player.force.name][event.element.parent.name:sub(24,24)][event.element.name] or 0) + 1
				end
			end
		elseif event.button == defines.mouse_button_type.right then
			if event.shift then
				global.talents[player.force.name][event.element.parent.name:sub(24,24)][event.element.name] = math.max(0,(global.talents[player.force.name][event.element.parent.name:sub(24,24)][event.element.name] or 0) - 5)
			else
				global.talents[player.force.name][event.element.parent.name:sub(24,24)][event.element.name] = math.max(0,(global.talents[player.force.name][event.element.parent.name:sub(24,24)][event.element.name] or 0) - 1)
			end
		end
		--verify_talents(game.forces[player.force.name])
		for _, p in pairs(global.forces[player.force.name].players) do
			talents_gui(p)
		end
	elseif event.element.name == "rpgitems_talents_close" then
		local player = game.players[event.player_index]
		for _, p in pairs(global.forces[player.force.name].players) do
			p.gui.center.talents_gui.destroy()
		end
		global.talents[player.force.name].ready = true
		apply_talents(player.force)
	--elseif event.element.name == "rpgitems_talents_copypaste_button" then
	--	local player = game.players[event.player_index]
	--	local unbased,unbased_ret = pcall(base64.decode,event.element.parent.rpgitems_talents_copypaste.text)
	--	--local unbased = base64.decode(event.element.parent.rpgitems_talents_copypaste.text)
	--	--local unbased =event.element.parent.rpgitems_talents_copypaste.text
	--	if unbased then
	--		local decompressed,decompressed_ret = pcall(LibDeflate_DecompressZlib,unbased_ret)
	--		--local decompressed = LibDeflate:DecompressZlib(unbased)
	--		if decompressed then
	--			local talents_status, talents = pcall(decode,decompressed_ret)
	--			--local talents =decode(decompressed)
	--			--local talents =decode(unbased)
	--			if talents_status then
	--				global.talents[player.index] = talents
	--				talents_gui(player)
	--			else
	--				player.print("JSON failed")
	--			end
	--		else
	--			player.print("decompress failed")
	--		end
	--	else
	--		player.print("base64 failed")
	--	end
	end
end
function verify_talents(force)
	for rgb, data in pairs(global.talents[force.name]) do
		for id, amount in pairs(data) do
			if amount == 0 then
				global.talents[force.name][rgb][id] = nil
			end
		end
	end
	local BONUS_TALENTS = global.forces[force.name].bonus_talents
	local ret = {r={spent = 0, over_spent = 0, width = 8+BONUS_TALENTS},g={spent = 0,over_spent = 0, width = 8+BONUS_TALENTS},b={spent = 0,over_spent = 0, width = 8+BONUS_TALENTS},a=0,total_spent = 0}
	local total_spent = 0
	local over_spent = 0
	for rgb, data in pairs(global.talents[force.name]) do
		for _, amount in pairs(data) do
			ret[rgb].spent = (ret[rgb].spent or 0) +amount
			--total_spent = total_spent + amount
		end
		--if ret[rgb].spent > 8 then
		--	local a= math.min(4-ret["a"],ret[rgb].spent-8)
		--	ret["a"] = ret["a"] +a
		--	ret[rgb].over_spent = ret[rgb].spent - a - 8
		--elseif ret[rgb].spent < 8 then
		--	spare = spare + (8-ret[rgb].spent)
		--end
		total_spent = total_spent + math.min(8+BONUS_TALENTS, ret[rgb].spent)
		if ret[rgb].spent > 8+BONUS_TALENTS then
			local a= math.min(4+BONUS_TALENTS-ret["a"],ret[rgb].spent-8-BONUS_TALENTS)
			ret["a"] = ret["a"] +a
			total_spent = total_spent + a
			if ret[rgb].spent > 8+BONUS_TALENTS+a then
				total_spent = total_spent + 2*(ret[rgb].spent - a - 8-BONUS_TALENTS)
				ret[rgb].over_spent = ret[rgb].spent - a - 8-BONUS_TALENTS
				over_spent = over_spent + ret[rgb].spent - a - 8-BONUS_TALENTS
			end
			ret[rgb].width = ret[rgb].spent
		end
	end
	over_spent = over_spent * 2
	local remaining_points = 28+BONUS_TALENTS*4-total_spent
	local temp_over_spent = over_spent
	local remaining_points_till_8 = 0
	for rgb, data in pairs(ret) do
		if rgb ~= "a" and rgb ~="total_spent" then
		if data.spent < 8+BONUS_TALENTS then
			remaining_points_till_8 = remaining_points_till_8 +8+BONUS_TALENTS-data.spent
		end
		end
	end
	for rgb, data in pairs(ret) do
		if rgb ~= "a" and rgb ~="total_spent" then
			if data.spent < 8+BONUS_TALENTS then
				--local spare = math.min(math.max(0,8-data.spent), over_spent)
				--over_spent= over_spent-spare
				--data.width = data.width - spare
				data.width = data.width-(8+BONUS_TALENTS-data.spent)/remaining_points_till_8*over_spent

			end
		end
	end
	ret.total_spent = total_spent
	return ret
end
function filter_clicks(button, input)
	--local filter = {
	--	["left-and-right"] = false,
	--	["left"] = false,
	--	["right"] = false,
	--	["middle"] = false,
	--	["button-4"] = false,
	--	["button-5"] = false,
	--	["button-6"] = false,
	--	["button-7"] = false,
	--	["button-8"] = false,
	--	["button-9"] = false,
	--}
	--filter[input] = true
	--for button_name, bool in pairs(filter) do
	--	--button.mouse_button_filter[button_name] = bool
	--end
	button.mouse_button_filter = {input}
end
function talents_gui(player)
	local force = player.force
	local BONUS_TALENTS = global.forces[force.name].bonus_talents
	local talents = global.talents
	if not talents[force.name] then talents[force.name] = {r={},g={},b={}} end

	local verified_talents = verify_talents(force)
	if player.gui.center.talents_gui then player.gui.center.talents_gui.destroy() end
	local gui = player.gui.center.add{type="frame",name = "talents_gui", direction="vertical"}
	gui.style.width = 668
	local header_flow = gui.add{type="flow", name = "header_flow", direction = "horizontal"}
	local copypaste = header_flow.add{type="textfield", name = "rpgitems_talents_copypaste"}
	--local copypaste_button = header_flow.add{type="button", name = "rpgitems_talents_copypaste_button", caption="load"}
	--copypaste_button.style.width = 50
	copypaste.style.font="default-tiny-bold"
	copypaste.style.width = 620
	local talents_string = encode(talents[force.name])
	local compressed =  LibDeflate_CompressZlib(talents_string)
	local b64 = base64.encode(compressed)
	copypaste.text = b64
	if verified_talents.total_spent >=28+BONUS_TALENTS*4 then
		local temp = header_flow.add{type = "sprite-button", name= "rpgitems_talents_close", sprite = "rpgitemsmarket_close"}
		temp.style.height = 29
		temp.style.width = 29
	end
	local flow = gui.add{type="flow", name = "flow", direction = "horizontal"}
	if verified_talents.total_spent <28+BONUS_TALENTS*4 or verified_talents.r.width >0 then
		local r = flow.add{type="progressbar", name="pr", style = "rpgitems_red_bar"}
		r.style.width = 665*verified_talents.r.width/(28+BONUS_TALENTS*4)
		--r.style.width = 190*verified_talents.r.width/(8+BONUS_TALENTS)
		--game.print("r ".. 190*verified_talents.r.width/(8+BONUS_TALENTS))
		remove_margin_padding(r)
		r.style.right_margin = -5
		r.style.left_margin = -9
		r.style.color= {r=1,g=0,b=0}
		r.value = math.min(1,verified_talents.r.spent/verified_talents.r.width)
	end
	if verified_talents.total_spent <28+BONUS_TALENTS*4 or verified_talents.g.width >0 then
		local g = flow.add{type="progressbar", name="pg", style = "rpgitems_green_bar"}
		g.style.width = 665*verified_talents.g.width/(28+BONUS_TALENTS*4)
		--g.style.width = 190*verified_talents.g.width/(8+BONUS_TALENTS)
		--game.print("g ".. 190*verified_talents.g.width/(8+BONUS_TALENTS))
		remove_margin_padding(g)
		g.style.right_margin = -5
		g.style.color = {r=0,g=1,b=0}
		g.value = math.min(1,verified_talents.g.spent/verified_talents.g.width)
	end
	if verified_talents.total_spent <28+BONUS_TALENTS*4 or verified_talents.b.width >0 then
		local b = flow.add{type="progressbar", name="pb", style = "rpgitems_blue_bar"}
		b.style.width = 665*verified_talents.b.width/(28+BONUS_TALENTS*4)
		--b.style.width = 190*verified_talents.b.width/(8+BONUS_TALENTS)
		--game.print("b ".. 190*verified_talents.b.width/(8+BONUS_TALENTS))
		remove_margin_padding(b)
		b.style.right_margin = -5
		b.style.color = {r=0,g=0,b=1}
		b.value = math.min(1,verified_talents.b.spent/verified_talents.b.width)
	end
	if verified_talents.a <4+BONUS_TALENTS then
		local a = flow.add{type="progressbar", name="pa", style = "rpgitems_white_bar"}
		a.style.width = 664*(4+BONUS_TALENTS-verified_talents.a)/(28+BONUS_TALENTS*4)
		--a.style.width = 95*(4+BONUS_TALENTS-verified_talents.a)/(4+BONUS_TALENTS)
		--game.print("a ".. 95*(4+BONUS_TALENTS-verified_talents.a)/(4+BONUS_TALENTS))
		remove_margin_padding(a)
		a.style.color = {r=1,g=1,b=1}
		a.value = 0
	end
	local tbl = gui.add{type="table",name="talent_list",column_count = 3}
	tbl.vertical_centering = false
	tbl.draw_vertical_lines = true
	tbl.style.right_cell_padding = 0
	tbl.style.left_cell_padding = 0
	tbl.style.width=652
	tbl.style.horizontal_spacing = 5

	local fr = tbl.add{type="flow", name = "r", direction = "vertical"}
	remove_margin_padding(fr)
	fr.style.height = 250
	fr.style.width = 175
	--fr.style.right_margin = -50
	local forec_talents = talents[force.name]
	local talent_localizations = global.talent_localizations
	local i = 1
	for name in pairs(global.all_talents.r) do
		local temp_flow = fr.add{type="flow", name="rpgitems_talent_choice_r_"..i, direction = "horizontal"}
		local label = temp_flow.add{type="label", name = "l"..i}
		remove_margin_padding(label)
		label.style.font = "default-bold"
		label.style.height = 20
		label.style.width = 20
		label.style.right_margin = -7
		label.style.left_margin = 3
		label.style.top_margin = -1
		label.caption=forec_talents.r[name] or 0
		local button
		if verified_talents.r.spent >= 8+BONUS_TALENTS then
			if verified_talents.total_spent >= 27+BONUS_TALENTS*4 and verified_talents.a == 4+BONUS_TALENTS  then
				button = temp_flow.add{type="button", name = name, caption = talent_localizations[name], style="rpgitems_gray_button"}
				if not forec_talents.r[name] or forec_talents.r[name] == 0 then
					button.enabled = false
				else
					filter_clicks(button, "right")
				end
			elseif verified_talents["a"] < 4+BONUS_TALENTS then
				button = temp_flow.add{type="button", name = name, caption = talent_localizations[name], style="rpgitems_yellow_button"}
			else
				button = temp_flow.add{type="button", name = name, caption = talent_localizations[name], style="rpgitems_orange_button"}
			end
		elseif verified_talents.total_spent >= 28+BONUS_TALENTS*4 then
			button = temp_flow.add{type="button", name = name, caption = talent_localizations[name], style="rpgitems_gray_button"}
			if not forec_talents.r[name] or forec_talents.r[name] == 0 then
				button.enabled = false
			else
				filter_clicks(button, "right")
			end
		else
			button = temp_flow.add{type="button", name = name, caption = talent_localizations[name], style="rpgitems_white_button"}
			if not forec_talents.r[name] or forec_talents.r[name] == 0 then
				filter_clicks(button, "left")
			end
		end
		remove_margin_padding(button)
		button.style.height = 20
		button.style.width = 185
		button.style.horizontal_align="left"
		button.style.horizontally_stretchable = true
		button.style.top_padding = -2

		i=i+1
	end

	local fg = tbl.add{type="flow", name = "g", direction = "vertical"}
	remove_margin_padding(fg)
	fg.style.height = 250
	fg.style.width = 175
	--fg.style.right_margin = -50
	local i = 1
	for name in pairs(global.all_talents.g) do
		local temp_flow = fg.add{type="flow", name="rpgitems_talent_choice_g_"..i, direction = "horizontal"}
		local label = temp_flow.add{type="label", name = "l"..i}
		remove_margin_padding(label)
		label.style.font = "default-bold"
		label.style.height = 20
		label.style.width = 20
		label.style.right_margin = -7
		label.style.left_margin = 3
		label.style.top_margin = -1
		label.caption=talents[force.name]["g"][name] or 0
		local button
		if verified_talents["g"].spent >= 8+BONUS_TALENTS then
			if verified_talents.total_spent >= 27+BONUS_TALENTS*4 and verified_talents.a == 4+BONUS_TALENTS then
				button = temp_flow.add{type="button", name = name, caption = talent_localizations[name], style="rpgitems_gray_button"}
				if not talents[force.name].g[name] or talents[force.name].g[name] == 0 then
					button.enabled = false
				else
					filter_clicks(button, "right")
				end
			elseif verified_talents["a"] < 4+BONUS_TALENTS then
				button = temp_flow.add{type="button", name = name, caption = talent_localizations[name], style="rpgitems_yellow_button"}
			else
				button = temp_flow.add{type="button", name = name, caption = talent_localizations[name], style="rpgitems_orange_button"}
			end
		elseif verified_talents.total_spent >= 28+BONUS_TALENTS*4 then
			button = temp_flow.add{type="button", name = name, caption = talent_localizations[name], style="rpgitems_gray_button"}
			if not talents[force.name].g[name] or talents[force.name].g[name] == 0 then
				button.enabled = false
			else
				filter_clicks(button, "right")
			end
		else
			button = temp_flow.add{type="button", name = name, caption = talent_localizations[name], style="rpgitems_white_button"}
			if not talents[force.name].g[name] or talents[force.name].g[name] == 0 then
				filter_clicks(button, "left")
			end
		end
		remove_margin_padding(button)
		button.style.height = 20
		button.style.width = 185
		button.style.horizontal_align="left"
		button.style.horizontally_stretchable = true
		button.style.top_padding = -2
		i=i+1
	end

	local fb = tbl.add{type="flow", name = "b", direction = "vertical"}
	remove_margin_padding(fb)
	fb.style.height = 250
	fb.style.width = 175
	--fb.style.right_margin = -50
	local i=1
	for name in pairs(global.all_talents.b) do
		local temp_flow = fb.add{type="flow", name="rpgitems_talent_choice_b_"..i, direction = "horizontal"}
		local label = temp_flow.add{type="label", name = "l"..i}
		remove_margin_padding(label)
		label.style.font = "default-bold"
		label.style.height = 20
		label.style.width = 20
		label.style.right_margin = -7
		label.style.left_margin = 3
		label.style.top_margin = -1
		label.caption=global.talents[force.name]["b"][name] or 0
		local button
		if verified_talents["b"].spent >= 8+BONUS_TALENTS then
			if verified_talents.total_spent >= 27+BONUS_TALENTS*4 and verified_talents.a == 4+BONUS_TALENTS then
				button = temp_flow.add{type="button", name = name, caption = talent_localizations[name], style="rpgitems_gray_button"}
				if not global.talents[force.name].b[name] or global.talents[force.name].b[name] == 0 then
					button.enabled = false
				else
					filter_clicks(button, "right")
				end
			elseif verified_talents["a"] < 4+BONUS_TALENTS then
				button = temp_flow.add{type="button", name = name, caption = talent_localizations[name], style="rpgitems_yellow_button"}
			else
				button = temp_flow.add{type="button", name = name, caption = talent_localizations[name], style="rpgitems_orange_button"}
			end
		elseif verified_talents.total_spent >= 28+BONUS_TALENTS*4 then
			button = temp_flow.add{type="button", name = name, caption = talent_localizations[name], style="rpgitems_gray_button"}
			if not global.talents[force.name].b[name] or global.talents[force.name].b[name] == 0 then
				button.enabled = false
			else
				filter_clicks(button, "right")
			end
		else
			button = temp_flow.add{type="button", name = name, caption = talent_localizations[name], style="rpgitems_white_button"}
			if not global.talents[force.name].b[name] or global.talents[force.name].b[name] == 0 then
				filter_clicks(button, "left")
			end
		end

		remove_margin_padding(button)
		button.style.height = 20
		button.style.width = 185
		button.style.horizontal_align="left"
		button.style.horizontally_stretchable = true
		button.style.top_padding = -2
		i=i+1
	end
end


function sort_items(array)
	local temp = {}
	local i = 1
	local itemcounts = {}
	for _, e in pairs(array) do
		itemcounts[e.item] = (itemcounts[e.item] or 0)+e.count
	end
	for name, count in pairs(itemcounts) do
		while count > 0 do
			local tempcount = math.min((global.items[name].stack_size or 1), count)
			count = count - tempcount
			table.insert(temp, {item = name, count = tempcount})
		end
	end
	return temp
end

function insert_item (force, item)
	if not global.items[item].stack_size then
		table.insert(global.forces[force.name].items, {item = item, count = 1})
	else
		local once = false
		for _, data in pairs(global.forces[force.name].items) do
			if not once then
				if data.item == item and data.count < global.items[item].stack_size then
					data.count = data.count + 1
					once= true
				end
			end
		end
		if not once then
			table.insert(global.forces[force.name].items, {item = item, count = 1})
		end
	end
end

script.on_nth_tick(21600,function(event) -- every 6 minutes
	if not global.forces or global.per_minute then return end
	for index, data in pairs(global.forces) do
		local force=game.forces[index]
		for _, modifier in pairs(data.modifiers) do
			if modifier.periodical then
				modifier.periodical = modifier.periodical +1
				local mult = 1
				add_modifier(force,modifier,mult)
			end
		end
		for _, modifier in pairs(data.talent_modifiers) do
			if modifier.periodical then
				modifier.periodical = modifier.periodical +1
				local mult = 1
				add_modifier(force,modifier,mult)
			end
		end
	end
end)

script.on_nth_tick(10800,function(event) -- every 3 minutes
	if not global.forces or not global.per_minute then return end
	for index, data in pairs(global.forces) do
		local force=game.forces[index]
		for _, modifier in pairs(data.modifiers) do
			if modifier.periodical then
				modifier.periodical = modifier.periodical +1
				local mult = 1
				add_modifier(force,modifier,mult)
			end
		end
		for _, modifier in pairs(data.talent_modifiers) do
			if modifier.periodical then
				modifier.periodical = modifier.periodical +1
				local mult = 1
				add_modifier(force,modifier,mult)
			end
		end
	end
end)

function remove_modifier(force, modifier, mult)
	if not mult then mult = 1 end
	if modifier.type == "force" then
		if modifier.modifier == "gun_speed_modifier" then
			if not modifier.ammo then
				for a in pairs(game.ammo_category_prototypes) do
					local new_mod = math.max(0,force.get_gun_speed_modifier(a) - modifier.value*mult)
					if new_mod < 0.00000001 then
						new_mod = 0
					end
					force.set_gun_speed_modifier(a, new_mod )
				end
			elseif not game.ammo_category_prototypes[modifier.ammo] then
				game.print("ammo type "..modifier.ammo.." not existing anymore")
			else
				local new_mod = math.max(0,force.get_gun_speed_modifier(modifier.ammo) - modifier.value*mult)
				if new_mod < 0.00000001 then
					new_mod = 0
				end
				force.set_gun_speed_modifier(modifier.ammo, new_mod)
			end
		elseif modifier.modifier =="ammo_damage_modifier" then
			if not modifier.ammo then
				for a in pairs(game.ammo_category_prototypes) do
					local new_mod = math.max(0,force.get_ammo_damage_modifier(a) - modifier.value*mult)
					if new_mod < 0.00000001 then
						new_mod = 0
					end
					force.set_ammo_damage_modifier(a, new_mod)
				end
				--local new_mod = math.max(0,global.forces[force.name].bonuses.chardamage_mult -modifier.value*mult)
				--if new_mod < 0.00000001 then
				--	new_mod = 0
				--end
				--global.forces[force.name].bonuses.chardamage_mult = new_mod
			elseif not game.ammo_category_prototypes[modifier.ammo] then
				game.print("ammo type "..modifier.ammo.." not existing anymore")
			else
				local new_mod = math.max(0,force.get_ammo_damage_modifier(modifier.ammo) - modifier.value*mult)
				if new_mod < 0.00000001 then
					new_mod = 0
				end
				force.set_ammo_damage_modifier(modifier.ammo, new_mod)
			end
		elseif modifier.modifier =="turret_attack_modifier" then
			if not modifier.turret then
				game.print("ERROR: all turrets modifier currently not supported")
				error("all turrets modifier currently not supported")
				for t, data in pairs(game.entity_prototypes) do
					if data.type == "fluid-turret" or data.type == "ammo-turret" or data.type == "electric-turret" then
						local new_mod = math.max(0,force.get_turret_attack_modifier(t) - modifier.value*mult)
						if new_mod < 0.00000001 then
							new_mod = 0
						end
						force.set_turret_attack_modifier(t, new_mod)
					end
				end
			elseif not game.entity_prototypes[modifier.turret] then
				game.print("turret type "..modifier.turret.." not existing anymore")
			else
				local new_mod = math.max(0,force.get_turret_attack_modifier(modifier.turret) - modifier.value*mult)
				if new_mod < 0.00000001 then
					new_mod = 0
				end
				force.set_turret_attack_modifier(modifier.turret, new_mod)
			end
		elseif modifier.modifier == "character_reach_distance_bonus" then
			force[modifier.modifier] = math.max(0,force[modifier.modifier] - modifier.value*mult)
			force["character_build_distance_bonus"] = math.max(0,force["character_build_distance_bonus"] - modifier.value*mult)
			force["character_resource_reach_distance_bonus"] = math.max(0,force["character_resource_reach_distance_bonus"] - modifier.value*mult/4)
		else
			local new_mod = math.max(0,force[modifier.modifier] - modifier.value*mult)
			if new_mod < 0.00000001 then
				new_mod = 0
			end
			force[modifier.modifier] = new_mod
		end
	elseif modifier.type == "other" then
		if modifier.unique then
			local new_mod = math.max(0,global.forces[force.name].bonuses[modifier.modifier] - modifier.value*mult)
			if new_mod < 0.00000001 then
				new_mod = 0
			end
			global.forces[force.name].bonuses[modifier.modifier] = new_mod
		else
			local new_mod = global.forces[force.name].bonuses[modifier.modifier] - modifier.value*mult
			if new_mod < 0.00000001 then
				new_mod = 0
			end
			global.forces[force.name].bonuses[modifier.modifier] = new_mod
		end
	elseif modifier.type == "giveitem" then
		local new_mod = math.max(0,global.forces[force.name].giveitem[modifier.item] - modifier.per_second*mult)
		if new_mod < 0.00000001 then
			new_mod = 0
		end
		global.forces[force.name].giveitem[modifier.item] = new_mod
	elseif modifier.type == "spellpack" then
		if remote.interfaces["spell-pack"] and tonumber(game.active_mods["spell-pack"]:sub(-2)) >= 18 then
			--local players =remote.call("spell-pack","get","players")
			--for _, player in pairs(global.forces[force.name].players) do
			--	local new_mod = players[player.index][modifier.modifier]- modifier.value*mult
			--	players[player.index][modifier.modifier] = new_mod
			--end
			--remote.call("spell-pack","set","players",players)
			remote.call("spell-pack", "modforce", force,modifier.modifier, -modifier.value*mult)
		end
	elseif modifier.type == "remotecall" then
		if remote.interfaces[modifier.mod] then
			remote.call(modifier.mod, modifier.func, force, modifier.param, -modifier.value)
		end
	end
end

function add_modifier(force, modifier, mult)
	if not mult then mult = 1 end
	if modifier.type == "force" then
		if modifier.modifier == "gun_speed_modifier" then
			if not modifier.ammo then
				for a in pairs(game.ammo_category_prototypes) do
					force.set_gun_speed_modifier(a, math.max(0,force.get_gun_speed_modifier(a) + modifier.value*mult))
				end
			elseif not game.ammo_category_prototypes[modifier.ammo] then
				game.print("ammo type "..modifier.ammo.." not existing anymore")
			else
				force.set_gun_speed_modifier(modifier.ammo, math.max(0,force.get_gun_speed_modifier(modifier.ammo) + modifier.value*mult))
			end
		elseif modifier.modifier =="ammo_damage_modifier" then
			if not modifier.ammo then
				for a in pairs(game.ammo_category_prototypes) do
					force.set_ammo_damage_modifier(a, math.max(0,force.get_ammo_damage_modifier(a) + modifier.value*mult))
				end
				--global.forces[force.name].bonuses.chardamage_mult = global.forces[force.name].bonuses.chardamage_mult +modifier.value*mult
			elseif not game.ammo_category_prototypes[modifier.ammo] then
				game.print("ammo type "..modifier.ammo.." not existing anymore")
			else
				force.set_ammo_damage_modifier(modifier.ammo, math.max(0,force.get_ammo_damage_modifier(modifier.ammo) + modifier.value*mult))
			end
		elseif modifier.modifier =="turret_attack_modifier" then
			if not modifier.turret then
				game.print("ERROR: all turrets modifier currently not supported")
				error("all turrets modifier currently not supported")
				for t, data in pairs(game.entity_prototypes) do
					if data.type == "fluid-turret" or data.type == "ammo-turret" or data.type == "electric-turret" then
						force.set_turret_attack_modifier(t, math.max(0,force.get_turret_attack_modifier(t) + modifier.value*mult))
					end
				end
			elseif not game.entity_prototypes[modifier.turret] then
				game.print("turret type "..modifier.turret.." not existing anymore")
			else
				force.set_turret_attack_modifier(modifier.turret, math.max(0,force.get_turret_attack_modifier(modifier.turret) + modifier.value*mult))
			end
		elseif modifier.modifier == "character_reach_distance_bonus" then
			--game.print(force[modifier.modifier])
			--game.print(force["character_build_distance_bonus"])
			--game.print(force["character_resource_reach_distance_bonus"])
			force[modifier.modifier] = math.max(0,force[modifier.modifier] + modifier.value*mult)
			force["character_build_distance_bonus"] = math.max(0,force["character_build_distance_bonus"] + modifier.value*mult)
			force["character_resource_reach_distance_bonus"] = math.max(0,force["character_resource_reach_distance_bonus"] + modifier.value*mult/4)
		else
			--game.print(force[modifier.modifier])
			force[modifier.modifier] = force[modifier.modifier] + modifier.value*mult
		end
	elseif modifier.type == "other" then
		--if modifier.modifier == "income" then
			global.forces[force.name].bonuses[modifier.modifier] = global.forces[force.name].bonuses[modifier.modifier] + modifier.value*mult
		--end
	elseif modifier.type == "giveitem" then
		global.forces[force.name].giveitem[modifier.item] = (global.forces[force.name].giveitem[modifier.item] or 0) + modifier.per_second*mult
	elseif modifier.type == "spellpack" then
		if remote.interfaces["spell-pack"] and tonumber(game.active_mods["spell-pack"]:sub(-2)) >= 18 then
			--local players =remote.call("spell-pack","get","players")
			--for _, player in pairs(global.forces[force.name].players) do
			--	local new_mod = players[player.index][modifier.modifier]+ modifier.value*mult
			--	players[player.index][modifier.modifier] = new_mod
			--end
			--remote.call("spell-pack","set","players",players)
			remote.call("spell-pack", "modforce", force,modifier.modifier, modifier.value*mult)
		end
	elseif modifier.type == "remotecall" then
		if remote.interfaces[modifier.mod] then
			remote.call(modifier.mod, modifier.func, force, modifier.param, modifier.value)
		end
	end
end

function remove_modifiers(force, tbl)
	local stack_cache = {}
	for _, modifier in pairs(tbl) do
		--if modifier.type == "player" then
		--	player[modifier.modifier] = math.max(0,player[modifier.modifier] - modifier.value)
		--else
		local mult = 1
		if modifier.periodical then
			mult = modifier.periodical
			table.insert(stack_cache, {type = modifier.type, modifier = modifier.modifier, ammo= modifier.ammo, value = modifier.value, turret = modifier.turret, periodical = mult})
		end
		remove_modifier(force, modifier, mult)
	end
	return stack_cache
end

function add_modifiers(force, tbl, stack_cache)
	for _, mod in pairs(tbl) do
		local modifier = deepcopy(mod)
		local mult = 1
		if modifier.periodical then
			mult, stack_cache = get_stack(modifier, stack_cache)
			--if mult > 0 then
				modifier.periodical = mult
			--else
			--	mult = 1
			--end
		end
		--if modifier.type == "player" then
		--	player[modifier.modifier] = player[modifier.modifier] + modifier.value
		--else
		local unique = false
		if modifier.unique then
			for _, checkmod in pairs(global.forces[force.name].modifiers) do
				if checkmod.unique == modifier.unique then
					unique = true
				end
			end
		end
		if not unique then
			if modifier.modifier =="ammo_damage_modifier" and not modifier.ammo then
				for a in pairs(game.ammo_category_prototypes) do
					local new_mod = deepcopy(mod)
					new_mod.ammo = a
					add_modifier(force, new_mod, mult)
					table.insert(global.forces[force.name].modifiers, new_mod)
				end
				--local new_mod = math.max(0,global.forces[force.name].bonuses.chardamage_mult +modifier.value*mult)
				--if new_mod < 0.00000001 then
				--	new_mod = 0
				--end
				--global.forces[force.name].bonuses.chardamage_mult = new_mod
			elseif modifier.modifier == "gun_speed_modifier" and not modifier.ammo then
				for a in pairs(game.ammo_category_prototypes) do
					local new_mod = deepcopy(mod)
					new_mod.ammo = a
					add_modifier(force, new_mod, mult)
					table.insert(global.forces[force.name].modifiers, new_mod)
				end
			else
				add_modifier(force, modifier, mult)
				table.insert(global.forces[force.name].modifiers, modifier)
			end
		end
	end
	return stack_cache
end

function get_stack(modifier, stack_cache)
	local type = modifier.type
	local mod = modifier.modifier
	local ammo = modifier.ammo
	local value = modifier.value
	local turret = modifier.turret
	local biggest_mult = 0
	for i, mod2 in pairs(stack_cache) do
		if type == mod2.type and mod == mod2.modifier and ammo== mod2.ammo and value == mod2.value and turret == mod2.turret then		--, periodical = mult}
			biggest_mult = mod2.periodical
		end
	end
	for i, mod2 in pairs(stack_cache) do
		if type == mod2.type and mod == mod2.modifier and ammo== mod2.ammo and value == mod2.value and turret == mod2.turret and mod2.periodical == biggest_mult then		--, periodical = mult}
			stack_cache[i] = nil
		end
	end
	return biggest_mult, stack_cache
end

function update_items(force)
	local stacks = remove_modifiers(force,global.forces[force.name].modifiers)
	global.forces[force.name].modifiers = {}
	for _, data in pairs(global.forces[force.name].items) do
		for i=1, (data.count or 1) do
			stacks = add_modifiers(force,global.items[data.item].effects, stacks)
		end
	end
	for _, player in pairs(global.forces[force.name].players) do
		if #player.gui.left.rpgitems_item_gui.equipment_table.children ~= 4+global.forces[player.force.name].bonus_slots then
			create_equipment_gui(player)
		end
		local i = 1
		for _, data in pairs(global.forces[force.name].items) do
			player.gui.left.rpgitems_item_gui.equipment_table["item_"..i].sprite = data.item
			player.gui.left.rpgitems_item_gui.equipment_table["item_"..i].tooltip = global.items[data.item].name.."\n\n"..global.items[data.item].description
			if global.items[data.item].stack_size then
				player.gui.left.rpgitems_item_gui.equipment_table["item_"..i].number = data.count
			else
				player.gui.left.rpgitems_item_gui.equipment_table["item_"..i].number = nil
			end
			player.gui.left.rpgitems_item_gui.equipment_table["item_"..i].clear()
			if global.forces[force.name].item_cooldowns[data.item] then
				local bar = player.gui.left.rpgitems_item_gui.equipment_table["item_"..i].add{type = "progressbar", name = "cd", value = (global.forces[force.name].item_cooldowns[data.item]/global.items[data.item].cooldown)}
				bar.style.color = {r=1,g=1,b=0}
				bar.style.width = 24
				bar.style.top_padding = 0
				bar.style.bottom_padding = 0
				bar.style.left_padding = 0
				bar.style.right_padding = 0
				bar.style.top_margin = 0
				bar.style.bottom_margin = 0
				bar.style.left_margin = -1
				bar.style.right_margin = 0
			end
			i=i+1
		end

		for j=i, 4+global.forces[player.force.name].bonus_slots do
			player.gui.left.rpgitems_item_gui.equipment_table["item_"..j].sprite = "transparent32"
			player.gui.left.rpgitems_item_gui.equipment_table["item_"..j].tooltip = ""
			player.gui.left.rpgitems_item_gui.equipment_table["item_"..j].number = nil
			player.gui.left.rpgitems_item_gui.equipment_table["item_"..j].clear()
		end
	end
end

function lock_items(player)
	for _, elem in pairs(player.gui.left.rpgitems_item_gui.equipment_table.children) do
		--print("'"..elem.sprite.."'")
		if elem.sprite ~="" and elem.sprite ~="transparent32" and global.items[elem.sprite].func then
			elem.mouse_button_filter = {"left"}
		else
			elem.mouse_button_filter = {"button-9"}
		end
	end
end
function unlock_items(player)
	for _, elem in pairs(player.gui.left.rpgitems_item_gui.equipment_table.children) do
		elem.mouse_button_filter = {"right"}
	end
end



function style_item_button(elem)
	elem.style.width = 30
	elem.style.height = 30
	elem.style.top_padding = 0
	elem.style.right_padding = 0
	elem.style.left_padding = 0
	elem.style.bottom_padding = 0
end

function remove_parts(force,itemname, only_calculate_price)
	local price = global.items[itemname].price*(global.price_mult or settings.global["rpgitems_price_mult"].value)
	local tableremove = {}
	if global.items[itemname].parts then
		for _, part in pairs(global.items[itemname].parts) do
			local removed_amount = 0
			local inventory = only_calculate_price or global.forces[force.name].items
			for i, data in pairs( inventory ) do
				if removed_amount < part.count then
					if data.item == part.name then
						if data.count == 1 then
							--if not only_calculate_price then
								--table.remove(global.forces[player.force.name].items,i)
								inventory[i] = nil
							--end
							removed_amount = removed_amount +1
						else
							local temp = math.min(data.count, part.count-removed_amount)
							--if not only_calculate_price then
								data.count = data.count - temp
								if data.count == 0 then
									--table.remove(global.forces[player.force.name].items,i)
									inventory[i] = nil
								end
							--end
							removed_amount = removed_amount + temp
						end
					end
				end
			end
			for i=1, (part.count - removed_amount) do
				price = price + remove_parts(force,part.name, only_calculate_price)
			end
		end
	end
	return price
end

function recursive_can_insert (force,itemname)
	local cleared_slots = 0
	local price = global.items[itemname].price*(global.price_mult or settings.global["rpgitems_price_mult"].value)
	if global.items[itemname].parts then
		for _, part in pairs(global.items[itemname].parts) do
			local removed_amount = 0
			for i, data in pairs( global.forces[force.name].items ) do
				if removed_amount < part.count then
					if data.item == part.name then
						if data.count == 1 then
							cleared_slots = cleared_slots + 1
							removed_amount = removed_amount +1
						else
							local temp = math.min(data.count, part.count-removed_amount)

							--data.count = data.count - temp
							if data.count == temp then
								cleared_slots = cleared_slots + 1
							end

							removed_amount = removed_amount + temp
						end
					end
				end
			end
			for i=1, (part.count - removed_amount) do
				cleared_slots = cleared_slots + recursive_can_insert(force,part.name)
			end
		end
	end
	return cleared_slots
end

function can_insert_item(force, item)
	if table_length(global.forces[force.name].items) < 4+global.forces[force.name].bonus_slots then
		return true
	elseif global.items[item].stack_size then
		for _, data in pairs(global.forces[force.name].items) do
			if data.item == item and (data.count or 1) < (global.items[item].stack_size or 1) then
				return true
			end
		end
	else
		if recursive_can_insert(force,item)>0 then
			return true
		end
	end
	return false
end

function get_sell_price(itemname)
	local price = global.items[itemname].price*(global.price_mult or settings.global["rpgitems_price_mult"].value)
	if global.items[itemname].parts then
		for _, part in pairs(global.items[itemname].parts) do
			price = price + get_sell_price(part.name) * part.count
		end
	end
	return price
end

function buy_item(force, itemname, only_calculate_price)
	if only_calculate_price then
		only_calculate_price = deepcopy(global.forces[force.name].items)
	end
	local price = remove_parts(force,itemname,only_calculate_price)
	if only_calculate_price then
		return price
	elseif global.forces[force.name].money >= price and can_insert_item(force, itemname) then
		global.forces[force.name].items = sort_items(global.forces[force.name].items)
		global.forces[force.name].money = global.forces[force.name].money - price
		insert_item(force,itemname)
		update_items(force)
	end
end

function open_market(player, selected_item)
	if not selected_item then
		if player.gui.center.rpgitems_market and player.gui.center.rpgitems_market.children[2] then
			selected_item = player.gui.center.rpgitems_market.children[2].name
		end
	end
	if player.gui.center.rpgitems_market then player.gui.center.rpgitems_market.destroy() end
	local gui = player.gui.center.add{type="frame", name="rpgitems_market", direction = "vertical"}
	gui.style.horizontal_align = "center"
	--gui.style.width = 600
	local table = gui.add{type="table", name = "market_table", column_count = 8}
	--table.style.minimal_height = 300
	local excluded_items = {}
	for name, data in pairs(global.items) do
		if data.parts and (not data.tech_requirement or player.force.technologies[data.tech_requirement].researched) then
			for _, data2 in pairs(data.parts) do
				excluded_items[data2.name] = true
			end
		end
	end
	for name, data in pairs(global.items) do
		if (not excluded_items[name] or global.items[name].always_show_in_main_list)
		and
		(
			not global.items[name].requires
			or
			(
				game.active_mods[global.items[name].requires]
				and
				(
					not global.items[name].andversion
					or tonumber(game.active_mods[global.items[name].requires]:sub(-2)) >= global.items[name].andversion
				)
			)
		)
		and
		(
			not global.items[name].conflicts
			or not
			(
				game.active_mods[global.items[name].conflicts]
				and
				(
					not global.items[name].andversion
					or tonumber(game.active_mods[global.items[name].conflicts]:sub(-2)) >= global.items[name].andversion
				)
			)
		)
		and (not data.tech_requirement or player.force.technologies[data.tech_requirement].researched)
		then
			local button
			if name == "rpgitems_bonus_slot" then
				button = table.add{type="sprite-button", name = name, number=50000+global.forces[player.force.name].bonus_slots*10000*(global.price_mult or settings.global["rpgitems_price_mult"].value), sprite = name, style = "quick_bar_slot_button"}
			else
				local style = "quick_bar_slot_button"
				if buy_item(player.force,name,true) < get_sell_price(name) then
					--style = "tool_button" --solid white
					--style = "highlighted_tool_button" --thicker? solid orange
					--style = "search_mods_button" --solid white
					--style = "side_menu_button_hovered" --solid orange
					--style = "recipe_slot_button" --ultrathin white
					--style = "frame_button" --thick strong gap
					--style = "drop_target_button" --dotted blue
					--style = "slot_button" --ultrathin white
					--style = "inline_icon_slot" --no border/background
					--style = "slot_with_filter_button" --ultrathin blue
					--style = "not_available_slot_button" --ultrathin red
					--style = "overloaded_crafting_machine_slot_button" --ultrathin yellow
					--style = "promised_crafting_queue_slot" --ultrathin blue
					--style = "not_accessible_station_in_station_selection" --inverted dark
					--style = "button_with_shadow" --white
					--style = "train_schedule_fulfilled_item_select_button" --big green
					--style = "quick_bar_slot_button"
					--style = "shortcut_bar_button" -- thin solid white
					--style = "shortcut_bar_button_small"
					--style = "shortcut_bar_button_blue"
					--style = "shortcut_bar_button_red"
					style = "shortcut_bar_button_green"
					--style = "shortcut_bar_expand_button"
				end
				button = table.add{type="sprite-button", name = name, number=buy_item(player.force,name,true), sprite = name, style = style}
			end
			button.tooltip = data.name.."\n\n"..data.description
			style_item_button(button)
			button.style.width = 50
			button.style.height = 50
		end
	end
	if selected_item then
		local parts_table = gui.add{type="flow", name = selected_item}
		parts_table.style.top_margin = 30
		--parts_table.style.width = 600
		parts_table.style.horizontally_stretchable = true
		parts_table.style.horizontal_align = "center"
		--local test = parts_table.add{type="label", name="asd", caption="ASD"}
		--test.style.horizontal_align = "center"
		add_parts_to_gui(player.force,selected_item, parts_table,1)
	end
	player.opened = gui
end
function get_amount_in_inventory(force,item)
	local count = 0
	for i, data in pairs( global.forces[force.name].items ) do
		if data.item == item then
			count = count + data.count
		end
	end
	return count
end
function add_parts_to_gui(force,item, gui, amount)
	local main_flow = gui.add{type="flow", name=item, direction = "vertical"}
	main_flow.style.horizontal_align = "center"
	local flow = main_flow.add{type="flow", name="market_buy_item", direction = "vertical"}
	flow.style.horizontal_align = "center"
	local inventory_amount = get_amount_in_inventory(force,item)
	local style = "quick_bar_slot_button"
	if inventory_amount > 0 then
		style = "shortcut_bar_button_green"
	end
	local button = flow.add{type="sprite-button", name=item, sprite = item, number = buy_item(force,item,true), style = style}
	button.tooltip = global.items[item].name.."\n\n"..global.items[item].description
	style_item_button(button)
	button.style.width = 50
	button.style.height = 50
	local label = flow.add{type="label", name = "cap", caption = inventory_amount.."/"..amount}
	label.style.font = "default-bold"
	if inventory_amount < amount then
		label.style.font_color = {r=0.7,g=0.7,b=0.7}
	end
	if global.items[item].parts then
		local partstable = main_flow.add{type="table", name = "parts", column_count = #global.items[item].parts}
		partstable.style.cell_padding =7
		partstable.vertical_centering =false
		partstable.draw_vertical_lines=true
		partstable.style.horizontal_align = "center"
		for _, part in pairs(global.items[item].parts) do
			add_parts_to_gui(force,part.name, partstable, part.count)
		end
	end


end
function create_equipment_gui(player)
	if player.gui.left.rpgitems_item_gui then player.gui.left.rpgitems_item_gui.destroy() end
	local gui = player.gui.left.add{type = "frame", name= "rpgitems_item_gui", direction= "vertical"}
	--gui.style.width = 75
	gui.style.left_padding = 2
	gui.style.right_padding = 2
	gui.style.horizontal_align = "center"
	local cols = 2
	if 4+global.forces[player.force.name].bonus_slots <= 6 then
		cols = 2
	elseif 4+global.forces[player.force.name].bonus_slots <= 12 then
		cols = 3
	else
		cols = 4
	end
	local table = gui.add{type = "table", name = "equipment_table", column_count = cols}
	for i=1,4+global.forces[player.force.name].bonus_slots do
		local button = table.add{type = "sprite-button", name = "item_"..i, style = "recipe_slot_button"}
		style_item_button(button)
		button.style.height = 27
		button.style.width = 27
	end


	local i=1
	for _, data in pairs(global.forces[player.force.name].items) do
		player.gui.left.rpgitems_item_gui.equipment_table["item_"..i].sprite = data.item
		player.gui.left.rpgitems_item_gui.equipment_table["item_"..i].tooltip = global.items[data.item].name.."\n\n"..global.items[data.item].description
		if global.items[data.item].stack_size then
			player.gui.left.rpgitems_item_gui.equipment_table["item_"..i].number = data.count
		else
			player.gui.left.rpgitems_item_gui.equipment_table["item_"..i].number = nil
		end
		player.gui.left.rpgitems_item_gui.equipment_table["item_"..i].clear()
		if global.forces[player.force.name].item_cooldowns[data.item] then
			local bar = player.gui.left.rpgitems_item_gui.equipment_table["item_"..i].add{type = "progressbar", name = "cd", value = (global.forces[player.force.name].item_cooldowns[data.item]/global.items[data.item].cooldown)}
			bar.style.color = {r=1,g=1,b=0}
			bar.style.width = 24
			bar.style.top_padding = 0
			bar.style.bottom_padding = 0
			bar.style.left_padding = 0
			bar.style.right_padding = 0
			bar.style.top_margin = 0
			bar.style.bottom_margin = 0
			bar.style.left_margin = -1
			bar.style.right_margin = 0
		end
		i=i+1
	end
	for j=i, 4+global.forces[player.force.name].bonus_slots do
		player.gui.left.rpgitems_item_gui.equipment_table["item_"..j].sprite = "transparent32"
		player.gui.left.rpgitems_item_gui.equipment_table["item_"..i].tooltip = ""
		player.gui.left.rpgitems_item_gui.equipment_table["item_"..i].number = nil
		player.gui.left.rpgitems_item_gui.equipment_table["item_"..i].clear()
	end
	gui.add{type = "label", name ="money", caption = math.floor(global.forces[player.force.name].money).."[img=rpgitems-coin]"}
	if player.gui.center.rpgitems_market then
		unlock_items(player)
	else
		lock_items(player)
	end
end

function deepcopy(orig)
		local orig_type = type(orig)
		local copy
		if orig_type == 'table' then
				copy = {}
				for orig_key, orig_value in next, orig, nil do
						copy[deepcopy(orig_key)] = deepcopy(orig_value)
				end
				setmetatable(copy, deepcopy(getmetatable(orig)))
		else -- number, string, boolean, etc
				copy = orig
		end
		return copy
end
