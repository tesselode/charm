local charm = require 'charm'

local ui = charm.new()

function love.keypressed(key)
	if key == 'escape' then love.event.quit() end
end

function love.draw()
	ui
		:new 'rectangle'
			:beginChildren()
				:new('rectangle', 100, 100, 100, 100)
				:new('rectangle', 150, 150, 100, 100)
			:endChildren()
			:wrap()
			:centerX(love.graphics.getWidth() / 2)
			:centerY(love.graphics.getHeight() / 2)
			if love.keyboard.isDown 'space' then
				ui:origin(0, 0)
				ui:padLeft(50)
			end
		ui:draw()
		:drawDebug()

	love.graphics.print(('Memory usage: %ikb'):format(collectgarbage 'count'))
	love.graphics.print(('Elements in pool: %i'):format(#ui._pool), 0, 16)
	love.graphics.print(('Elements in tree: %i'):format(#ui._tree), 0, 32)
end
