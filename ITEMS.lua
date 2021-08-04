local ceil = math.ceil
local floor = math.floor


---@param raw_data table
---@return table|boolean
local function merge_localization(raw_data)
	local final_data = {}
	if #raw_data >= 380 then
			log("Too much data")
			return false
	elseif #raw_data > 10 then
		for i=1, ceil(#raw_data/20)+1 do
			final_data[i] = {""}
		end
		local i1 = 1
		local i2 = 2
		for _, _data in pairs(raw_data) do
			final_data[i1][i2] = _data
			if i2 >= 20 then
		    i1 = i1 + 1
		    i2 = 2
			else
		    i2 = i2 + 1
			end
		end
	else
		final_data = raw_data
	end

	return final_data
end

function make_items()
	global.items = {
		["rpgitems_health_potion"] = {
			effects = {},
			name = {"", "[", {"rpg-items.potion"}, "]"},
			description = {"rpg-items-description.potion"},
			price = 250,
			stack_size = 10,
			cooldown = 30,
			consumed = true,
			always_show_in_main_list = true,
			func = true
		},
		["rpgitems_mana_potion"] = {
			effects = {},
			name = {"", "[", {"rpg-items.mana_potion"}, "]"},
			description = {"rpg-items-description.mana_potion"},
			price = 250,
			stack_size = 10,
			cooldown = 30,
			consumed = true,
			requires = "spell-pack",
			andversion = 18,
			always_show_in_main_list = true,
			func = true
		},
		["rpgitems_amnesia_book"] = {
			effects = {},
			name = {"", "[", {"rpg-items.amnesia_book"}, "]"},
			description = {"rpg-items-description.amnesia_book"},
			price = 35000,
			stack_size = 1,
			cooldown = 30,
			consumed = true,
			always_show_in_main_list = true,
			func = true
		},
		["rpgitems_shoes"] = {
			effects = {{type = "force", modifier = "character_running_speed_modifier", value = 0.2, unique = "Shoes"}},
			name = {"", "[", {"rpg-items.shoes"}, "]"},
			price = 10000,
			stack_size = nil,
			cooldown = nil,
			consumed = nil
		},
		["rpgitems_boots_0"] = {
			effects = {
				{type = "force", modifier = "character_running_speed_modifier", value = 0.3, unique = "Shoes"},
				{type = "other", modifier = "momentum", value = 1, unique = "Momentum"}
			},
			name = {"", "[", {"rpg-items.boots_0"}, "]"},
			price = 30000,
			parts = {{name = "rpgitems_shoes", count = 1}}
		},
		["rpgitems_boots_1"] = {
			effects = {
				{type = "other", modifier = "armor", value = 20},
				{type = "force", modifier = "character_running_speed_modifier", value = 0.3, unique = "Shoes"}
			},
			name = {"", "[", {"rpg-items.boots_1"}, "]"},
			price = 12000,
			parts = {{name = "rpgitems_shoes", count = 1}, {name = "rpgitems_armor_0", count = 1}}
		},
		["rpgitems_boots_2"] = {
			effects = {
				{type = "force", modifier = "gun_speed_modifier", value = 0.3},
				{type = "force", modifier = "character_running_speed_modifier", value = 0.3, unique = "Shoes"}
			},
			name = {"", "[", {"rpg-items.boots_2"}, "]"},
			price = 12000,
			parts = {{name = "rpgitems_shoes", count = 1}, {name = "rpgitems_attackspeed_0", count = 1}}
		},
		["rpgitems_golden_amulet"] = {
			effects = {{type = "other", modifier = "income", value = 0.25}},
			name = {"", "[", {"rpg-items.golden_amulet"}, "]"},
			price = 10000,
			stack_size = nil,
			cooldown = nil,
			consumed = nil,
			func = nil
		},
		["rpgitems_spineripper"] = {
			effects = {
				{type = "force", modifier = "ammo_damage_modifier", value = 1}, {type = "other", modifier = "crit", value = 0.1},
				{type = "other", modifier = "critdamage", value = 0.5, unique = "Spineripper"}
			},
			name = {"", "[", {"rpg-items.spineripper"}, "]"},
			price = 20000,
			parts = {{name = "rpgitems_damage_1", count = 1}, {name = "rpgitems_crit_1", count = 1}}
		},
		["rpgitems_wind_0"] = {
			effects = {
				{type = "force", modifier = "gun_speed_modifier", value = 0.3}, {type = "other", modifier = "crit", value = 0.05} -- , unique = "Immolation"},
			},
			name = {"", "[", {"rpg-items.wind_0"}, "]"},
			price = 15000,
			parts = {
				{name = "rpgitems_crit_0", count = 1}, {name = "rpgitems_attackspeed_0", count = 1}
				-- {name = "rpgitems_regeneration_0", count = 1},
				-- {name = "rpgitems_manareg_0", count = 1},
			}
		},
		["rpgitems_wind_1"] = {
			effects = {
				{type = "force", modifier = "gun_speed_modifier", value = 0.50}, {type = "other", modifier = "crit", value = 0.09},
				{type = "other", modifier = "critdamage", value = 0.05},
				{type = "force", modifier = "character_running_speed_modifier", value = 0.05}
			},
			name = {"", "[", {"rpg-items.wind_1"}, "]"},
			price = 25000,
			parts = {
				-- {name = "rpgitems_crit_0", count = 1},
				-- {name = "rpgitems_crit_1", count = 1},
				{name = "rpgitems_wind_0", count = 1}, {name = "rpgitems_attackspeed_0", count = 1}
				-- {name = "rpgitems_manareg_0", count = 1},
			}
		},
		["rpgitems_lifesteal_0"] = {
			effects = {
				{type = "force", modifier = "turret_attack_modifier", value = 0.2, turret = "character"},
				{type = "other", modifier = "lifesteal", value = 0.1}
		},
			name = {"", "[", {"rpg-items.lifesteal_0"}, "]"},
			price = 10000,
			parts = {{name = "rpgitems_damage_0", count = 1}, {name = "rpgitems_regeneration_0", count = 1}}
		},
		["rpgitems_lifesteal_1"] = {
			effects = {
				{type = "force", modifier = "turret_attack_modifier", value = 0.5, turret = "character"},
				{type = "other", modifier = "pctlifesteal", value = 1}
			},
			name = {"", "[", {"rpg-items.lifesteal_1"}, "]"},
			price = 10000,
			parts = {{name = "rpgitems_damage_1", count = 1}, {name = "rpgitems_lifesteal_0", count = 1}}
		},
		["rpgitems_staff"] = {
			effects = {
				{type = "force", modifier = "turret_attack_modifier", value = 0.2, turret = "character"},
				{type = "other", modifier = "crit", value = 0.07},
				{type = "force", modifier = "character_health_bonus", value = 250},
				-- {type = "other", modifier = "regen", value = 5},
				-- {type = "other", modifier = "pctregen", value = 0.5},
				-- {type = "spellpack", modifier = "max_spirit", value = 50},
				{type = "other", modifier = "armor", value = 15}, -- {type = "spellpack", modifier = "cdr", value = 0.1},
				{type = "other", modifier = "stun", value = 0.02}
				-- {type = "other", modifier = "revive", value = 1, unique = "Crusader"},
			},
			name = {"", "[", {"rpg-items.staff"}, "]"},
			description = {"rpg-items-description.staff"},
			-- cooldown = 300,
			conflicts = "spell-pack",
			andversion = 18,
			price = 9000,
			parts = {
				{name = "rpgitems_crit_1", count = 1}, {name = "rpgitems_armor_health", count = 1}
				-- {name = "rpgitems_golden_amulet", count = 1},
			}
		},
		["rpgitems_staff_spepa"] = {
			effects = {
				{type = "force", modifier = "turret_attack_modifier", value = 0.2, turret = "character"},
				{type = "other", modifier = "crit", value = 0.07},
				{type = "force", modifier = "character_health_bonus", value = 250},
				-- {type = "other", modifier = "regen", value = 5},
				-- {type = "other", modifier = "pctregen", value = 0.5},
				-- {type = "spellpack", modifier = "max_spirit", value = 50},
				{type = "other", modifier = "armor", value = 15}, {type = "spellpack", modifier = "cdr", value = 0.1},
				{type = "other", modifier = "stun", value = 0.02, unique = "Madness"}
				-- {type = "other", modifier = "revive", value = 1, unique = "Crusader"},
			},
			name = {"", "[", {"rpg-items.staff"}, "]"},
			description = {"rpg-items-description.staff_spepa"},
			-- cooldown = 300,
			requires = "spell-pack",
			andversion = 18,
			price = 9000,
			parts = {
				{name = "rpgitems_crit_1", count = 1}, {name = "rpgitems_armor_health", count = 1}
				-- {name = "rpgitems_golden_amulet", count = 1},
			}
		},
		["rpgitems_yellow_ammo"] = {
			effects = {
				{type = "force", modifier = "ammo_damage_modifier", value = 0.20, ammo = "bullet"},
				{type = "giveitem", item = "firearm-magazine", per_second = 0.1}
			},
			name = {"", "[", {"rpg-items.yellow_ammo"}, "]"},
			price = 20000
		},
		["rpgitems_red_ammo"] = {
			effects = {
				{type = "force", modifier = "ammo_damage_modifier", value = 0.30, ammo = "bullet"},
				{type = "giveitem", item = "piercing-rounds-magazine", per_second = 0.1}
			},
			name = {"", "[", {"rpg-items.red_ammo"}, "]"},
			price = 20000,
			parts = {{name = "rpgitems_yellow_ammo", count = 1}}
		},
		["rpgitems_green_ammo"] = {
			effects = {
				{type = "force", modifier = "ammo_damage_modifier", value = 0.40, ammo = "bullet"},
				{type = "giveitem", item = "uranium-rounds-magazine", per_second = 0.1}
			},
			name = {"", "[", {"rpg-items.green_ammo"}, "]"},
			price = 20000,
			parts = {{name = "rpgitems_red_ammo", count = 1}},
			tech_requirement = "uranium-ammo"
		},
		["rpgitems_tyrs_hand"] = {
			effects = {
				{type = "force", modifier = "turret_attack_modifier", value = 0.20, turret = "character"},
				{type = "force", modifier = "gun_speed_modifier", value = 0.4}, {type = "other", modifier = "crit", value = 0.07},
				{type = "force", modifier = "character_health_bonus", value = 250}
			},
			name = {"", "[", {"rpg-items.tyrs_hand"}, "]"},
			price = 7000,
			parts = {
				-- {name = "rpgitems_attackspeed_0", count = 2},
				{name = "rpgitems_damage_0", count = 1}, -- {name = "rpgitems_crit_0", count = 1},
				{name = "rpgitems_wind_0", count = 1}, {name = "rpgitems_health_0", count = 1}
			}
		},
		["rpgitems_armor_health"] = {
			effects = {
				{type = "force", modifier = "character_health_bonus", value = 200}, {type = "other", modifier = "armor", value = 15}
			},
			name = {"", "[", {"rpg-items.armor_health"}, "]"},
			price = 10000,
			parts = {{name = "rpgitems_armor_0", count = 1}, {name = "rpgitems_health_0", count = 1}}
		},
		["rpgitems_armor_2"] = {
			effects = {
				{type = "force", modifier = "character_health_bonus", value = 500},
				{type = "other", modifier = "armor", value = 45}, {type = "other", modifier = "regen", value = 5}
			},
			name = {"", "[", {"rpg-items.armor2"}, "]"},
			price = 13000,
			parts = {{name = "rpgitems_armor_health", count = 2}, {name = "rpgitems_regeneration_0", count = 1}}
		},
		["rpgitems_regeneration_1"] = {
			effects = {
				{type = "force", modifier = "character_health_bonus", value = 200},
				{type = "other", modifier = "pctregen", value = 0.5}
			},
			name = {"", "[", {"rpg-items.regeneration_1"}, "]"},
			price = 4000,
			parts = {{name = "rpgitems_health_0", count = 1}, {name = "rpgitems_regeneration_0", count = 1}}
		},

		["rpgitems_bulwark"] = {
			effects = {
				{type = "force", modifier = "character_health_bonus", value = 800},
				{type = "other", modifier = "regen", value = 10}, -- {type = "other", modifier = "repair", value = 0.15},
				{type = "other", modifier = "pctregen", value = 1.5, unique = "Aqua vita"}
			},
			name = {"", "[", {"rpg-items.bulwark"}, "]"},
			price = 12000,
			parts = {
				{name = "rpgitems_health_1", count = 1}, {name = "rpgitems_regeneration_1", count = 1},
				{name = "rpgitems_regeneration_0", count = 2}
				-- {name = "rpgitems_repair", count = 1}
			}
		},
		["rpgitems_horned_helmet"] = {
			effects = {
				{type = "force", modifier = "ammo_damage_modifier", value = 0.25},
				{type = "force", modifier = "character_health_bonus", value = 300},
				{type = "other", modifier = "armor", value = 20}, {type = "other", modifier = "thorns", value = 90}
			},
			name = {"", "[", {"rpg-items.horned_helmet"}, "]"},
			price = 10000,
			parts = {
				{name = "rpgitems_spiked_collar", count = 1}, {name = "rpgitems_armor_health", count = 1},
				{name = "rpgitems_damage_0", count = 1}
			}
		},
		["rpgitems_crusader_spepa"] = {
			effects = {
				{type = "force", modifier = "character_health_bonus", value = 250},
				{type = "other", modifier = "armor", value = 20}, {type = "other", modifier = "regen", value = 5},
				{type = "spellpack", modifier = "max_spirit", value = 50}, {type = "spellpack", modifier = "cdr", value = 0.1},
				{type = "other", modifier = "income", value = 0.3},
				{type = "other", modifier = "revive", value = 5, unique = "Crusader"}
			},
			name = {"", "[", {"rpg-items.crusader"}, "]"},
			-- description = "[color=0.9098,0.7255,0.1373](unique: Crusader)[/color]",
			cooldown = 300,
			requires = "spell-pack",
			andversion = 18,
			price = 11000,
			parts = {
				{name = "rpgitems_armor_health", count = 1},
				{name = "rpgitems_regeneration_0", count = 1},
				{name = "rpgitems_golden_amulet", count = 1}
			}
		},
		["rpgitems_crusader"] = {
			effects = {
				{type = "force", modifier = "character_health_bonus", value = 250},
				{type = "other", modifier = "armor", value = 20},
				{type = "other", modifier = "regen", value = 5},
				{type = "other", modifier = "pctregen", value = 0.5},
				-- {type = "spellpack", modifier = "max_spirit", value = 50},
				-- {type = "spellpack", modifier = "cdr", value = 0.1},
				{type = "other", modifier = "income", value = 0.25},
				{type = "other", modifier = "revive", value = 5, unique = "Crusader"}
			},
			name = {"", "[", {"rpg-items.crusader"}, "]"},
			-- description = "[color=0.9098,0.7255,0.1373](unique: Crusader)[/color]",
			cooldown = 300,
			conflicts = "spell-pack",
			andversion = 18,
			price = 11000,
			parts = {
				{name = "rpgitems_armor_health", count = 1}, {name = "rpgitems_regeneration_0", count = 1},
				{name = "rpgitems_golden_amulet", count = 1}
			}
		},
		["rpgitems_flamecloak_spepa"] = {
			effects = {
				{type = "force", modifier = "ammo_damage_modifier", value = 0.4, ammo = "flamethrower"},
				{type = "force", modifier = "character_health_bonus", value = 250},
				-- {type = "other", modifier = "regen", value = 5},
				-- {type = "other", modifier = "pctregen", value = 0.5},
				-- {type = "spellpack", modifier = "max_spirit", value = 50},
				{type = "other", modifier = "armor", value = 20}, {type = "spellpack", modifier = "cdr", value = 0.1},
				{type = "other", modifier = "immolation", value = 50} -- unique = "Immolation"},
			},
			name = {"", "[", {"rpg-items.flamecloak"}, "]"},
			-- description = "[color=0.7,0.7,0.7]Stun chance is tripled for player attacks[/color]",
			cooldown = 0,
			requires = "spell-pack",
			andversion = 18,
			price = 15000,
			func = true,
			parts = {
				{name = "rpgitems_lavalamp", count = 1}, {name = "rpgitems_armor_health", count = 1},
				-- {name = "rpgitems_regeneration_0", count = 1},
				{name = "rpgitems_manareg_0", count = 1}
			}
		},
		["rpgitems_flamecloak"] = {
			effects = {
				{type = "force", modifier = "ammo_damage_modifier", value = 0.4, ammo = "flamethrower"},
				{type = "force", modifier = "character_health_bonus", value = 250},
				{type = "other", modifier = "armor", value = 20}, {type = "other", modifier = "regen", value = 5},
				-- {type = "other", modifier = "pctregen", value = 0.5},
				-- {type = "spellpack", modifier = "max_spirit", value = 50},
				-- {type = "spellpack", modifier = "cdr", value = 0.1},
				{type = "other", modifier = "immolation", value = 50} -- , unique = "Immolation"},
			},
			name = {"", "[", {"rpg-items.flamecloak"}, "]"},
			-- description = "[color=0.7,0.7,0.7]Stun chance is tripled for player attacks[/color]",
			cooldown = 3,
			conflicts = "spell-pack",
			andversion = 18,
			price = 15000,
			func = true,
			parts = {
				{name = "rpgitems_lavalamp", count = 1},
				{name = "rpgitems_armor_health", count = 1},
				{name = "rpgitems_regeneration_0", count = 1}
				-- {name = "rpgitems_manareg_0", count = 1},
			}
		},
		["rpgitems_crit_1"] = {
			effects = {
				{type = "force", modifier = "ammo_damage_modifier", value = 0.4}, {type = "other", modifier = "crit", value = 0.05}
			},
			name = {"", "[", {"rpg-items.crit_1"}, "]"},
			price = 25000,
			parts = {{name = "rpgitems_damage_0", count = 1}, {name = "rpgitems_crit_0", count = 1}}
		},
		-- ["rpgitems_chardamage_0"] = {
		--	effects = {
		--				--{type = "other", modifier = "chardamage", value = 15},
		--				{type = "force", modifier = "manual_crafting_speed_modifier", value = 0.2}
		--	},
		--	name = "[Wooden club]",
		--	--description = "\n[color=0.7,0.7,0.7]Melee Damage gets multiplied by item damage bonuses[/color]",
		--	price = 8000,
		-- },
		["rpgitems_chardamage_gold"] = {
			effects = {
				{type = "force", modifier = "turret_attack_modifier", value = 0.1, turret = "character"},
				{type = "force", modifier = "manual_crafting_speed_modifier", value = 0.75},
				{type = "other", modifier = "income", value = 0.3}
			},
			-- description = "\n[color=0.7,0.7,0.7]Melee Damage gets multiplied by item damage bonuses[/color]",
			name = {"", "[", {"rpg-items.chardamage_gold"}, "]"},
			price = 16000,
			parts = {{name = "rpgitems_crafting_speed", count = 1}, {name = "rpgitems_golden_amulet", count = 1}}
		},
		["rpgitems_chardamage_gold_reg"] = {
			effects = {
				{type = "force", modifier = "turret_attack_modifier", value = 0.15, turret = "character"},
				{type = "other", modifier = "armor", value = 15}, {type = "other", modifier = "regen", value = 7.5},
				{type = "force", modifier = "manual_crafting_speed_modifier", value = 1.0},
				{type = "force", modifier = "character_reach_distance_bonus", value = 5},
				{type = "other", modifier = "income", value = 0.35}
			},
			name = {"", "[", {"rpg-items.chardamage_gold"}, "]"},
			-- description = "\n[color=0.7,0.7,0.7]Melee Damage gets multiplied by item damage bonuses[/color]",
			price = 10000,
			parts = {
				{name = "rpgitems_chardamage_gold", count = 1}, {name = "rpgitems_regeneration_0", count = 1},
				{name = "rpgitems_armor_0", count = 1}
			}
		},
		["rpgitems_spellpack_neclace"] = {
			effects = {
				{type = "spellpack", modifier = "max_mana", value = 30}, {type = "spellpack", modifier = "mana_reg", value = 0.5},
				{type = "spellpack", modifier = "spirit_reg", value = 0.15}
			},
			requires = "spell-pack",
			andversion = 18,
			name = {"", "[", {"rpg-items.spellpack_neclace"}, "]"},
			price = 14000,
			parts = {{name = "rpgitems_mana_0", count = 1}, {name = "rpgitems_manareg_0", count = 1}}
		},
		["rpgitems_multitool"] = {
			effects = {
				{type = "force", modifier = "manual_mining_speed_modifier", value = 1.5},
				{type = "force", modifier = "manual_crafting_speed_modifier", value = 1}
			},
			name = {"", "[", {"rpg-items.multitool"}, "]"},
			price = 12000,
			parts = {{name = "rpgitems_mining_speed", count = 1}, {name = "rpgitems_crafting_speed", count = 1}}
		},
		-- ["rpgitems_book1"] = {
		--	effects = {	{type = "force", modifier = "turret_attack_modifier", value = 0.1},},
		--	name = "[Book with interesting tower Blueprints]",
		--	price = 16000,
		-- },
		["rpgitems_robo_butler"] = {
			effects = {
				{type = "force", modifier = "manual_mining_speed_modifier", value = 2.5},
				{type = "force", modifier = "manual_crafting_speed_modifier", value = 1.75},
				-- {type = "force", modifier = "turret_attack_modifier", value = 0.20},
				{type = "force", modifier = "character_reach_distance_bonus", value = 10},
				{type = "other", modifier = "repair", value = 0.15}
				-- {type = "other", modifier = "energy", value = 100},
			},
			name = {"", "[", {"rpg-items.robo_butler"}, "]"},
			price = 15000,
			parts = {
				-- {name = "rpgitems_book1", count = 1},
				-- {name = "rpgitems_battery", count = 1},
				{name = "rpgitems_multitool", count = 1},
				{name = "rpgitems_repair", count = 1},
				{name = "rpgitems_battery", count = 1}

			}
		},
		["rpgitems_rainbow_drill"] = {
			effects = {
				{type = "force", modifier = "manual_mining_speed_modifier", value = 2.0},
				{type = "force", modifier = "manual_crafting_speed_modifier", value = 1.0},
				{type = "giveitem", item = "steel-plate", per_second = 0.3},
				{type = "giveitem", item = "iron-plate", per_second = 0.5},
				{type = "giveitem", item = "copper-plate", per_second = 0.5},
				{type = "giveitem", item = "stone-brick", per_second = 0.5}
			},
			name = {"", "[", {"rpg-items.rainbow_drill"}, "]"},
			price = -15000,
			parts = {
				{name = "rpgitems_steel_plates_generator", count = 1}, {name = "rpgitems_iron_plates_generator", count = 1},
				{name = "rpgitems_copper_plates_generator", count = 1}, {name = "rpgitems_stone_bricks_generator", count = 1}
			}
		},
		["rpgitems_iron_generator"] = {
			effects = {
				{type = "force", modifier = "manual_mining_speed_modifier", value = 0.2},
				{type = "force", modifier = "manual_crafting_speed_modifier", value = 0.1},
				{type = "giveitem", item = "iron-ore", per_second = 0.5}
			},
			name = {"", "[", {"rpg-items.iron_generator"}, "]"},
			price = 6000
		},
		["rpgitems_iron_plates_generator"] = {
			effects = {
				{type = "force", modifier = "manual_mining_speed_modifier", value = 0.4},
				{type = "force", modifier = "manual_crafting_speed_modifier", value = 0.2},
				{type = "giveitem", item = "iron-plate", per_second = 0.5}
			},
			name = {"", "[", {"rpg-items.iron_plates_generator"}, "]"},
			price = 5000,
			parts = {{name = "rpgitems_iron_generator", count = 1}}
		},
		["rpgitems_steel_plates_generator"] = {
			effects = {
				{type = "force", modifier = "manual_mining_speed_modifier", value = 0.8},
				{type = "force", modifier = "manual_crafting_speed_modifier", value = 0.4},
				{type = "giveitem", item = "steel-plate", per_second = 0.3}
			},
			name = {"", "[", {"rpg-items.rpgitems_steel_plates_generator"}, "]"},
			price = 5000,
			parts = {{name = "rpgitems_iron_plates_generator", count = 3}}
		},
		["rpgitems_copper_generator"] = {
			effects = {
				{type = "force", modifier = "manual_mining_speed_modifier", value = 0.2},
				{type = "force", modifier = "manual_crafting_speed_modifier", value = 0.1},
				{type = "giveitem", item = "copper-ore", per_second = 0.5}
			},
			name = {"", "[", {"rpg-items.copper_generator"}, "]"},
			price = 6000
		},
		["rpgitems_copper_plates_generator"] = {
			effects = {
				{type = "force", modifier = "manual_mining_speed_modifier", value = 0.4},
				{type = "force", modifier = "manual_crafting_speed_modifier", value = 0.2},
				{type = "giveitem", item = "copper-plate", per_second = 0.5}
			},
			name = {"", "[", {"rpg-items.copper_plates_generator"}, "]"},
			price = 5000,
			parts = {{name = "rpgitems_copper_generator", count = 1}}
		},
		["rpgitems_stone_generator"] = {
			effects = {
				{type = "force", modifier = "manual_mining_speed_modifier", value = 0.2},
				{type = "force", modifier = "manual_crafting_speed_modifier", value = 0.1},
				{type = "giveitem", item = "stone", per_second = 1}
			},
			name = {"", "[", {"rpg-items.stone_generator"}, "]"},
			price = 5000
		},
		["rpgitems_stone_bricks_generator"] = {
			effects = {
				{type = "force", modifier = "manual_mining_speed_modifier", value = 0.4},
				{type = "force", modifier = "manual_crafting_speed_modifier", value = 0.2},
				{type = "giveitem", item = "stone-brick", per_second = 0.5}
			},
			name = {"", "[", {"rpg-items.stone_bricks_generator"}, "]"},
			price = 5000,
			parts = {{name = "rpgitems_stone_generator", count = 1}}
		},
		-- ["rpgitems_coal_generator"] = {
		--	effects = {	{type = "force", modifier = "manual_mining_speed_modifier", value = 0.5},
		--				{type = "force", modifier = "manual_crafting_speed_modifier", value = 0.5},
		--				{type = "giveitem", item = "coal", per_second = 0.5}},
		--	name = "[Automated Coal Miner]",
		--	price = 20000,
		-- },
		-- ["rpgitems_uranium_generator"] = {
		--	effects = {	{type = "force", modifier = "manual_mining_speed_modifier", value = 0.5},
		--				{type = "force", modifier = "manual_crafting_speed_modifier", value = 0.5},
		--				{type = "giveitem", item = "uranium-ore", per_second = 1}},
		--	name = "[Automated Uranium Miner]",
		--	price = 30000,
		-- },
		["rpgitems_factorio_bronze"] = {
			effects = {
				-- {type = "force", modifier = "ammo_damage_modifier", value = 0.1, turret = "character"},
				-- {type = "force", modifier = "gun_speed_modifier", value = 0.1, turret = "character"},
				{type = "force", modifier = "character_health_bonus", value = 25, unique = 91},
				{type = "force", modifier = "character_running_speed_modifier", value = 0.025, unique = 92},
				{type = "force", modifier = "manual_mining_speed_modifier", value = 0.2, unique = 93},
				{type = "force", modifier = "manual_crafting_speed_modifier", value = 0.2, unique = 94},
				{type = "force", modifier = "character_inventory_slots_bonus", value = 1, unique = 95},
				{type = "force", modifier = "character_reach_distance_bonus", value = 1, unique = 96},
				-- {type = "other", modifier = "pctlifesteal", value = 1},
				-- {type = "other", modifier = "crit", value = 0.05},
				-- {type = "other", modifier = "critdamage", value = 0.1},
				-- {type = "other", modifier = "armor", value = 10},
				-- {type = "other", modifier = "thorns", value = 1},
				-- {type = "other", modifier = "regen", value = 1},
				-- {type = "other", modifier = "chardamage", value = 1},
				{type = "other", modifier = "repair", value = 0.04, unique = 97},
				-- {type = "other", modifier = "pctlifesteal", value = 1},
				{type = "other", modifier = "income", value = 0.05, unique = 98},
				{type = "other", modifier = "energy", value = 50, unique = 99}
			},
			name = {"", "[", {"rpg-items.factorio_bronze"}, "]"},
			price = 25000
			-- parts = {
			--	--{name = "rpgitems_battery", count = 1},
			--	{name = "rpgitems_multitool", count = 1},
			--	{name = "rpgitems_golden_amulet", count = 1},
			-- }
		},
		["rpgitems_factorio_silver"] = {
			effects = {
				-- {type = "force", modifier = "ammo_damage_modifier", value = 0.1, turret = "character"},
				-- {type = "force", modifier = "gun_speed_modifier", value = 0.1, turret = "character"},
				{type = "force", modifier = "character_health_bonus", value = 50, unique = 91},
				{type = "force", modifier = "character_running_speed_modifier", value = 0.05, unique = 92},
				{type = "force", modifier = "manual_mining_speed_modifier", value = 0.4, unique = 93},
				{type = "force", modifier = "manual_crafting_speed_modifier", value = 0.4, unique = 94},
				{type = "force", modifier = "character_inventory_slots_bonus", value = 2, unique = 95},
				{type = "force", modifier = "character_reach_distance_bonus", value = 2, unique = 96},
				-- {type = "other", modifier = "pctlifesteal", value = 1},
				-- {type = "other", modifier = "crit", value = 0.05},
				-- {type = "other", modifier = "critdamage", value = 0.1},
				-- {type = "other", modifier = "armor", value = 10},
				-- {type = "other", modifier = "thorns", value = 1},
				-- {type = "other", modifier = "regen", value = 1},
				-- {type = "other", modifier = "chardamage", value = 1},
				{type = "other", modifier = "repair", value = 0.08, unique = 97},
				-- {type = "other", modifier = "pctlifesteal", value = 1},
				{type = "other", modifier = "income", value = 0.1, unique = 98},
				{type = "other", modifier = "energy", value = 100, unique = 99}
			},
			name = {"", "[", {"rpg-items.factorio_silver"}, "]"},
			price = 20000,
			parts = {
				{name = "rpgitems_factorio_bronze", count = 1}
				-- {name = "rpgitems_battery", count = 1},
			}
		},
		["rpgitems_factorio_gold"] = {
			effects = {
				-- {type = "force", modifier = "ammo_damage_modifier", value = 0.1, turret = "character"},
				-- {type = "force", modifier = "gun_speed_modifier", value = 0.1, turret = "character"},
				{type = "force", modifier = "character_health_bonus", value = 125, unique = 91},
				{type = "force", modifier = "character_running_speed_modifier", value = 0.125, unique = 92},
				{type = "force", modifier = "manual_mining_speed_modifier", value = 1, unique = 93},
				{type = "force", modifier = "manual_crafting_speed_modifier", value = 1, unique = 94},
				{type = "force", modifier = "character_inventory_slots_bonus", value = 5, unique = 95},
				{type = "force", modifier = "character_reach_distance_bonus", value = 5, unique = 96},
				-- {type = "other", modifier = "pctlifesteal", value = 1},
				-- {type = "other", modifier = "crit", value = 0.05},
				-- {type = "other", modifier = "critdamage", value = 0.1},
				-- {type = "other", modifier = "armor", value = 10},
				-- {type = "other", modifier = "thorns", value = 1},
				-- {type = "other", modifier = "regen", value = 1},
				-- {type = "other", modifier = "chardamage", value = 1},
				{type = "other", modifier = "repair", value = 0.2, unique = 97},
				-- {type = "other", modifier = "pctlifesteal", value = 1},
				{type = "other", modifier = "income", value = 0.25, unique = 98},
				{type = "other", modifier = "energy", value = 250, unique = 99}
			},
			name = {"", "[", {"rpg-items.factorio_gold"}, "]"},
			price = 45000,
			parts = {
				{name = "rpgitems_factorio_silver", count = 1}
				-- {name = "rpgitems_repair", count = 1},
			}
		},
		["rpgitems_cards_spepa"] = {
			effects = {
				{type = "other", modifier = "regen", value = 5}, {type = "spellpack", modifier = "mana_reg", value = 0.5},
				{type = "spellpack", modifier = "spirit_reg", value = 0.2}, {type = "spellpack", modifier = "cdr", value = 0.1},
				{type = "other", modifier = "repair", value = 0.15}, {type = "other", modifier = "energy", value = 250}
			},
			name = {"", "[", {"rpg-items.cards"}, "]"},
			requires = "spell-pack",
			andversion = 18,
			price = 10000,
			parts = {
				{name = "rpgitems_battery", count = 1}, {name = "rpgitems_manareg_0", count = 1},
				{name = "rpgitems_regeneration_0", count = 1}, {name = "rpgitems_repair", count = 1}
			}
		},
		["rpgitems_cards"] = {
			effects = {
				{type = "other", modifier = "regen", value = 5}, {type = "other", modifier = "pctregen", value = 0.5},
				{type = "other", modifier = "repair", value = 0.15}, {type = "other", modifier = "energy", value = 250}
				-- {type = "spellpack", modifier = "mana_reg", value = 0.5},
				-- {type = "spellpack", modifier = "spirit_reg", value = 0.2},
				-- {type = "spellpack", modifier = "cdr", value = 0.1},
			},
			name = {"", "[", {"rpg-items.cards"}, "]"},
			conflicts = "spell-pack",
			andversion = 18,
			price = 10000,
			parts = {
				{name = "rpgitems_battery", count = 1}, -- {name = "rpgitems_manareg_0", count = 1},
				{name = "rpgitems_regeneration_0", count = 1}, {name = "rpgitems_repair", count = 1}
			}
		},
		["rpgitems_spellpack_helmet"] = {
			effects = {
				{type = "force", modifier = "ammo_damage_modifier", value = 0.4, ammo = "grenade"},
				{type = "spellpack", modifier = "max_mana", value = 50}, {type = "spellpack", modifier = "mana_reg", value = 1},
				{type = "spellpack", modifier = "spirit_reg", value = 0.3}, {type = "spellpack", modifier = "cdr", value = 0.3}
			},
			requires = "spell-pack",
			andversion = 18,
			name = {"", "[", {"rpg-items.spellpack_helmet"}, "]"},
			price = 25000,
			parts = {{name = "rpgitems_spellpack_neclace", count = 1}, {name = "rpgitems_grenade_damage_0", count = 1}}
		},
		["rpgitems_repair"] = {
			effects = {{type = "other", modifier = "repair", value = 0.1}},
			name = {"", "[", {"rpg-items.repair"}, "]"},
			stack_size = 5,
			price = 25000
		},
		["rpgitems_spiked_collar"] = {
			effects = {
				-- {type = "force", modifier = "character_health_bonus", value = 200},
				-- {type = "other", modifier = "armor", value = 15},
				{type = "other", modifier = "thorns", value = 25}
			},
			name = {"", "[", {"rpg-items.spiked_collar"}, "]"},
			stack_size = 5,
			price = 24000
		},
		["rpgitems_health_0"] = {
			effects = {{type = "force", modifier = "character_health_bonus", value = 150}},
			name = {"", "[", {"rpg-items.health_0"}, "]"},
			stack_size = 5,
			price = 18000
		},
		["rpgitems_health_1"] = {
			effects = {{type = "force", modifier = "character_health_bonus", value = 400}},
			name = {"", "[", {"rpg-items.health_1"}, "]"},
			-- stack_size = 5,
			price = 10000,
			parts = {{name = "rpgitems_health_0", count = 2}}
		},
		["rpgitems_armor_0"] = {
			effects = {{type = "other", modifier = "armor", value = 10}},
			name = {"", "[", {"rpg-items.armor_0"}, "]"},
			stack_size = 5,
			price = 18000
		},
		["rpgitems_regeneration_0"] = {
			effects = {{type = "other", modifier = "regen", value = 2.5}},
			name = {"", "[", {"rpg-items.regeneration_0"}, "]"},
			stack_size = 5,
			price = 7500,
			parts = {{name = "rpgitems_health_potion", count = 10}}
		},
		["rpgitems_damage_0"] = {
			effects = {{type = "force", modifier = "ammo_damage_modifier", value = 0.25}},
			name = {"", "[", {"rpg-items.damage_0"}, "]"},
			stack_size = 5,
			price = 25000
		},
		["rpgitems_damage_1"] = {
			effects = {{type = "force", modifier = "ammo_damage_modifier", value = 0.7}},
			name = {"", "[", {"rpg-items.damage_1"}, "]"},
			-- stack_size = 5,
			price = 55000
		},
		["rpgitems_attackspeed_0"] = {
			effects = {{type = "force", modifier = "gun_speed_modifier", value = 0.2}},
			name = {"", "[", {"rpg-items.attackspeed_0"}, "]"},
			stack_size = 5,
			price = 20000
		},
		["rpgitems_crit_0"] = {
			effects = {{type = "other", modifier = "crit", value = 0.03}},
			name = {"", "[", {"rpg-items.crit_0"}, "]"},
			stack_size = 5,
			price = 30000
		},
		["rpgitems_manareg_0"] = {
			effects = {{type = "spellpack", modifier = "mana_reg", value = 0.5}},
			requires = "spell-pack",
			andversion = 18,
			name = {"", "[", {"rpg-items.manareg_0"}, "]"},
			stack_size = 5,
			price = 7500,
			parts = {{name = "rpgitems_mana_potion", count = 10}}
		},
		["rpgitems_mana_0"] = {
			effects = {{type = "spellpack", modifier = "max_mana", value = 20}},
			requires = "spell-pack",
			andversion = 18,
			name = {"", "[", {"rpg-items.mana_0"}, "]"},
			stack_size = 5,
			price = 10000
		},
		["rpgitems_grenade_damage_0"] = {
			effects = {{type = "force", modifier = "ammo_damage_modifier", value = 0.2, ammo = "grenade"}},
			requires = "spell-pack",
			andversion = 18,
			name = {"", "[", {"rpg-items.grenade_damage_0"}, "]"},
			stack_size = 5,
			price = 14000
		},
		["rpgitems_mining_speed"] = {
			effects = {{type = "force", modifier = "manual_mining_speed_modifier", value = 0.75}},
			name = {"", "[", {"rpg-items.mining_speed"}, "]"},
			stack_size = 5,
			price = 16000
		},
		["rpgitems_crafting_speed"] = {
			effects = {{type = "force", modifier = "manual_crafting_speed_modifier", value = 0.5}},
			name = {"", "[", {"rpg-items.crafting_speed"}, "]"},
			stack_size = 5,
			price = 16000
		},
		["rpgitems_battery"] = {
			effects = {{type = "other", modifier = "energy", value = 150}},
			name = {"", "[", {"rpg-items.battery"}, "]"},
			stack_size = 5,
			price = 15000
			-- parts = {
			-- 	{name = "rpgitems_factorio_silver", count = 1},
			-- 	{name = "rpgitems_lifesteal_0", count = 1},
			-- }
		},
		["rpgitems_lavalamp"] = {
			effects = {{type = "force", modifier = "ammo_damage_modifier", value = 0.2, ammo = "flamethrower"}},
			name = {"", "[", {"rpg-items.lavalamp"}, "]"},
			stack_size = 10,
			-- description = "[color=0.7,0.7,0.7]Stun chance is tripled for player attacks[/color]",
			-- cooldown = 300,
			requires = "spell-pack",
			andversion = 18,
			price = 15000
			-- parts = {
			--	{name = "rpgitems_crit_1", count = 1},
			--	{name = "rpgitems_armor_health", count = 1},
			--	--{name = "rpgitems_golden_amulet", count = 1},
			-- }
		},

		["rpgitems_bonus_slot"] = {
			effects = {},
			name = {"", "[", {"rpg-items.bonus_slot"}, "]"},
			description = {"rpg-items-description.bonus_slot"},
			price = 70000,
			parts = {}
		}
	}
	-- if not game.active_mods["spell-pack"] then
	--	global.items["rpgitems_mana_potion"] = nil
	--	global.items["rpgitems_manareg_0"] = nil
	-- end

	for _, data in pairs(global.items) do
		data.description = make_description(data)
	end
end

-- local function capitalize(str)
-- 	return (str:gsub("^%l", string.upper))
-- end

function make_description(data)
	-- local localization = {
	-- 	["iron-ore"] = "Iron ore",
	-- 	["iron-plate"] = "Iron plate",
	-- 	["steel-plate"] = "Steel plate",
	-- 	["copper-ore"] = "Copper ore",
	-- 	["copper-plate"] = "Copper plate",
	-- 	["coal"] = "Coal",
	-- 	["stone"] = "Stone",
	-- 	["stone-brick"] = "Stone brick",
	-- 	["uranium-ore"] = "Uranium ore",
	-- 	["firearm-magazine"] = "Firearm magazine",
	-- 	["piercing-rounds-magazine"] = "Piercing rounds magazine",
	-- 	["uranium-rounds-magazine"] = "Uranium rounds magazine",
	-- 	["character"] = "Player"
	-- }
	local raw_data = {}
	for _, effect in pairs(data.effects) do
		if effect.unique then
			raw_data[#raw_data+1] = "[color=0.9098,0.7255,0.1373]"
		end
		if effect.type == "force" then
			if effect.modifier == "ammo_damage_modifier" then
				raw_data[#raw_data+1] = "+" .. effect.value * 100 .. "% "
				if effect.ammo then
					raw_data[#raw_data+1] = effect.ammo .. " "
				end
				raw_data[#raw_data+1] = {"description.damage"}
			elseif effect.modifier == "gun_speed_modifier" then
				raw_data[#raw_data+1] = "+" .. effect.value * 100 .. "% "
				if effect.ammo then
					raw_data[#raw_data+1] = effect.ammo .. " "
				end
				raw_data[#raw_data+1] = {"gui-bonus.shooting-speed-bonus"}
			elseif effect.modifier == "character_running_speed_modifier" then
				raw_data[#raw_data+1] = "+" .. effect.value * 100 .. "% "
				raw_data[#raw_data+1] = {"description.character-movement-speed-modifier"}
			elseif effect.modifier == "character_health_bonus" then
				raw_data[#raw_data+1] = "+" .. floor(effect.value) .. " Health (character)"
			elseif effect.modifier == "manual_mining_speed_modifier" then
				raw_data[#raw_data+1] = "+" .. effect.value * 100 .. "% "
				raw_data[#raw_data+1] = {"gui-bonus.character-mining-speed"}
			elseif effect.modifier == "manual_crafting_speed_modifier" then
				raw_data[#raw_data+1] = "+" .. effect.value * 100 .. "% "
				raw_data[#raw_data+1] = {"gui-bonus.character-crafting-speed"}
			elseif effect.modifier == "character_inventory_slots_bonus" then
				raw_data[#raw_data+1] = "+" .. floor(effect.value) .. " "
				raw_data[#raw_data+1] = {"gui-bonus.character-inventory-slots-bonus"}
			elseif effect.modifier == "character_reach_distance_bonus" then
				raw_data[#raw_data+1] = "+" .. floor(effect.value) .. " "
				raw_data[#raw_data+1] = {"gui-bonus.character-reach-distance"}
			elseif effect.modifier == "turret_attack_modifier" then
				raw_data[#raw_data+1] = "+" .. effect.value * 100 .. "% "
				if effect.turret then
					raw_data[#raw_data+1] = {"entity-name." .. effect.turret} --(localization[effect.turret] or capitalize(effect.turret))
				else
					raw_data[#raw_data+1] = {"tooltip-category.turret"}
				end
				raw_data[#raw_data+1] = {"", " ", {"description.damage"}}
			else
				raw_data[#raw_data+1] = "+" .. effect.value .. " " .. effect.modifier .. "(???)"
			end
		elseif effect.type == "giveitem" then
			if effect.turret then
				-- It's not so correct actually but it seems fine
				raw_data[#raw_data+1] = {"", "+" .. effect.per_second .. " ", {"entity-name." .. effect.turret}}
				--(localization[effect.turret] or capitalize(effect.turret))
			elseif effect.item then
				raw_data[#raw_data+1] = {"", "+" .. effect.per_second .. " ", {"item-name." .. effect.item}}
			end
				-- raw_data[#raw_data+1] = "+" .. effect.per_second .. " " .. (localization[effect.item] or effect.item)
			-- if effect.per_second ~= 1 and localization[effect.item] and
			-- 				(localization[effect.item]:sub(-5, -1) == "plate" or localization[effect.item]:sub(-5, -1) == "brick" or
			-- 								localization[effect.item]:sub(-8, -1) == "magazine") then
			-- 	raw_data[#raw_data+1] = "s"
			-- end
			-- raw_data[#raw_data+1] = " per second"
		elseif effect.type == "other" then
			if effect.modifier == "income" then
				raw_data[#raw_data+1] = {"rpg-items-bonuses.income", effect.value}
			elseif effect.modifier == "crit" then
				raw_data[#raw_data+1] = {"rpg-items-bonuses.crit", effect.value * 100}
			elseif effect.modifier == "critdamage" then
				raw_data[#raw_data+1] = {"rpg-items-bonuses.critdamage", effect.value * 100}
			elseif effect.modifier == "armor" then
				raw_data[#raw_data+1] = {"", "+" .. floor(effect.value) .. " ", {"gui.armor"}, '(', {"gui.character"}, ')'}
			elseif effect.modifier == "thorns" then
				raw_data[#raw_data+1] = {"rpg-items-bonuses.thorns", effect.value, {"gui.character"}}
			elseif effect.modifier == "regen" then
				raw_data[#raw_data+1] = {"rpg-items-bonuses.regen", effect.value, {"gui.character"}}
			elseif effect.modifier == "pctregen" then
				raw_data[#raw_data+1] = {"rpg-items-bonuses.pctregen", effect.value, {"gui.character"}}
			elseif effect.modifier == "towerhp" then
				raw_data[#raw_data+1] = {"rpg-items-bonuses.towerhp", effect.value}
			elseif effect.modifier == "chardamage" then
				raw_data[#raw_data+1] = {"rpg-items-bonuses.chardamage", effect.value}
			elseif effect.modifier == "repair" then
				raw_data[#raw_data+1] = {"rpg-items-bonuses.repair", effect.value}
			elseif effect.modifier == "lifesteal" then
				raw_data[#raw_data+1] = {"rpg-items-bonuses.lifesteal", effect.value, {"gui.character"}}
			elseif effect.modifier == "pctlifesteal" then
				raw_data[#raw_data+1] = {"rpg-items-bonuses.pctlifesteal", effect.value, {"gui.character"}}
			elseif effect.modifier == "energy" then
				raw_data[#raw_data+1] ={"rpg-items-bonuses.energy", effect.value, {"gui.character"}, {"tooltip-category.vehicle"}}
			elseif effect.modifier == "revive" then
				raw_data[#raw_data+1] = {"rpg-items-bonuses.revive", effect.value}
			elseif effect.modifier == "stun" then
				raw_data[#raw_data+1] = {"rpg-items-bonuses.cdr", effect.value * 100}
			elseif effect.modifier == "momentum" then
				-- descr = descr.."While moving, your movement speed stacks up every 2 seconds, up to 10 times"
				raw_data[#raw_data+1] = {"rpg-items-bonuses.momentum"}
			elseif effect.modifier == "immolation" then
				-- descr = descr.."While moving, your movement speed stacks up every 2 seconds, up to 10 times"
				raw_data[#raw_data+1] = {"rpg-items-bonuses.immolation", effect.value}
			else
				raw_data[#raw_data+1] = "+" .. effect.value .. " " .. effect.modifier .. "(???)"
			end
		elseif effect.type == "spellpack" then
			if effect.modifier == "cdr" then
				raw_data[#raw_data+1] = {"rpg-items-bonuses.cdr", effect.value * 100}
			elseif effect.modifier == "max_mana" then
				raw_data[#raw_data+1] = {"rpg-items-bonuses.max_mana", effect.value}
			elseif effect.modifier == "max_spirit" then
				raw_data[#raw_data+1] = {"rpg-items-bonuses.max_spirit", effect.value}
			elseif effect.modifier == "mana_reg" then
				raw_data[#raw_data+1] = {"rpg-items-bonuses.mana_reg", effect.value}
			elseif effect.modifier == "spirit_reg" then
				raw_data[#raw_data+1] = {"rpg-items-bonuses.spirit_reg", effect.value}
			end
		elseif effect.type == "remotecall" then
			raw_data[#raw_data+1] = effect.description
			-- effect.mod
			-- effect.func
			-- effect.param (required!)
			-- effect.value (+ on add, - on remove)
			-- results in:
			-- remote.call(mod, func, force, param, +-value)
			-- you need to format your item's description yourself, this script is only called on init for the items in this file.
			-- example:
			-- {type = "remotecall", mod = "spell-pack", func = "modforce", param = "max_mana", value = 100, description = "+100 Max Mana"}
		end
		if effect.periodical then
			raw_data[#raw_data+1] = "/hour"
		end
		if effect.unique then
			if type(effect.unique) == "number" then
				raw_data[#raw_data+1] = " (unique)[/color]"
			else
				raw_data[#raw_data+1] = " (unique: " .. effect.unique .. ")[/color]"
			end
		end
		raw_data[#raw_data+1] = "\n"
	end
	-- if descr:sub(-1) == "\n" and not data.description then
	-- 	descr = descr:sub(1, -2)
	-- else

	if data.description then
		raw_data[#raw_data+1] = data.description
	elseif raw_data[#raw_data] == "\n" then
		raw_data[#raw_data] = nil
	end

	-- end

	local final_data = merge_localization(raw_data)

	if #final_data > 0 then
		return {"", table.unpack(final_data)}
	else
		return ""
	end
end
-- EDIT: DON'T USE THE "PLAYER" TYPE ANYMORE, AS IT'S EFFECTS GET LOST ON DEATH

-- type = "force" (every player has his own force) (basically every variable in LuaForce can be changed, if it's a number value)
--	ammo_damage_modifier [ammo = ammo_category, if nil then all categories]
--	gun_speed_modifier	[ammo = ammo_category, if nil then all categories]
--	turret_attack_modifier [turret = turret.name, if nil then all turrets]
--	manual_mining_speed_modifier
--	manual_crafting_speed_modifier
--	laboratory_speed_modifier
--	laboratory_productivity_bonus
--	worker_robots_speed_modifier
--	worker_robots_battery_modifier
--	worker_robots_storage_bonus
--	inserter_stack_size_bonus
--	stack_inserter_capacity_bonus
--	following_robots_lifetime_modifier
--	artillery_range_modifier
--	mining_drill_productivity_bonus
--	train_braking_force_bonus)
--	(character_running_speed_modifier)
--	(character_build_distance_bonus)
--	(character_item_drop_distance_bonus)
--	(character_reach_distance_bonus)
--	(character_resource_reach_distance_bonus)
--	(character_item_pickup_distance_bonus)
--	(character_loot_pickup_distance_bonus)
--	(character_inventory_slots_bonus)
--	(character_health_bonus)

-- type = "other"
--	income	(:: 1 Gold/sec = 1 :: Bonus income, default income is 1 Gold/sec)
--	crit	(:: 1% = 0.01 :: Critical strike chance, default is 0%)
--	critdamage (:: 1% = 0.01 :: bonus damage on crits, default is 200% damage)
--	armor (:: 1 Armor = 1 :: formula: absorb = armor/(armor+100) - for example 50 armor gives 33% absorbtion, 100 = 50% absorbtion, 200 = 66% absorbtion, 300 = 75% absorbtion)
--	thorns (:: 1 Damage = 1 :: damage thrown back at the enemy does not get substracted from incoming damage)
--	regen (:: 1 HP/s = 1 :: per second)
--	towerhp (:: 1 HP = 1 :: tower health bonus) not implemented yet

-- type = "giveitem"
--  Parameters:
--  item (the internal item name)
--  per_second (amount of items per second, can be less than 0)

-- func tutorial [outdated]:
-- Items need to have a cooldown for this.
-- As demonstrated in the health potion, you can execute stuff later.
-- Use the method demonstrated there to first create a table on the tick you want to execute on, then insert a function in that table.
-- Local variables carry over to the function you are declaring there (Like the "player" variable carries over in the health pot)
