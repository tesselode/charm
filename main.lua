local charm = require 'charm'

local ui = charm.new()

function love.keypressed(key)
	if key == 'escape' then love.event.quit() end
end

function love.draw()
	ui
		:new('rectangle', 50, 50, 100, 100)
			:fillColor(1/4, 1/4, 1/4)
			:outlineColor(1, 1, 1)
			:beginChildren()
				:new('rectangle', 50, 50, 100, 25)
					:fillColor(1, 0, 0)
			:endChildren()
		:draw()

	love.graphics.print(('Memory usage: %ikb'):format(collectgarbage 'count'))
	love.graphics.print(('Elements in pool: %i'):format(#ui._pool), 0, 16)
	love.graphics.print(('Elements in tree: %i'):format(#ui._tree), 0, 32)
end
