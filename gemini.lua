-- final output:
local blocks = {}

function inner_text(el)
  local fullText = ""
  if (el.content) then
    for i, v in ipairs(el.content) do
      if (v.content) then
        fullText = fullText .. inner_text(v)
      end
      if (v.text == nil) then
        fullText = fullText .. " "
      else
        fullText = fullText .. v.text
      end
    end
  else
    if (el.text) then
      fullText = fullText .. el.text
    end
  end
  return fullText
end

-- add a block to the 'blocks' output:
function add_block(el)
  table.insert(blocks, el)
end

function debug(el, level)
  -- print(type(el))
  level = level or 1
  local prefix = ""
  for i = 1, level do
    prefix = prefix .. " "
  end
  if (el.tag) then
    print(prefix .. el.tag .. ": " .. inner_text(el))
  end
  if (el.content) then
    level = level + 1
    debug(el.content, level)
  end
end

function link_filter()
  return {
    Link = function(el)
      -- print(el.tag .. " " .. el.target)
      return {
        pandoc.LineBreak(),
        pandoc.Str("=> " .. el.target .. " " .. inner_text(el) ),
        pandoc.LineBreak(),
      }
    end,
  }
end

function handle_block (el)
  -- print(el.tag)
  if (el.tag == "Header") then
    if (el.level > 3) then
      el.level = 3
    end
    local prefix = ""
    for i = 1, el.level do
      prefix = prefix .. "#"
    end
    if (el.level <= 3) then
      add_block(pandoc.Plain(prefix .. " " .. inner_text(el)))
    end
    return
  end
  if (el.tag == "HorizontalRule") then
    add_block(pandoc.Para("--------------------------------------------------------------------------------"))
    return
  end
  if (el.tag == "Link") then
    add_block(pandoc.Para(pandoc.Str("=> " .. el.target .. " " .. inner_text(el) )))
    return
  end
  if (el.tag == "Str") then
    add_block(pandoc.Para(el))
    return
  end
  if (el.tag == "OrderedList") then
    for i,v in ipairs(el.content) do
      local listItem = {}
      table.insert(listItem, pandoc.Str("* "))
      for j, item in ipairs(v) do
        local block_with_links = pandoc.walk_block(item, link_filter())
        local inlines = pandoc.utils.blocks_to_inlines({ block_with_links })
        for index,inlineElement in ipairs(inlines) do
          table.insert(listItem, inlineElement)
        end
      end
      add_block(pandoc.Para(listItem))
    end
    return
  end
  if(el.tag == "Para") then
    local block_with_links = pandoc.walk_block(el, link_filter())
    add_block(block_with_links)
    return
  end
  if (el.tag == "BulletList") then
    for i,v in ipairs(el.content) do
      local listItem = {}
      table.insert(listItem, pandoc.Str("* "))
      for j, item in ipairs(v) do
        local block_with_links = pandoc.walk_block(item, link_filter())
        local inlines = pandoc.utils.blocks_to_inlines({ block_with_links })
        for index,inlineElement in ipairs(inlines) do
          table.insert(listItem, inlineElement)
        end
      end
      add_block(pandoc.Para(listItem))
    end
    return
  end
  if (el.content and el.tag ~= "Link") then
    for i, child in ipairs(el.content) do
      handle_block(child)
    end
  end
end

function flatten_document (doc)
  for i,el in ipairs(doc.blocks) do
    handle_block(el)
  end
  return pandoc.Pandoc(blocks, doc.meta)
end

return {
  { Pandoc = flatten_document },
}