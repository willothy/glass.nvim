local object = require("glass.object")
local class = object.class
local Frame = require("glass.frame")
local Window = require("glass.window")

---@class Glass.TabPage
---@field topframe Glass.Sized
---@field width integer
---@field height integer
---@field tabpage integer
---@field new fun(tabpage: tabpage?): Glass.TabPage Create a new TabPage object from a tabpage handle
local TabPage = class("TabPage")

---@param tabpage tabpage?
function TabPage:init(tabpage)
  tabpage = tabpage or vim.api.nvim_get_current_tabpage()
  if not vim.api.nvim_tabpage_is_valid(tabpage) then
    error(("Tabpage %s is not valid"):format(tabpage))
  end
  local kind, val = unpack(vim.fn.winlayout(tabpage))
  if kind == "leaf" then
    self.topframe = Window:new(val, nil)
  else
    self.topframe = Frame:new(kind, val)
  end
  self.width = vim.o.columns
  self.height = vim.o.lines
  self.tabpage = tabpage
end

function TabPage:refresh()
  self:init(self.tabpage)
end

---List all windows in the layout
---@return Glass.Window[]
function TabPage:windows()
  local windows = {}
  local function add_windows(frame)
    if frame.children then
      for _, child in ipairs(frame.children) do
        add_windows(child)
      end
    else
      table.insert(windows, frame)
    end
  end
  add_windows(self.topframe)
  return windows
end

---List all frames in the layout
---@return Glass.Frame[]
function TabPage:frames()
  local frames = {}
  local function add_frames(frame)
    if frame.children then
      table.insert(frames, frame)
      for _, child in ipairs(frame.children) do
        add_frames(child)
      end
    end
  end
  add_frames(self.topframe)
  return frames
end

return TabPage
