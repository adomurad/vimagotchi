local M = {}

local creature = require("vimagotchi.creature")

M._state = {
	timer = 0,
	pos = {
		x = 4,
		y = 4,
	},
	frame_idle = 1,
	frame_eat = 1,
	text_to_eat = "",
}

M.height = 10
M.width = 40

function M.init()
	-- nothing
end

local function stringToArray(str)
	local t = {}
	local i = 1
	while i <= #str do
		local b = str:byte(i)
		local len = (b < 0x80) and 1 or (b < 0xE0) and 2 or (b < 0xF0) and 3 or 4
		table.insert(t, str:sub(i, i + len - 1))
		i = i + len
	end
	return t
end

local function render_creature_in_window(creature_frame)
	local char_lines = vim.split(creature_frame, "\n")

	local lines = {}

	-- above creature
	local pos = M._state.pos
	if pos.y > 1 then
		for y = 1, pos.y - 1 do
			lines[y] = ""
		end
	end

	-- creature
	for y = pos.y, pos.y + creature.char_height do
		local padding = string.rep(" ", pos.x - 1)
		lines[y] = padding .. char_lines[y + 1 - pos.y]

		-- line with the eaten text
		if #M._state.text_to_eat > 0 and y == pos.y + 2 then
			local chars = stringToArray(lines[y])
			local head, tail = vim.list_slice(chars, 1, #chars - 6), vim.list_slice(chars, #chars - 5)
			lines[y] = table.concat(head)

			local eat_chars = stringToArray(M._state.text_to_eat)

			for char_index, char in ipairs(tail) do
				local eat_char = vim.list_slice(eat_chars, char_index, char_index + 1)

				if #eat_char == 0 or eat_char[1] == " " then
					lines[y] = lines[y] .. char
				else
					lines[y] = lines[y] .. eat_char[1]
				end
			end

			lines[y] = lines[y] .. table.concat(vim.list_slice(eat_chars, #tail + 1))

			local text_to_eat_arr = stringToArray(M._state.text_to_eat)
			M._state.text_to_eat = table.concat(vim.list_slice(text_to_eat_arr, 2))
		end
	end

	return lines
end

local function get_creature_frame()
	local is_eating = #M._state.text_to_eat > 0

	-- EATING
	if is_eating then
		if M._state.timer % 2 == 0 then
			M._state.frame_eat = M._state.frame_eat + 1
		end

		local animation_eat = creature.animations.eat

		if M._state.frame_eat > #animation_eat.frames then
			M._state.frame_eat = 1
		end

		local eat_frame = animation_eat.frames[M._state.frame_eat]
		return eat_frame
	end

	-- IDLE
	local animation_idle = creature.animations.idle

	if M._state.timer % 5 == 0 then
		M._state.frame_idle = M._state.frame_idle + 1
	end

	if M._state.frame_idle > #animation_idle.frames then
		M._state.frame_idle = 1
	end

	local idle_frame = animation_idle.frames[M._state.frame_idle]
	return idle_frame
end

local function move_creature()
	local pos = M._state.pos
	local rand_dir = math.random(0, 5)

	if rand_dir == 0 then
		pos.x = pos.x + 1
	elseif rand_dir == 1 then
		pos.x = pos.x - 1
	elseif rand_dir == 2 then
		pos.y = pos.y + 1
	elseif rand_dir == 3 then
		pos.y = pos.y - 1
	end

	if pos.x > M.width - creature.char_width + 1 then
		pos.x = M.width - creature.char_width + 1
	elseif pos.x < 1 then
		pos.x = 1
	elseif pos.y > M.height - creature.char_height + 1 then
		pos.y = M.height - creature.char_height + 1
	elseif pos.y < 1 then
		pos.y = 1
	end
end

function M.next_frame()
	M._state.timer = M._state.timer + 1

	local creature_frame = get_creature_frame()

	local is_eating = #M._state.text_to_eat > 0

	if not is_eating and M._state.timer % 5 == 0 then
		move_creature()
	end

	return render_creature_in_window(creature_frame)
end

function M.eat_text(text)
	local padding_chars = M.width - M._state.pos.x - 8 - #M._state.text_to_eat
	local padding = string.rep(" ", padding_chars)
	M._state.text_to_eat = M._state.text_to_eat .. padding .. text
end

return M
