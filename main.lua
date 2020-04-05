local charm = require 'charm'

local ui = charm.new()

function love.keypressed(key)
	if key == 'escape' then love.event.quit() end
end

function love.draw()
	ui
		:new 'rectangle'
			:bounds(50, 50, 200, 100)
		:new 'rectangle'
			:left(ui:get('@previous', 'right'))
			:centerY(ui:get('@previous', 'centerY'))
			:size(50, 100)
		:draw()
		:drawDebug()

	love.graphics.print(('Memory usage: %ikb'):format(collectgarbage 'count'))
	love.graphics.print(('Elements in pool: %i'):format(#ui._pool), 0, 16)
	love.graphics.print(('Elements in tree: %i'):format(#ui._tree), 0, 32)
end
