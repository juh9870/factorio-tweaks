---@class ItemReplacement
---@field name? string
---@field type? ("item"|"fluid")
---@field amountMult? number

---@alias ItemReplacementMap {[string]: ItemReplacement}

---This function patches the recipe to replace inputs and outputs with
---different items or fluids
---
---Items can't be swapped into fluids and vice versa
---
---Item/Fluid amount will not go below 1
---@param recipe data.RecipePrototype
---@param replacements ItemReplacementMap
local function patchRecipe(recipe, replacements)
	if recipe.ingredients then
		for ingName, ing in pairs(recipe.ingredients) do
			if replacements[ing.name] then
				local newIng = replacements[ing.name]
				if newIng.type then
					ing.type = newIng.type
				end
				if newIng.name then
					ing.name = newIng.name
				end
				if newIng.amountMult then
					ing.amount = math.max(1, math.floor(ing.amount * newIng.amountMult))
				end
				recipe.ingredients[ingName] = ing
			end
		end
	end
	if recipe.results then
		for prodName, prod in pairs(recipe.results) do
			if replacements[prod.name] then
				local newProd = replacements[prod.name]
				if newProd.type then
					prod.type = newProd.type
				end
				if newProd.name then
					prod.name = newProd.name
				end
				if newProd.amountMult then
					prod.amount = math.max(1, math.floor(prod.amount * newProd.amountMult))
				end
				recipe.results[prodName] = prod
			end
		end
	end
	if recipe.main_product and replacements[recipe.main_product] then
		recipe.main_product = replacements[recipe.main_product].name
	end
end

if mods["wret-beacon-rebalance-mod"] then
	if mods["Krastorio2-spaced-out"] then
		local singularity_beacon = data.raw["beacon"]["kr-singularity-beacon"]
		singularity_beacon.module_slots = 15
		singularity_beacon.supply_area_distance = singularity_beacon.supply_area_distance + 1
		singularity_beacon.energy_usage = "800kW"

		singularity_beacon.profile = { 1, 0 }

		if settings.startup["wret-overload-enable-beaconmk3"].value == true then
			data.raw["recipe"]["wr-beacon-3"].ingredients = {
				{ type = "item", name = "wr-beacon-2", amount = 1 },
				{ type = "item", name = "kr-imersium-beam", amount = 4 },
				{ type = "item", name = "kr-ai-core", amount = 20 },
				{ type = "item", name = "copper-cable", amount = 30 },
				{ type = "item", name = "quantum-processor", amount = 40 },
				{ type = "item", name = "snouz_better_substation", amount = 4 },
				{ type = "item", name = "kr-advanced-radar", amount = 4 },
			}
			data.raw["technology"]["effect-transmission-3"].prerequisites = {
				"effect-transmission-2",
				"quantum-processor",
				"electric-energy-distribution-2",
				"kr-ai-core",
				"kr-energy-control-unit",
				"kr-advanced-radar",
			}
			data.raw["technology"]["effect-transmission-3"].unit.ingredients = {
				{ "production-science-pack", 1 },
				{ "utility-science-pack", 1 },
				{ "space-science-pack", 1 },
				{ "electromagnetic-science-pack", 1 },
				{ "cryogenic-science-pack", 1 },
				{ "kr-matter-tech-card", 1 },
				{ "kr-advanced-tech-card", 1 },
			}
			data.raw["technology"]["kr-singularity-beacon"].prerequisites = {
				"effect-transmission-3",
				"kr-singularity-tech-card",
			}
		end
	end

	data.raw["beacon"]["wr-beacon-3"].profile = { 1, 0 }
	data.raw["beacon"]["wr-beacon-2"].profile = { 1, 0 }
	data.raw["beacon"]["beacon"].profile = { 1, 0 }
end

if mods["248k-Redux"] and mods["um-standalone-foundry"] then
	local replacements = {
		["el_arc_pure_iron"] = {
			name = "molten-iron",
			amountMult = 1,
		},
		["el_arc_pure_copper"] = {
			name = "molten-copper",
			amountMult = 1,
		},
		["molten-iron"] = {
			name = "molten-iron",
			amountMult = 10,
		},
		["molten-copper"] = {
			name = "molten-copper",
			amountMult = 10,
		},
	}
	for _, recipeData in pairs(data.raw["recipe"]) do
		patchRecipe(recipeData, replacements)
	end

	local categories = {
		["electronics"] = {
			"fi_modules_productivity_1_recipe",
			"fi_modules_productivity_2_recipe",
			"fi_modules_productivity_3_recipe",
			"fi_modules_productivity_4_recipe",
			"fi_modules_productivity_5_recipe",
			"fi_modules_productivity_6_recipe",
			"fi_modules_core_recipe",
			"gr_gold_wire_recipe",
		},
		["electronics-with-fluid"] = {
			"gr_circuit_recipe",
		},
		["crafting-with-fluid-or-metallurgy"] = {
			"el_ceramic_recipe",
			"fi_ceramic_recipe",
		},
	}

	for catName, recipes in pairs(categories) do
		for _, recipeName in pairs(recipes) do
			data.raw["recipe"][recipeName].category = catName
		end
	end

	local assemblerCategories = data.raw["assembling-machine"]["assembling-machine-3"].crafting_categories

	for _, machineId in pairs({ "fi_crafter_entity", "gr_crafter_entity" }) do
		local machine = data.raw["assembling-machine"][machineId]
		local categories = {}
		for _, catId in pairs(assemblerCategories) do
			categories[catId] = true
		end
		for _, catId in pairs(machine.crafting_categories) do
			categories[catId] = true
		end

		categories["crafting-with-fluid"] = false
		categories["crafting-with-fluid-or-metallurgy"] = false
		categories["electronics-with-fluid"] = false

		local categoriesList = {}
		for catId, add in pairs(categories) do
			if add then
				table.insert(categoriesList, catId)
			end
		end

		machine.crafting_categories = categoriesList
	end

	local foundryCats = data.raw["assembling-machine"]["foundry"].crafting_categories
	table.insert(foundryCats, "el_caster_category")
	table.insert(foundryCats, "el_arc_furnace_category")

	data.raw["recipe"]["casting-iron"].hidden = true
	data.raw["recipe"]["casting-steel"].hidden = true
	data.raw["recipe"]["casting-copper"].hidden = true

	data.raw["recipe"]["el_arc_pure_iron_recipe"].subgroup = "el_item_subgroup_e"
	data.raw["recipe"]["el_arc_pure_copper_recipe"].subgroup = "el_item_subgroup_e"
end

if mods["RenaiTransportation"] and mods["rubia"] then
	---@param id string
	---@param trigger data.TechnologyTrigger
	---@param prereqs (string)[]?
	local function modify_tech(id, trigger, prereqs)
		local tech = data.raw["technology"][id]
		if not tech then
			return
		end
		tech.unit = nil
		tech.research_trigger = trigger
		if prereqs then
			tech.prerequisites = prereqs
		end
	end

	modify_tech(
		"se-no",
		{ type = "craft-item", item = "yeet-automation-science-pack", count = 50 },
		{ "rubia-progression-stage1" }
	)
	modify_tech(
		"RTSimonSays",
		{ type = "craft-item", item = "yeet-DirectedBouncePlate", count = 50 },
		{ "se-no", "rubia-progression-stage2" }
	)
	modify_tech("RTThrowerTime", { type = "craft-item", item = "yeet-inserter", count = 150 })
	modify_tech(
		"RTFocusedFlinging",
		{ type = "craft-item", item = "yeet-rubia-sniper-turret", count = 10 },
		{ "RTThrowerTime", "rubia-sniper-turret" }
	)
	modify_tech("RTFlyingFreight", { type = "craft-item", item = "yeet-locomotive", count = 25 })
	local space_tech_exist = data.raw["technology"]["tech-space-trains"] ~= nil
	local locomitive_exists = data.raw["locomotive"]["space-locomotive"] ~= nil

	log(
		"tech-space-trains exists: "
			.. tostring(space_tech_exist)
			.. "; space-locomotive item exists: "
			.. tostring(locomitive_exists)
	)

	if space_tech_exist and locomitive_exists then
		modify_tech(
			"RTMagnetTrainRamps",
			{ type = "craft-item", item = "yeet-space-locomotive", count = 4 },
			{ "RTFlyingFreight", "tech-space-trains", "electric-energy-distribution-2" }
		)
	else
		modify_tech(
			"RTMagnetTrainRamps",
			{ type = "craft-item", item = "yeet-rail-ramp", count = 10 },
			{ "RTFlyingFreight", "elevated-rail", "electric-energy-distribution-2", "electric-energy-accumulators" }
		)
	end
	modify_tech("RTBeltRampTech", { type = "craft-item", item = "yeet-transport-belt", count = 200 })
	modify_tech("HatchRTTech", { type = "craft-item", item = "yeet-OpenContainer", count = 100 })
	modify_tech("EjectorHatchRTTech", { type = "craft-item", item = "yeet-HatchRT", count = 50 })
	modify_tech("RTVacuumHatchTech", { type = "craft-item", item = "yeet-pump", count = 50 })
end

if mods["Telogistics"] then
	local tech = data.raw["technology"]["s6x-logistic-teleporter"]
	tech.prerequisites = {
		"kr-energy-control-unit",
		"space-science-pack",
		"logistic-system",
	}
	local recipe = data.raw["recipe"]["s6x-logistic-teleporter"]
	recipe.ingredients = {
		{
			type = "item",
			name = "kr-rare-metals",
			amount = 100,
		},
		{
			type = "item",
			name = "kr-energy-control-unit",
			amount = 50,
		},
		{
			type = "item",
			name = "accumulator",
			amount = 20,
		},
		{
			type = "item",
			name = "kr-advanced-radar",
			amount = 10,
		},
	}
	recipe.surface_conditions = {
		{
			property = "gravity",
			min = 0,
			max = 0,
		},
	}
	local item = data.raw["item"]["s6x-logistic-teleporter"]
	item.weight = 10000
end

if mods["Paracelsin"] and mods["Cerys-Moon-of-Fulgora"] and mods["Krastorio2-spaced-out"] then
	local recipe = data.raw["recipe"]["paracelsin-processing-units-from-nitric-acid"]
	patchRecipe(recipe, { ["electronic-circuit"] = { amountMult = 12 / 16 } })

	recipe.icon = nil
	recipe.icons = {
		{
			icon = "__base__/graphics/icons/processing-unit.png",
			icon_size = 64,
			scale = 0.65,
			shift = { 2, 2 },
			draw_background = true,
		},
		{
			icon = "__Krastorio2Assets__/icons/fluids/nitric-acid.png",
			icon_size = 64,
			scale = 0.45,
			shift = { -11, -11 },
			draw_background = true,
		},
		{
			icon = "__Paracelsin-Graphics__/graphics/icons/zinc-solder.png",
			icon_size = 64,
			scale = 0.45,
			shift = { 11, -11 },
			draw_background = true,
		},
	}
end
