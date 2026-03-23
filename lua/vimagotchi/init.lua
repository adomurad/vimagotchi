local M = {}

local Game = require("vimagotchi.game")

M._state = {
	is_running = false,
	game_buf = nil,
	win_id = nil,
	loop_timer = nil,
}

M._config = nil

local valid_args = { "Open", "Close" }

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
			print("Error: Vimagotchi requires an argument (Open, Close)")
			return
		end

		if args.args == "Open" then
			M.open()
		elseif args.args == "Close" then
			M.close()
		else
			print("Error: wrong arg!")
		end
	end, {
		desc = "Vimagotchi",
		nargs = 1, -- Expect exactly one argument
		complete = complete_my_cmd, -- Autocompletion function
	})
end

local function start_loop()
	if M._state.loop_timer == nil then
		error("vimagotchi: timer is missing")
		return
	end

	M._state.loop_timer:start(
		10,
		100,
		vim.schedule_wrap(function()
			local frame = Game.next_frame()
			vim.api.nvim_buf_set_lines(M._state.game_buf, 0, -1, true, frame)
		end)
	)
end

---@class EatOn
---@field delete? boolean
---@field change? boolean
---@field yank? boolean

---@class VimagotchiOpts
---@field eat_on? EatOn

---@type VimagotchiOpts
local default_options = {
	eat_on = {
		delete = true,
		change = false,
		yank = false,
	},
}

---@param opts? VimagotchiOpts
function M.setup(opts)
	create_user_commands()

	opts = opts or {}
	M._config = vim.tbl_deep_extend("force", default_options, opts)

	Game.init()

	M._state.game_buf = vim.api.nvim_create_buf(false, true)

	M._state.loop_timer = vim.uv.new_timer()

	vim.api.nvim_create_autocmd("TextYankPost", {
		callback = function(ev)
			local match_str = ""

			if M._config.eat_on.yank then
				match_str = match_str .. "y"
			end

			if M._config.eat_on.delete then
				match_str = match_str .. "d"
			end

			if M._config.eat_on.change then
				match_str = match_str .. "c"
			end

			if #match_str == 0 then
				return
			end

			-- if vim.v.event.operator:match("[ydc]") then
			if vim.v.event.operator:match("[" .. match_str .. "]") then
				local content = vim.fn.getreg(vim.v.event.regname or '"')
				Game.eat_text(content:gsub("[\r\n]+", ""))
			end
		end,
	})
end

function M.open()
	start_loop()

	M._state.win_id = vim.api.nvim_open_win(M._state.game_buf, false, {
		relative = "editor",
		width = Game.width,
		height = Game.height,
		col = vim.o.columns / 8,
		row = vim.o.lines / 2,
		style = "minimal",
		border = "none", -- or 'rounded', 'none', etc.
		focusable = false,
	})
	Game.win_id = M._state.win_id
end

function M.close()
	if M._state.loop_timer == nil then
		error("vimagotchi: timer is missing")
		return
	end

	M._state.loop_timer:stop()

	if M._state.win_id ~= nil then
		vim.api.nvim_win_close(M._state.win_id, true)
		M._state.win_id = nil
	end
end

return M
