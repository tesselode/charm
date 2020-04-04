local charm = require 'charm'

local ui = charm.new()

function love.keypressed(key)
	if key == 'escape' then love.event.quit() end
end

function love.draw()
	ui
		:new('rectangle', 50, 50, 100, 100)
			:fillColor(ui:get('@selected', 'hovered') and {.5, .5, .5} or {.25, .25, .25})
			:outlineColor(1, 1, 1)
			:beginChildren()
				:new('rectangle', 50, 50, 100, 100)
					:fillColor(ui:get('@selected', 'hovered') and {1, 1, 1} or {1, 0, 0})
				:new('rectangle', 25, 75, 100, 25)
					:fillColor(ui:get('@selected', 'hovered') and {1, 1, 1} or {0, 0, 1})
			:endChildren()
			:clip()
			:onEnter(function() print 'enter' end)
			:onExit(function() print 'exit' end)
			:onClick(function() print 'click' end)
		:draw()

	love.graphics.print(('Memory usage: %ikb'):format(collectgarbage 'count'))
	love.graphics.print(('Elements in pool: %i'):format(#ui._pool), 0, 16)
	love.graphics.print(('Elements in tree: %i'):format(#ui._tree), 0, 32)
end
