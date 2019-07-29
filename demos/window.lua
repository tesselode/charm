--[[
	This is an example of how you could implement some higher level
	GUI controls using Charm. The window code is pretty gross
	looking when you see it all in one chunk, but if you split
	this up into multiple functions, it would be more pleasant.
]]

local charm = require 'charm'

local function lerp(a, b, f)
	return a + (b - a) * f
end

local font = love.graphics.newFont(18)
local testText = [[
Sapiente necessitatibus qui iure mollitia sequi eum nemo voluptatum. Molestiae placeat possimus consequatur tempore. Nam molestias vero iusto. Aperiam est est assumenda fugit sapiente suscipit rem. Expedita quam occaecati autem quo nam autem suscipit.

Sequi ipsum vel fugiat repellat esse amet qui quis. Animi ut quam repellendus. Soluta sapiente quibusdam qui incidunt et nobis eum.

Temporibus quam reprehenderit ut occaecati sed. Qui id ullam adipisci corrupti. Tempore numquam corporis odit ea et qui rerum.

Itaque saepe quod nihil non sed. Nihil voluptates dolor sit error laudantium eum ipsum excepturi. Ad et fuga impedit praesentium perspiciatis pariatur.

Eum molestiae nihil ut voluptatum maiores repellat. Nulla repellat id unde suscipit necessitatibus impedit. Sunt voluptatum cum minima sed. Officia adipisci et recusandae necessitatibus ea est.	
]]

local ui = charm.new()

local windowX = 100
local windowY = 100
local windowW = 400
local windowH = 300
local scrollAmount = .5

function love.draw()
	ui:new 'rectangle'
		:name 'window'
		:x(windowX)
		:y(windowY)
		:width(windowW)
		:height(windowH)
		:beginChildren()
			:new 'rectangle'
				:name 'titlebar'
				:beginChildren()
					:new('text', font, 'Test window')
				:endChildren()
				:wrap(4)
				:x(0)
				:width(ui:getWidth '@parent')
				:set('fillColor', 1/2, 1/2, 1/2)
			:new 'rectangle'
				:name 'windowBody'
				:top(ui:getBottom 'titlebar')
				:width(ui:getWidth '@parent')
				:height(ui:getHeight '@parent' - ui:getHeight 'titlebar')
				:beginChildren()
					:new 'rectangle'
						:name 'scrollbarContainer'
						:width(32)
						:height(ui:getHeight '@parent')
						:right(ui:getRight '@parent')
						:set('fillColor', 1/4, 1/4, 1/4)
						:beginChildren()
							:new 'rectangle'
								:name 'scrollbar'
								:width(ui:getWidth '@parent')
								:height(ui:getHeight '@parent' / 2)
								:y(lerp(0, ui:getHeight '@parent' - ui:getHeight '@current', scrollAmount))
								if ui:isHovered 'scrollbar' or ui:isHeld 'scrollbar' then
									ui:set('fillColor', 3/4, 3/4, 3/4)
								else
									ui:set('fillColor', 1/2, 1/2, 1/2)
								end
						ui:endChildren()
					:new 'rectangle'
						:name 'contentArea'
						:width(ui:getWidth '@parent' - ui:getWidth 'scrollbarContainer')
						:height(ui:getHeight '@parent')
						:set('fillColor', 1/5, 1/5, 1/5)
						:clip()
						:beginChildren()
							:new('paragraph', font, testText, ui:getWidth '@parent')
								:y(lerp(0, -(ui:getHeight '@current' - ui:getHeight '@parent'), scrollAmount))
						:endChildren()
				:endChildren()
		:endChildren()
	:draw()
	do
		local dragged, dx, dy = ui:isDragged 'titlebar'
		if dragged then
			windowX = windowX + dx
			windowY = windowY + dy
		end
	end
	do
		local dragged, _, dy = ui:isDragged 'scrollbar'
		if dragged then
			local newScrollbarY = ui:getY 'scrollbar' + dy
			scrollAmount = newScrollbarY / (ui:getHeight 'scrollbarContainer' - ui:getHeight 'scrollbar')
			scrollAmount = scrollAmount < 0 and 0 or scrollAmount > 1 and 1 or scrollAmount
		end
	end
end
