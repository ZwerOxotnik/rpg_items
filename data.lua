require ("prototypes.buildings")
require ("prototypes.item_sprites")
--require ("prototypes.talent_gui_sprites")

--if settings.startup["rpgitems_regeneration_hack"].value then
data.raw.character.character.healing_per_tick = 0
--end


data:extend({{
    type = "sprite",
    name = "rpgitemsmarket_close",
    filename = "__m-rpg_items__/graphics/close.png",
    priority = "extra-high-no-scale",
    width = 20,
    height = 20,
    flags = {"no-crop", "icon"},
    scale = 1
  },
  --{
  --  type = "damage-type",
  --  name = "chardamage"
  --},
  {
    type = "sticker",
    name = "rpgitems-stun-sticker",
    flags = {"not-on-map"},
    duration_in_ticks = 60,
    target_movement_modifier = 0,
	single_particle = true,
	animation =
    {
      filename = "__m-rpg_items__/graphics/stunsticker.png",
      line_length = 2,
      width = 62,
      height = 20,
      frame_count = 6,
      axially_symmetrical = false,
      direction_count = 1,
      blend_mode = "additive",
      animation_speed = 0.3,
      scale = 0.7,
     -- tint = data.tint,
      shift ={0,-2},
	  run_mode = "backward"
    },
  },
  
  {
    type = "sticker",
    name = "rpgitems-flamecloak-sticker",
    flags = {"not-on-map"},
	render_layer = "decorative",
    animation =
    {
      filename = "__base__/graphics/entity/fire-flame/fire-flame-13.png",
      line_length = 8,
      width = 60,
      height = 118,
      frame_count = 25,
      blend_mode = "normal",
      animation_speed = 1,
      scale = 1.1,
      tint = { r = 0.5, g = 0.5, b = 0.5, a = 0.18 }, --{ r = 1, g = 1, b = 1, a = 0.35 },
      shift = {0,-0.9}
    },
	single_particle = true,
    duration_in_ticks = 60*60*60*5,
    target_movement_modifier = 1,
    --damage_per_tick = { amount = 100 / 60, type = "fire" },
    spread_fire_entity = "fire-flame-on-tree",
    fire_spread_cooldown = 30,
    fire_spread_radius = 0.75
  }
  })
  for i=1, 5 do
  data:extend({{
    type = "sticker",
    name = "rpgitems-speed-sticker-"..i,
    flags = {"not-on-map"},
    duration_in_ticks = 1200,
    target_movement_modifier = 1.10,
	--single_particle = true,
  },
  {
    type = "sticker",
    name = "rpgitems-halo-sticker-"..i,
    flags = {"not-on-map"},
    duration_in_ticks = 60*i,
    target_movement_modifier = 1,
	single_particle = true,
	animation =
    {
      filename = "__m-rpg_items__/graphics/halo.png",
      line_length = 5,
      width = 88,
      height = 44,
      frame_count = 36,
      axially_symmetrical = false,
      direction_count = 1,
      blend_mode = "additive-soft",
      animation_speed = 0.27,
      scale = 0.19,
      tint = {r=1,g=1,b=0.85,a=0.7},
      shift ={0,-1.2}
    },
  },
  })
  end
--data.raw.character.character.tool_attack_result.action_delivery.target_effects.damage.type = "chardamage"

--data.raw["gui-style"].default.default_tileset = "__m-rpg_items__/graphics/gui-new.png"
data.raw["gui-style"].default.rpgitems_yellow_button = {
      type = "button_style",
      parent = "button",
      default_graphical_set =
      {
        base =   {
			border = 1,
			filename = "__m-rpg_items__/graphics/gui-new.png",
			position = {0, 0},
			size = 17,
			scale = 1
		},
        shadow = default_dirt
      },
      hovered_graphical_set =
      {
        base = {
			border = 1,
					filename = "__m-rpg_items__/graphics/gui-new.png",
			position = {17, 0},
			size = 17,
			scale = 1
		},
        shadow = default_dirt,
        glow = default_glow({r=1,g=1,b=0.8}, 0.45)
      },
      clicked_graphical_set =
      {
        base = {
			border = 1,
			filename = "__m-rpg_items__/graphics/gui-new.png",
			position = {34, 0},
			size = 17,
			scale = 1
		},
        shadow = default_dirt
      },
      disabled_graphical_set =
      {
        base = {position = {330, 136}, corner_size = 8},
        shadow = default_dirt
      }
    }
data.raw["gui-style"].default.rpgitems_orange_button = {
      type = "button_style",
      parent = "button",
      default_graphical_set =
      {
        base = {
			border = 1,
			filename = "__m-rpg_items__/graphics/gui-new.png",
			position = {51, 0},
			size = 17,
			scale = 1
		},
        shadow = default_dirt
      },
      hovered_graphical_set =
      {
        base = {
			border = 1,
			filename = "__m-rpg_items__/graphics/gui-new.png",
			position = {68, 0},
			size = 17,
			scale = 1
		},
        shadow = default_dirt,
        glow = default_glow({r=1,g=0.9,b=0.8}, 0.45)
      },
      clicked_graphical_set =
      {
        base = {
			border = 1,
			filename = "__m-rpg_items__/graphics/gui-new.png",
			position = {85, 0},
			size = 17,
			scale = 1
		},
        shadow = default_dirt
      },
      disabled_graphical_set =
      {
        base = {position = {330, 136}, corner_size = 8},
        shadow = default_dirt
      }
    }
data.raw["gui-style"].default.rpgitems_white_button = {
      type = "button_style",
      parent = "button",
      default_graphical_set =
      {
        base = {
			border = 1,
			filename = "__m-rpg_items__/graphics/gui-new.png",
			position = {102, 0},
			size = 17,
			scale = 1
		},
        shadow = default_dirt
      },
      hovered_graphical_set =
      {
        base = {
			border = 1,
			filename = "__m-rpg_items__/graphics/gui-new.png",
			position = {119, 0},
			size = 17,
			scale = 1
		},
        shadow = default_dirt,
        glow = default_glow({r=0.9,g=0.9,b=0.9}, 0.45)
      },
      clicked_graphical_set =
      {
        base = {
			border = 1,
			filename = "__m-rpg_items__/graphics/gui-new.png",
			position = {136, 0},
			size = 17,
			scale = 1
		},
        shadow = default_dirt
      },
      disabled_graphical_set =
      {
        base = {position = {330, 136}, corner_size = 8},
        shadow = default_dirt
      }
    }
data.raw["gui-style"].default.rpgitems_gray_button = {
      type = "button_style",
      parent = "button",
      default_graphical_set =
      {
        base = {
			border = 1,
			filename = "__m-rpg_items__/graphics/gui-new.png",
			position = {153, 0},
			size = 17,
			scale = 1
		},
        shadow = default_dirt
      },
      hovered_graphical_set =
      {
        base = {
			border = 1,
			filename = "__m-rpg_items__/graphics/gui-new.png",
			position = {170, 0},
			size = 17,
			scale = 1
		},
        shadow = default_dirt,
        glow = default_glow({r=0.8,g=0.8,b=0.8}, 0.45)
      },
      clicked_graphical_set =
      {
        base = {
			border = 1,
			filename = "__m-rpg_items__/graphics/gui-new.png",
			position = {187, 0},
			size = 17,
			scale = 1
		},
        shadow = default_dirt
      },
      disabled_graphical_set =
      {
        base = {
			border = 1,
			filename = "__m-rpg_items__/graphics/gui-new.png",
			position = {204, 0},
			size = 17,
			scale = 1
		},
        shadow = default_dirt
      }
    }
data.raw["gui-style"].default.rpgitems_red_bar = 
    {
      type = "progressbar_style",
      minimal_width = 10,
      natural_width = 200,
      bar_width = 7, -- thickness of the bar, not horizontal size
      color = {g=1},
      other_colors = {},
      bar_background =
      {
        base = {
			border = 1,
			filename = "__m-rpg_items__/graphics/gui-new.png",
			position = {0, 17},
			size = 17,
			scale = 1
		},
        shadow = default_dirt
      },
      bar = {position = {313, 48}, corner_size = 8},
      font = "default",
      font_color = {1, 1, 1}
    }
data.raw["gui-style"].default.rpgitems_green_bar = 
    {
      type = "progressbar_style",
      minimal_width = 10,
      natural_width = 200,
      bar_width = 7, -- thickness of the bar, not horizontal size
      color = {g=1},
      other_colors = {},
      bar_background =
      {
        base = {
			border = 1,
			filename = "__m-rpg_items__/graphics/gui-new.png",
			position = {17, 17},
			size = 17,
			scale = 1
		},
        shadow = default_dirt
      },
      bar = {position = {313, 48}, corner_size = 8},
      font = "default",
      font_color = {1, 1, 1}
    }
data.raw["gui-style"].default.rpgitems_blue_bar = 
    {
      type = "progressbar_style",
      minimal_width = 10,
      natural_width = 200,
      bar_width = 7, -- thickness of the bar, not horizontal size
      color = {g=1},
      other_colors = {},
      bar_background =
      {
        base = {
			border = 1,
			filename = "__m-rpg_items__/graphics/gui-new.png",
			position = {34, 17},
			size = 17,
			scale = 1
		},
        shadow = default_dirt
      },
      bar = {position = {313, 48}, corner_size = 8},
      font = "default",
      font_color = {1, 1, 1}
    }
data.raw["gui-style"].default.rpgitems_white_bar = 
    {
      type = "progressbar_style",
      minimal_width = 10,
      natural_width = 200,
      bar_width = 7, -- thickness of the bar, not horizontal size
      color = {g=1},
      other_colors = {},
      bar_background =
      {
        base = {
			border = 1,
			filename = "__m-rpg_items__/graphics/gui-new.png",
			position = {51, 17},
			size = 17,
			scale = 1
		},
        shadow = default_dirt
      },
      bar = {position = {313, 48}, corner_size = 8},
      font = "default",
      font_color = {1, 1, 1}
    }