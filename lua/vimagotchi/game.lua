local M = {}

M._state = {
  timer = 0,
  pos = {
    x = 4,
    y = 4,
  },
  frame = 1,
  frame_eat = 1,
  text_to_eat = '',
}

M.height = 10
M.width = 40

local animation = {
  char_width = 3,
  char_height = 3,
  frames = {
    [[
⣀⣀⣀
⣯⣿⣽
⠈⠁⠁
  ]],
    [[
⣀⣀⣀
⣯⣿⣽
⠈⠈⠁
  ]],
    [[
⣀⣀⣀
⢯⣿⡽
⠈⠤⠁
  ]],
    [[
⣀⣀⣀
⣯⣿⣽
⠈⠈⠁
  ]],
  },
}

local animation = {
  char_width = 11,
  char_height = 7,
  frames = {
    [[
⠀⠀⠀⢀⣀⣀⣀⠀⠀⠀⠀
⠀⢠⡾⠿⡿⠿⡿⠿⣦⠀⠀
⠀⣿⣜⣃⠠⠠⢀⣛⣼⡇⠀
⢰⣿⠿⣷⣭⣭⣵⡿⢿⣷⠀
⢨⣿⣦⣼⣿⣿⣿⣤⣾⣯⠀
⠸⣿⣿⣿⣿⣿⣿⣿⣿⡿⠀
⠀⠘⠒⠊⠉⠉⠉⠒⠚⠀⠀
  ]],
    [[
⠀⠀⠀⢀⣀⣀⣀⠀⠀⠀⠀
⠀⢠⡾⠿⡿⠿⡿⠿⣦⠀⠀
⠀⣿⣌⣁⠠⠠⢀⣉⣼⡇⠀
⢰⣿⡿⢷⣭⣭⣵⠿⣿⣷⠀
⢨⣿⣷⣤⣿⣿⣧⣴⣿⣯⠀
⠸⣿⣿⣿⣿⣿⣿⣿⣿⡿⠀
⠀⠘⠒⠊⠉⠉⠉⠒⠚⠀⠀
  ]],
    [[
⠀⠀⠀⢀⣀⣀⣀⠀⠀⠀⠀
⠀⢠⡾⠿⡿⠿⡿⠿⣦⠀⠀
⠀⣿⣜⣃⠠⠠⢀⣛⣼⡇⠀
⢰⣿⡿⢷⣭⣭⣵⠿⣿⣷⠀
⢨⣿⣷⣤⣿⣿⣧⣴⣿⣯⠀
⠸⣿⣿⣿⣿⣿⣿⣿⣿⡿⠀
⠀⠘⠒⠊⠉⠉⠉⠒⠚⠀⠀
  ]],
    [[
⠀⠀⠀⢀⣀⣀⣀⠀⠀⠀⠀
⠀⢠⡾⠿⡿⠿⡿⠿⣦⠀⠀
⠀⣿⣜⣃⠠⠠⢀⣛⣼⡇⠀
⢰⣿⠿⣷⣭⣭⣵⡿⢿⣷⠀
⢨⣿⣦⣼⣿⣿⣿⣤⣾⣯⠀
⠸⣿⣿⣿⣿⣿⣿⣿⣿⡿⠀
⠀⠘⠒⠊⠉⠉⠉⠒⠚⠀⠀
  ]],
    [[
⠀⠀⠀⢀⣀⣀⣀⠀⠀⠀⠀
⠀⢠⡾⠿⡿⠿⡿⠿⣦⠀⠀
⠀⣿⣜⣃⠠⠠⢀⣛⣼⡇⠀
⢰⣿⠿⣷⣭⣭⣵⡿⢿⣷⠀
⢨⣿⣦⣼⣿⣿⣿⣤⣾⣯⠀
⠸⣿⠿⢿⣿⣿⣿⣿⣿⡿⠀
⠀⠈⠉⠉⠉⠉⠉⠒⠚⠀⠀
  ]],
  },
}

local animation_eat = {
  char_width = 11,
  char_height = 7,
  frames = {
    [[
⠀⠀⠀⢀⣀⣀⣀⠀⠀⠀⠀
⠀⢠⢪⡍⢫⣩⠋⣭⢢⠀⠀
⠀⣿⣤⡖⠁⠀⠑⣦⣼⡇⠀
⢰⣿⠿⣿⣶⣶⣾⡿⢿⣷⠀
⢨⣿⣦⣼⣿⣿⣿⣤⣾⣯⠀
⠸⣿⣿⣿⣿⣿⣿⣿⣿⡿⠀
⠀⠘⠒⠊⠉⠉⠉⠒⠚⠀⠀
  ]],
    [[
⠀⠀⠀⢀⣀⣀⣀⠀⠀⠀⠀
⠀⢠⢪⡍⢫⣩⠋⣭⢢⠀⠀
⠀⣿⣤⣶⠁⠀⢱⣦⣼⡇⠀
⢰⣿⠿⣿⣷⣶⣿⡿⢿⣷⠀
⢨⣿⣦⣼⣿⣿⣿⣤⣾⣯⠀
⠸⣿⣿⣿⣿⣿⣿⣿⣿⡿⠀
⠀⠘⠒⠊⠉⠉⠉⠒⠚⠀⠀
  ]],
  },
}

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

local function render_char_on_screen(character)
  local char_lines = vim.split(character, '\n')

  local lines = {}

  local pos = M._state.pos
  if pos.y > 1 then
    for y = 1, pos.y - 1 do
      -- lines[y] = padding .. char_lines[]
      lines[y] = ''
    end
  end

  for y = pos.y, pos.y + animation.char_height do
    local padding = string.rep(' ', pos.x - 1)
    lines[y] = padding .. char_lines[y + 1 - pos.y]

    if #M._state.text_to_eat > 0 and y == pos.y + 2 then
      -- local chars = vim.split(lines[y], '', { plain = true, trimempty = false })
      local chars = stringToArray(lines[y])
      local head, tail = vim.list_slice(chars, 1, #chars - 6), vim.list_slice(chars, #chars - 5)
      -- print(vim.inspect(head))
      -- -- print(vim.inspect(head))
      lines[y] = table.concat(head)
      -- print(lines[y])

      local eat_chars = stringToArray(M._state.text_to_eat)

      for char_index, char in ipairs(tail) do
        local eat_char = vim.list_slice(eat_chars, char_index, char_index + 1)

        if #eat_char == 0 or eat_char[1] == ' ' then
          lines[y] = lines[y] .. char
        else
          lines[y] = lines[y] .. eat_char[1]
        end
      end

      lines[y] = lines[y] .. table.concat(vim.list_slice(eat_chars, #tail + 1))

      -- lines[y] = lines[y]:sub(1, -13)
      -- lines[y] = lines[y] .. M._state.text_to_eat
      M._state.text_to_eat = M._state.text_to_eat:sub(2)
    end
  end

  return lines
end

function M.next_frame()
  M._state.timer = M._state.timer + 1

  local frameNr = M._state.frame
  local frame = animation.frames[frameNr]

  if #M._state.text_to_eat > 0 then
    if M._state.timer % 2 == 0 then
      M._state.frame_eat = M._state.frame_eat + 1
    end

    if M._state.frame_eat > #animation_eat.frames then
      M._state.frame_eat = 1
    end

    local eat_frame = animation_eat.frames[M._state.frame_eat]

    return render_char_on_screen(eat_frame)
  end

  if M._state.timer % 5 ~= 0 then
    return render_char_on_screen(frame)
  end

  frameNr = frameNr + 1
  if frameNr > #animation.frames then
    frameNr = 1
  end

  M._state.frame = frameNr

  -- move
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

  if pos.x > M.width - animation.char_width + 1 then
    pos.x = M.width - animation.char_width + 1
  elseif pos.x < 1 then
    pos.x = 1
  elseif pos.y > M.height - animation.char_height + 1 then
    pos.y = M.height - animation.char_height + 1
  elseif pos.y < 1 then
    pos.y = 1
  end

  return render_char_on_screen(frame)
end

function M.eat_text(text)
  local padding_chars = M.width - M._state.pos.x - 8 - #M._state.text_to_eat
  local padding = string.rep(' ', padding_chars)
  M._state.text_to_eat = M._state.text_to_eat .. padding .. text
end

return M
