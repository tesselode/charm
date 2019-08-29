local testFont = love.graphics.newFont(16)
local testText = [[
Sapiente necessitatibus qui iure mollitia sequi eum nemo voluptatum. Molestiae placeat possimus consequatur tempore. Nam molestias vero iusto. Aperiam est est assumenda fugit sapiente suscipit rem. Expedita quam occaecati autem quo nam autem suscipit.

Sequi ipsum vel fugiat repellat esse amet qui quis. Animi ut quam repellendus. Soluta sapiente quibusdam qui incidunt et nobis eum.

Temporibus quam reprehenderit ut occaecati sed. Qui id ullam adipisci corrupti. Tempore numquam corporis odit ea et qui rerum.

Itaque saepe quod nihil non sed. Nihil voluptates dolor sit error laudantium eum ipsum excepturi. Ad et fuga impedit praesentium perspiciatis pariatur.

Eum molestiae nihil ut voluptatum maiores repellat. Nulla repellat id unde suscipit necessitatibus impedit. Sunt voluptatum cum minima sed. Officia adipisci et recusandae necessitatibus ea est.	
]]

local function lerp(a, b, f)
	return a + (b - a) * f
end

local function clamp(x, min, max)
	return x < min and min or x > max and max or x
end

local function scrollbar(ui, name, x, y, h, scrollAmount)
	local handleHeight = h/2
	local handleY = lerp(0, h - handleHeight, scrollAmount)
	local handleName = name .. '.handle'
	ui:new('rectangle', x, y, 25, h)
		:name(name)
		:fillColor(1/4, 1/4, 1/4)
		:beginChildren()
			:new('rectangle', 0, handleY, 25, handleHeight)
				:name(handleName)
				if ui:isHovered(handleName) or ui:isHeld(handleName) then
					ui:fillColor(3/4, 3/4, 3/4)
				else
					ui:fillColor(1/2, 1/2, 1/2)
				end
		ui:endChildren()
	local dragged, _, dy = ui:isDragged(handleName)
	if dragged then
		scrollAmount = scrollAmount + dy / (h - handleHeight)
		scrollAmount = clamp(scrollAmount, 0, 1)
	end
	return scrollAmount
end

local function scrollArea(ui, x, y, w, h, scrollAmount, content)
	ui:new('rectangle', x, y, w, h)
		:clip()
		:beginChildren()
			ui:new 'rectangle'
				:width(w)
				:beginChildren()
					content(ui)
				ui:endChildren()
				:wrap()
				:y(-(ui:getHeight '@current' - h) * scrollAmount)
		:endChildren()
end

local function window(ui, name, title, x, y, w, h, scrollAmount, content)
	ui:new('rectangle', x, y, w, h)
		:name(name)
		:fillColor(1/6, 1/6, 1/6)
		:beginChildren()
			-- titlebar
			:new 'rectangle'
				:name(name .. '.titlebar')
				:beginChildren()
					:new('text', testFont, title)
				:endChildren()
				:wrap(4)
				:x(0):y(0)
				:width(w)
				:fillColor(1/3, 1/3, 1/3)
			-- scrollbar
			scrollAmount = scrollbar(ui, name .. '.scrollbar',
					0, ui:getBottom(name .. '.titlebar'),
					h - ui:getHeight(name .. '.titlebar'),
					scrollAmount)
				ui:right(w)
			-- content area
			scrollArea(ui, 0, ui:getHeight(name .. '.titlebar'),
				w - ui:getWidth(name .. '.scrollbar'), h - ui:getHeight(name .. '.titlebar'),
				scrollAmount, content)
		ui:endChildren()
	local dragged, dx, dy = ui:isDragged(name .. '.titlebar')
	if dragged then
		x = x + dx
		y = y + dy
	end
	return x, y, scrollAmount
end

local function windowContent(ui)
	ui:new('paragraph', testFont, testText, ui:getWidth '@parent')
end

local ui = require 'charm'.new()
local windowX, windowY = 50, 50
local scrollAmount = 0

function love.draw()
	windowX, windowY, scrollAmount = window(ui, 'window', 'Hello world!',
		windowX, windowY, 300, 300, scrollAmount, windowContent)
	ui:draw()
end
