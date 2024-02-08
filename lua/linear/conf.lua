local pathlib = require("plenary.path")
local with = require("plenary.context_manager").with
local open = require("plenary.context_manager").open

local function get_conf_file()
  local config_root = pathlib.new(vim.fn.expand("$XDG_CONFIG_HOME"))

  if not config_root:is_dir() then
    if vim.fn.has("win32") > 0 then
      config_root = pathlib.new(vim.fn.expand("~/AppData/Local"))
    else
      config_root = pathlib.new(vim.fn.expand("~/.config"))
    end
  end

  if not config_root:is_dir() then
    print("Error: could not find config path")
    return
  end

  local config_dir = config_root / "linear_nvim"

  if not config_dir:exists() then
    config_dir:mkdir()
  end

  return config_dir / "credentials.json"
end

local function read_api_key()
  local conf_file = get_conf_file()
  if conf_file == nil or not conf_file:exists() then
    return nil
  end
  return with(open(conf_file, "r"), function(f)
    local content = f:read()
    return vim.fn.json_decode(content)["api_key"]
  end)
end

local function set_api_key(api_key)
  vim.g.linear_api_key = api_key
end

local function ask_api_key()
  -- Ask for api key and save it to credentials.json
  local api_key = vim.fn.input("Enter your Linear API key: ")
  local conf = { api_key = api_key }
  local conf_file = get_conf_file()
  if not conf_file then
    return
  end

  with(open(conf_file, "w"), function(f)
    f:write(vim.fn.json_encode(conf))
  end)
  return api_key
end

local function reset()
  set_api_key(ask_api_key())
end

local function setup(api_key)
  if api_key == nil then
    api_key = read_api_key()
  end

  if api_key == nil then
    api_key = ask_api_key()
  end

  set_api_key(api_key)
end

return {
  setup = setup,
  reset = reset,
}
