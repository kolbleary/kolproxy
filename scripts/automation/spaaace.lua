local script = nil

local function maybe_pull_item(name, amount)
	amount = amount or 1
	if count(name) < amount then
		async_post_page("/storage.php", { action = "pull", whichitem1 = get_itemid(name), howmany1 = amount - count(name), pwd = session.pwd, ajax = 1 })
		if amount > 1 and count(name) < amount then
			critical("Couldn't pull " .. tostring(amount) .. "x " .. tostring(name))
		end
	end
end

local function adv_space_zone(zoneid)
	script.ensure_buffs { "Fat Leon's Phat Loot Lyric", "Leash of Linguini", "Empathy" }
	script.heal_up()
	script.ensure_mp(100)
	result, resulturl, advagain = autoadventure {
		zoneid = zoneid,
		noncombatchoices = {
			["An E.M.U. for Y.O.U."] = "Hand over the parts",
		},
	}
end

local function use_map(mapname, mapzonetitle, choices)
	local pt, url = use_item(mapname)()
	pt, url = get_page("/choice.php")
	result, resulturl, advagain = handle_adventure_result(pt, url, "?", nil, nil, function (advtitle, choicenum, pt)
		if advtitle == mapzonetitle then
			for c in table.values(choices) do
				if pt:contains(c) then
					return c
				end
			end
		end
	end)
end

local function ronaldus(choices)
	if have("Map to Safety Shelter Ronald Prime") then
		use_map("Map to Safety Shelter Ronald Prime", "Deep Inside Ronald, Baby", choices)
	else
		adv_space_zone(265)
	end
end

local function grimacite(choices)
	if have("Map to Safety Shelter Grimace Prime") then
		use_map("Map to Safety Shelter Grimace Prime", "Deep Inside Grimace, Bow Chick-a Bow Bow", choices)
	else
		adv_space_zone(266)
	end
end

local function solve_porko(pegs, rewards)
	local current_worth_8 = {}
	local current_worth_9 = {}
	local function compute_worth_8(w9, peg_start_number)
		local new_worth_8 = {}
		for i = 1, 8 do
			local pegstyle = pegs[peg_start_number + i - 1]
			local left_value = w9[i]
			local right_value = w9[i + 1]
			if pegstyle == 1 then
				table.insert(new_worth_8, right_value)
			elseif pegstyle == 2 then
				table.insert(new_worth_8, left_value)
			elseif pegstyle == 3 then
				table.insert(new_worth_8, (left_value + right_value) / 2)
			else
				critical("Unknown peg style: " .. tostring(pegstyle))
			end
		end
-- 		print("", new_worth_8)
		return new_worth_8
	end
	local function compute_worth_9(w8, peg_start_number)
		local new_worth_9 = {}
		for i = 1, 9 do
			local pegstyle = pegs[peg_start_number + i - 1]
			local left_value = w8[i - 1] or w8[i]
			local right_value = w8[i] or w8[i - 1]
			if pegstyle == 1 then
				table.insert(new_worth_9, right_value)
			elseif pegstyle == 2 then
				table.insert(new_worth_9, left_value)
			elseif pegstyle == 3 then
				table.insert(new_worth_9, (left_value + right_value) / 2)
			else
				critical("Unknown peg style: " .. tostring(pegstyle))
			end
		end
-- 		print(new_worth_9)
		return new_worth_9
	end
	-- layout:
	-- 9 drop spots
	-- 9 pegs 1
	--  8 pegs 10
	-- 9 pegs 18
	--  8 pegs 27
	-- 9 pegs 35
	--  8 pegs 44
	-- 9 pegs 52
	--  8 pegs 61
	-- 9 pegs 69
	--  8 pegs 78
	-- 9 pegs 86
	--  8 pegs 95
	-- 9 pegs 103
	--  8 pegs 112
	-- 9 pegs 120
	--  8 pegs 129
	-- 9 rewards
	for x in table.values(rewards) do
		table.insert(current_worth_9, x)
	end
	current_worth_8 = compute_worth_8(current_worth_9, 129)
	current_worth_9 = compute_worth_9(current_worth_8, 120)
	current_worth_8 = compute_worth_8(current_worth_9, 112)
	current_worth_9 = compute_worth_9(current_worth_8, 103)
	current_worth_8 = compute_worth_8(current_worth_9, 95)
	current_worth_9 = compute_worth_9(current_worth_8, 86)
	current_worth_8 = compute_worth_8(current_worth_9, 78)
	current_worth_9 = compute_worth_9(current_worth_8, 69)
	current_worth_8 = compute_worth_8(current_worth_9, 61)
	current_worth_9 = compute_worth_9(current_worth_8, 52)
	current_worth_8 = compute_worth_8(current_worth_9, 44)
	current_worth_9 = compute_worth_9(current_worth_8, 35)
	current_worth_8 = compute_worth_8(current_worth_9, 27)
	current_worth_9 = compute_worth_9(current_worth_8, 18)
	current_worth_8 = compute_worth_8(current_worth_9, 10)
	current_worth_9 = compute_worth_9(current_worth_8, 1)
	local best_option = nil
	local best_option_score = -1000
	for i = 1, 9 do
		if current_worth_9[i] > best_option_score then
			best_option = i
			best_option_score = current_worth_9[i]
		end
	end
	print("best option", best_option, "for", best_option_score)
	return best_option
end

local transponders_used = 0

-- TODO: stop if spooky little girl gets hurt(?)

local space_href = add_automation_script("automate-spaaace", function ()
	if not autoattack_is_set() then
		stop "Set a macro on autoattack to use for scripting this quest."
	end
	script = get_automation_scripts()
	maybe_pull_item("sea salt scrubs")
	maybe_pull_item("flaming pink shirt")
	maybe_pull_item("spangly mariachi pants")
	script.set_familiar "Scarecrow with spangly mariachi pants"
	equip_item("spangly mariachi pants", "familiarequip")
	equip_item("sea salt scrubs", "shirt")
	equip_item("flaming pink shirt", "shirt")
	local function run_turns()
		advagain = false
		if advs() == 0 then
			stop "Out of adventures."
		end
		if not buff("Transpondent") then
			if transponders_used < 2 then
				transponders_used = transponders_used + 1
				maybe_pull_item("transporter transponder")
				use_item("transporter transponder")
			end
			if not buff("Transpondent") then
				stop "Use another transporter transponder."
			end
		end
		if not have("E.M.U. Unit") then
			if not have("spooky little girl") then
				if not have("E.M.U. rocket thrusters") then
					ronaldus { "Take a Look Around", "Try the Swimming Pool", "To the Left, to the Left", "Take the Red Door", "Step through the Glowy-Orange Thing" }
					if have("E.M.U. rocket thrusters") then
						advagain = true
					end
				elseif not have("E.M.U. joystick") then
					ronaldus { "Take a Look Around", "Try the Swimming Pool", "Right as Rain", "Crawl through the Ventilation Duct", "Step through the Glowy Thing" }
					if have("E.M.U. joystick") then
						advagain = true
					end
				elseif not have("E.M.U. harness") then
					grimacite { "Down the Hatch!", "Check out the Coat Check", "Exit, Stage Left", "Be the Duke of the Hazard", "Enter the Transporter" }
					if have("E.M.U. harness") then
						advagain = true
					end
				elseif not have("E.M.U. helmet") then
					grimacite { "Down the Hatch!", "Check out the Coat Check", "Stage Right, Even", "Try the Starboard Door", "Step Through the Transporter" }
					if have("E.M.U. helmet") then
						advagain = true
					end
				else
					adv_space_zone(266)
					advagain = have("spooky little girl")
				end
			elseif not have_equipped("spooky little girl") then
				equip_item("spooky little girl", "offhand")
				advagain = have_equipped("spooky little girl")
			else
				adv_space_zone(266)
				if have("E.M.U. Unit") then
					advagain = true
				end
			end
		elseif not have_equipped("E.M.U. Unit") then
			equip_item("E.M.U. Unit", "acc1")
			advagain = have_equipped("E.M.U. Unit")
		else
			result, resulturl, advagain = autoadventure { zoneid = 267 }
			result, resulturl, did_action = handle_adventure_result(result, resulturl, "?", nil, { ["Big-Time Generator"] = "See what you have to lose" })

			if result:contains("Big-Time Generator") and result:contains("Start Here") then
				local pegs = {}
				for x in result:gmatch([[title="peg style ([0-9])"]]) do
					table.insert(pegs, tonumber(x))
				end
				local rewards = { 0, 0, 0, 0, 1, 0, 0, 0, 0 }
				local best_option = solve_porko(pegs, rewards)
				result, resulturl = get_page("/choice.php", { whichchoice = 540, pwd = session.pwd, option = best_option })
				result, resulturl = get_page("/spaaace.php", { place = "grimace" })
			end

			return result, resulturl
		end
		if advagain then
			return run_turns()
		else
			return result, resulturl
		end
	end
	return run_turns()
end)

add_printer("/spaaace.php", function()
	if not setting_enabled("enable turnplaying automation") or ascensionstatus() ~= "Aftercore" then return end
	if text:contains("transpanel_before.gif") then
		text = text:gsub([[(</table></center>)(</body>)]], [[%1<center><a href="]]..space_href { pwd = session.pwd }..[[" style="color: green">{ Automate Space }</a></center>%2]])
	end
end)

function automate_porko_play()
	local pt, pturl = post_page("/spaaace.php", { pwd = session.pwd, place = "porko", action = "playporko" })
	if pt:contains("Click starting slot to drop your Porko!") then
-- 		print(pt)
		local pegs = {}
		for x in pt:gmatch([[title="peg style ([0-9])"]]) do
			table.insert(pegs, tonumber(x))
		end
-- 		print("Pegs!", pegs)
		local rewards = {}
		for x in pt:gmatch([[<div class="blank">x([0-9])</div>]]) do
-- 			print("rewarding x", x)
			table.insert(rewards, tonumber(x))
		end
-- 		print("Rewards!", rewards)
		local best_option = solve_porko(pegs, rewards)
		async_get_page("/choice.php", { whichchoice = 537, pwd = session.pwd, option = best_option })
		async_get_page("/choice.php", { whichchoice = 537, pwd = session.pwd, option = best_option })
		async_get_page("/choice.php", { whichchoice = 537, pwd = session.pwd, option = best_option })
	end
end

local porko_href = add_automation_script("automate-porko", function()
	local numtimes = tonumber(params.numtimes) or 0
	local before_isotopes = count("lunar isotope")
	local before_turns = advs()
	for i = 1, numtimes do
		automate_porko_play()
	end
	local after_isotopes = count("lunar isotope")
	local after_turns = advs()
	text = [[
<html>
<head>
<script>top.charpane.location = "charpane.php"</script>
</head>
<body>
]] .. "Gained " .. make_plural(after_isotopes - before_isotopes, "lunar isotope", "lunar isotopes") .. " in " .. make_plural(before_turns - after_turns, "adventure", "adventures") .. "." .. [[
</body>
</html>
]]
	return text, requestpath
end)

add_printer("/spaaace.php", function()
	if not setting_enabled("enable turnplaying automation") or ascensionstatus() ~= "Aftercore" then return end
	if text:contains("Step right up and try your luck at Porko") then
		text = text:gsub([[(</table></center>)(</body>)]], function(a, b)
			return a .. [[
<script language="javascript">
function automate_N_porko() {
	var N = prompt('How many turns?');
	if (N > 0) {
		var url = ']] .. porko_href { pwd = session.pwd } .. [['

		top.mainpane.location.href = (url + "&numtimes=" + N)
	}
}
</script><center><a href="javascript:automate_N_porko()" style="color: green">{ Automate Porko farming }</a></center>]] .. b
		end)
	end
end)