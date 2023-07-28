local iter = vim.iter

local M = {}

function M.layout_tree(frame)
  local node = { type = frame[1] }
  if node.type == "leaf" then
    node.winid = frame[2]
  else
    iter(frame[2])
      :map(M.layout_tree)
      :enumerate()
      :each(function(i, child)
        node[i] = child
      end)
      :totable()
  end
  return node
end



return M
