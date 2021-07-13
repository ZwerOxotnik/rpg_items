local function upscale (arr)
	if arr.filename then
		arr.scale = (arr.scale or 1) * 2
		log(arr.filename)
	end
	if arr.collision_box then
		arr.collision_box[1][1] = arr.collision_box[1][1]*2
		arr.collision_box[1][2] = arr.collision_box[1][2]*2
		arr.collision_box[2][1] = arr.collision_box[2][1]*2
		arr.collision_box[2][2] = arr.collision_box[2][2]*2
	end
	if arr.selection_box then
		arr.selection_box[1][1] = arr.selection_box[1][1]*2
		arr.selection_box[1][2] = arr.selection_box[1][2]*2
		arr.selection_box[2][1] = arr.selection_box[2][1]*2
		arr.selection_box[2][2] = arr.selection_box[2][2]*2
	end
	for i, v in pairs(arr) do
		if type(v) == "table" then
			v = upscale(v)
		end
	end
	return arr
end


local market = table.deepcopy(data.raw.market.market)
market.name = "rpgitems-market"
market.localised_name= "Equipment Market"
minable = {mining_time = 1, result = "rpgitems-market"}
market.order = "zzzz"
market.picture =
    {
      filename = "__rpg_items__/graphics/equipment-market.png",
      width = 312,
      height = 254,
	  scale = 0.5,
      shift = {0.95, 0.2}
    }

local recipe = table.deepcopy(data.raw.recipe["rocket-silo"])
recipe.name = "rpgitems-market"
recipe.result = "rpgitems-market"
recipe.enabled = true
recipe.ingredients =
    {
      {"iron-plate", 1000},
      {"copper-plate", 1000},
      {"stone-brick", 1000},

    }

local item =  table.deepcopy(data.raw.item["rocket-silo"])
item.name = "rpgitems-market"
item.localised_name= "Equipment Market"
item.place_result = "rpgitems-market"
item.icon = "__rpg_items__/graphics/market-icon.png"
item.icon_size=144
--market.picture =
--    {
--      filename = "__rpg_items__/graphics/market.png",
--      width = 244,
--      height = 244,
--      shift = {0.95, 0.2}
--    }
data:extend({recipe, item, market})