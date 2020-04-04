local charm = require 'charm'

local ui = charm.new()

function love.keypressed(key)
	if key == 'escape' then love.event.quit() end
end

function love.draw()
	ui:new('element', 50, 50, 100, 150)
	if love.keyboard.isDown 'space' then
		ui:new 'element'
			:width(100)
			:height(100)
			:x(love.graphics.getWidth(), 1)
			:y(love.graphics.getHeight(), 1)
	end
	ui:drawDebug()

	love.graphics.print(('Memory usage: %ikb'):format(collectgarbage 'count'))
	love.graphics.print(('Elements in tree: %i'):format(#ui._tree), 0, 16)
	love.graphics.print(('Elements in pool: %i'):format(#ui._pool), 0, 32)
end
