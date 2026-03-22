local M = {}

local Game = require("vimagotchi.game")
Game.init()

M._store = {
	game_buf = nil,
}

local valid_args = { "Open" }

local function complete_my_cmd(arg_lead, cmd_line, cursor_pos)
	local matches = {}
	for _, arg in ipairs(valid_args) do
		if arg:find("^" .. arg_lead) then
			table.insert(matches, arg)
		end
	end
	return matches
end

local function create_user_commands()
	vim.api.nvim_create_user_command("Vimagotchi", function(args)
		if args.args == "" then
			print("Error: Vimagotchi requires an argument (Open, )")
			return
		end

		if args.args == "Open" then
			M.toggle_chat()
		elseif args.args == "Close" then
			-- M.new_chat()
		else
			print("Error: wrong arg!")
		end
	end, {
		desc = "Vimagotchi",
		nargs = 1, -- Expect exactly one argument
		complete = complete_my_cmd, -- Autocompletion function
	})
end

function M.setup()
	create_user_commands()
	M._store.game_buf = vim.api.nvim_create_buf(false, true)

	local timer = vim.uv.new_timer()
	if timer == nil then
		error("could not start a timer")
		return
	end

	timer:start(
		10,
		100,
		vim.schedule_wrap(function()
			-- your animation frame update here
			local frame = Game.next_frame()
			vim.api.nvim_buf_set_lines(M._store.game_buf, 0, -1, true, frame)
			-- vim.api.nvim_buf_set_lines(M._store.game_buf, 0, -1, true, vim.split(frame, '\n'))
		end)
	)

	M.open()

	vim.api.nvim_create_autocmd("TextYankPost", {
		callback = function(ev)
			if vim.v.event.operator:match("[ydc]") then
				local content = vim.fn.getreg(vim.v.event.regname or '"')
				-- print('Deleted/yanked:\n' .. content)
				Game.eat_text(content:gsub("[\r\n]+", ""))
			end
		end,
	})
end

function M.open()
	vim.api.nvim_open_win(M._store.game_buf, false, {
		relative = "editor",
		width = Game.width,
		height = Game.height,
		col = vim.o.columns - Game.width - 2, -- 2 = small padding
		row = vim.o.lines - Game.height - 3 - 1, -- status + cmdline + padding + lualine
		style = "minimal",
		border = "single", -- or 'rounded', 'none', etc.
		focusable = false,
	})
end

return M
