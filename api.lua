---@class ItemReplacement
---@field name? string
---@field type? ("item"|"fluid")
---@field amountMult? number
---@field amountAdd? number
---@field delete? boolean
---@field setChance? number

---@alias ItemReplacementMap {[string]: ItemReplacement}

---@class JuhTweaks.Api
local api = {}

---This function patches the recipe to replace inputs and outputs with
---different items or fluids
---
---Item/Fluid amount will not go below 1
---@param recipe data.RecipePrototype|data.RecipeID
---@param replacements ItemReplacementMap
api.patchRecipe = function(recipe, replacements)
	if type(recipe) == "string" then
		recipe = data.raw["recipe"][recipe]
	end
	if recipe.ingredients then
		for idx = #recipe.ingredients, 1, -1 do
			local ing = recipe.ingredients[idx]
			local newIng = replacements[ing.name]
			if newIng then
				if newIng.delete then
					table.remove(recipe.ingredients, idx)
				else
					if newIng.type then
						ing.type = newIng.type
					end
					if newIng.name then
						ing.name = newIng.name
					end
					if newIng.amountMult then
						ing.amount = math.max(1, math.floor(ing.amount * newIng.amountMult + 0.5))
					end
					if newIng.amountAdd then
						ing.amount = math.max(1, math.floor(ing.amount + newIng.amountAdd + 0.5))
					end
					recipe.ingredients[idx] = ing
				end
			end
		end
	end
	if recipe.results then
		for idx = #recipe.results, 1, -1 do
			local prod = recipe.results[idx]
			local newProd = replacements[prod.name]
			if replacements[prod.name] then
				if newProd.delete then
					table.remove(recipe.results, idx)
				else
					if newProd.type then
						prod.type = newProd.type
					end
					if newProd.name then
						prod.name = newProd.name
					end
					if newProd.amountMult then
						prod.amount = math.max(1, math.floor(prod.amount * newProd.amountMult + 0.5))
					end
					if newProd.amountAdd then
						prod.amount = math.max(1, math.floor(prod.amount + newProd.amountAdd + 0.5))
					end
					if newProd.setChance then
						prod.probability = newProd.setChance
					end
					recipe.results[idx] = prod
				end
			end
		end
	end
	if recipe.main_product and replacements[recipe.main_product] then
		recipe.main_product = replacements[recipe.main_product].name
	end
end

---@param recipes (data.RecipePrototype|data.RecipeID)[]
---@param replacements ItemReplacementMap
api.patchRecipes = function(recipes, replacements)
	for _, recipe in pairs(recipes) do
		api.patchRecipe(recipe, replacements)
	end
end

---@class IconsGenData
---@field base string
---@field top_left? string
---@field top_right? string
---@field bottom_left? string
---@field bottom_right? string

---@param icons IconsGenData
api.build_icons_subscripts = function(icons)
	local icons_data = {
		{
			icon = icons.base,
			icon_size = 64,
			scale = 0.65,
			shift = { 2, 2 },
			draw_background = true,
		},
	}
	if icons.top_left ~= nil then
		icons_data[#icons_data + 1] = {
			icon = icons.top_left,
			icon_size = 64,
			scale = 0.45,
			shift = { -11, -11 },
			draw_background = true,
		}
	end
	if icons.top_right ~= nil then
		icons_data[#icons_data + 1] = {
			icon = icons.top_right,
			icon_size = 64,
			scale = 0.45,
			shift = { 11, -11 },
			draw_background = true,
		}
	end
	if icons.bottom_left ~= nil then
		icons_data[#icons_data + 1] = {
			icon = icons.bottom_left,
			icon_size = 64,
			scale = 0.45,
			shift = { -11, 11 },
			draw_background = true,
		}
	end
	if icons.bottom_right ~= nil then
		icons_data[#icons_data + 1] = {
			icon = icons.bottom_right,
			icon_size = 64,
			scale = 0.45,
			shift = { -11, 11 },
			draw_background = true,
		}
	end
	return icons_data
end

---@param recipes (data.RecipePrototype|data.RecipeID)[]
api.hideRecipes = function(recipes)
	for _, recipe in pairs(recipes) do
		if type(recipe) == "string" then
			recipe = data.raw["recipe"][recipe]
		end
		if recipe ~= nil then
			recipe.hidden = true
			recipe.hidden_in_factoriopedia = true
		end
	end
end

---@param a string[]
---@param b string[]
---@param overrides? {[string]: boolean}
---@return string[]
api.merge_categories = function(a, b, overrides)
	local categories = {}
	for _, catId in pairs(a) do
		categories[catId] = true
	end
	for _, catId in pairs(b) do
		categories[catId] = true
	end
	if overrides ~= nil then
		for k, v in pairs(overrides) do
			categories[k] = v
		end
	end

	local cats = {}
	for cat, include in pairs(categories) do
		if include then
			cats[#cats + 1] = cat
		end
	end

	return cats
end

---@param machine data.CraftingMachinePrototype
---@param fn fun(base: data.Effect)
api.modify_effects_receiver_base = function(machine, fn)
	if machine.effect_receiver == nil then
		machine.effect_receiver = { base_effect = {} }
	end
	if machine.effect_receiver.base_effect == nil then
		machine.effect_receiver.base_effect = {}
	end
	fn(machine.effect_receiver.base_effect)
end

return api
