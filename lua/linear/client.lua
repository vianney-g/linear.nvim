local Client = {}

local linear_api_url = "https://api.linear.app/graphql/"


function Client:new(api_key)
  local o = {}
  setmetatable(o, self)
  self.__index = self
  self.api_key = api_key
  return o
end

function Client:post(endpoint, body)
  local resp = vim.fn.systemlist({
    "curl",
    "-s",
    "-X",
    "POST",
    "-H",
    "Content-Type: application/json",
    "-H",
    "Authorization: " .. self.api_key,
    "-d",
    body,
    linear_api_url .. endpoint,
  })
  -- parse json response and returns its tables
  return vim.fn.json_decode(resp[1])
end

local function assignee_filter(filters)
  local assignee = filters["assignee"]
  if assignee == nil then
    return ""
  elseif assignee == "me" then
    return "assignee: { isMe: { eq: true } }"
  else
    return "assignee: { email: { eq: \\\"" .. assignee .. "\\\" } }"
  end
end

local function team_filter(filters)
  local team = filters["team"]
  if team == nil then
    return ""
  else
    return "team: { key: { eq: \\\"" .. team .. "\\\" } }"
  end
end

local function filters_str(filters)
  local all_filters = {
    assignee_filter(filters),
    team_filter(filters),
  }

  local joined_filters = table.concat(all_filters, ", ")
  return "filter: { " .. joined_filters .. " }"
end

function Client:get_issues(filters)
  filters = filters or {}

  local body = string.format([[
      {
        "query": "query { issues( %s ) { nodes { branchName identifier title description } } }"
      }
    ]], filters_str(filters))
  return self:post("", body)["data"]["issues"]["nodes"]
end

return Client
