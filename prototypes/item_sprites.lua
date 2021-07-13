local items = {
	"rpgitems_shoes", "rpgitems_golden_amulet", "rpgitems_health_potion", "rpgitems_spineripper", "rpgitems_tyrs_hand",
	"rpgitems_bulwark", "rpgitems_spiked_collar", "rpgitems_horned_helmet", "rpgitems_yellow_ammo", "rpgitems_red_ammo",
	"rpgitems_green_ammo", "rpgitems_book1", "rpgitems_iron_generator", "rpgitems_iron_plates_generator",
	"rpgitems_steel_plates_generator", "rpgitems_copper_generator", "rpgitems_copper_plates_generator",
	"rpgitems_stone_generator", "rpgitems_stone_bricks_generator", "rpgitems_uranium_generator",
	"rpgitems_coal_generator", "rpgitems_attackspeed_0", "rpgitems_damage_0", "rpgitems_damage_1", "rpgitems_armor_0",
	"rpgitems_health_0", "rpgitems_health_1", "rpgitems_armor_health", "rpgitems_boots_0", "rpgitems_boots_1",
	"rpgitems_boots_2", "rpgitems_regeneration_0", "rpgitems_rainbow_drill", "rpgitems_chardamage_0",
	"rpgitems_chardamage_gold", "rpgitems_chardamage_gold_reg", "rpgitems_amnesia_book", "rpgitems_mana_potion",
	"rpgitems_mana_0", "rpgitems_manareg_0", "rpgitems_bonus_slot", "rpgitems_spellpack_neclace",
	"rpgitems_grenade_damage_0", "rpgitems_spellpack_helmet", "rpgitems_mining_speed", "rpgitems_crafting_speed",
	"rpgitems_multitool", "rpgitems_robo_butler", "rpgitems_repair", "rpgitems_regeneration_1", "rpgitems_armor_2",
	"rpgitems_lifesteal_0", "rpgitems_lifesteal_1", "rpgitems_factorio_bronze", "rpgitems_factorio_silver",
	"rpgitems_factorio_gold", "rpgitems_battery", "rpgitems_cards", "rpgitems_cards_spepa", "rpgitems_crusader",
	"rpgitems_crusader_spepa", "rpgitems_crit_0", "rpgitems_crit_1", "rpgitems_staff", "rpgitems_staff_spepa",
	"rpgitems_lavalamp", "rpgitems_flamecloak", "rpgitems_flamecloak_spepa", "rpgitems_wind_0", "rpgitems_wind_1"
}
local extend = {}
for _, name in pairs(items) do
	table.insert(extend, {
		type = "sprite",
		name = name,
		filename = "__m-rpg_items__/graphics/items/" .. name .. ".png",
		priority = "extra-high-no-scale",
		width = 64,
		height = 64,
		flags = {"no-crop", "icon"},
		scale = 1
	})
end
table.insert(extend, {
	type = "sprite",
	name = "rpgitems-coin",
	filename = "__m-rpg_items__/graphics/coin.png",
	priority = "extra-high-no-scale",
	width = 165,
	height = 172,
	flags = {"no-crop", "icon"},
	scale = 1
})
table.insert(extend, {
	type = "sprite",
	name = "transparent32",
	filename = "__m-rpg_items__/graphics/transparent32.png",
	priority = "extra-high-no-scale",
	width = 32,
	height = 32,
	flags = {"no-crop", "icon"},
	scale = 1
})
data:extend(extend)

-- require ("unused_items")
