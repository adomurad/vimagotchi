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

M.height = 7
M.width = 11

M.win_id = nil

function M.init()
	-- nothing
	M._state.pos.x = vim.o.columns / 8
	M._state.pos.y = vim.o.lines / 2
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
	-- local pos = M._state.pos
	-- if pos.y > 1 then
	-- 	for y = 1, pos.y - 1 do
	-- 		lines[y] = ""
	-- 	end
	-- end

	-- creature
	for y = 1, creature.char_height do
		-- local padding = string.rep(" ", pos.x - 1)
		lines[y] = char_lines[y]

		-- line with the eaten text
		if #M._state.text_to_eat > 0 and y == 1 + 2 then
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

local function get_editor_cursor_pos()
	local win = vim.api.nvim_get_current_win()
	local win_pos = vim.api.nvim_win_get_position(win)
	local win_row = vim.fn.winline() - 1
	local win_col = vim.fn.wincol() - 1
	return {
		y = win_pos[1] + win_row, -- 0-based
		x = win_pos[2] + win_col, -- 0-based
	}
end

local function move_creature()
	local pos = M._state.pos

	local cursor = get_editor_cursor_pos()

	-- if math.abs(cursor.y - pos.y) < 1 then
	-- 	-- if cursor.y > pos.y then
	-- 	pos.y = pos.y + 1
	-- 	-- else
	-- 	-- pos.y = pos.y + 1
	-- 	-- end
	-- elseif math.abs(cursor.y - (pos.y + M.height)) < 1 then
	-- 	pos.y = pos.y - 1

	local x_cross = cursor.x >= pos.x and cursor.x <= pos.x + M.width
	local y_cross = cursor.y >= pos.y and cursor.y < pos.y + M.height

	if y_cross or x_cross then
		if y_cross then
			if cursor.y - pos.y < 3 then
				pos.y = pos.y + 1
			else
				pos.y = pos.y - 1
			end
		end

		if x_cross then
			if cursor.x - pos.x < 3 then
				pos.x = pos.x + 1
			else
				pos.x = pos.x - 1
			end
		end
	else
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
	end

	if pos.x > vim.o.columns - creature.char_width + 1 then
		pos.x = vim.o.columns - creature.char_width + 1
	elseif pos.x < 1 then
		pos.x = 1
	elseif pos.y > vim.o.lines - creature.char_height + 1 then
		pos.y = vim.o.lines - creature.char_height + 1
	elseif pos.y < 1 then
		pos.y = 1
	end

	if M.win_id ~= nil then
		vim.api.nvim_win_set_config(M.win_id, {
			relative = "editor",
			col = pos.x,
			row = pos.y,
		})
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
