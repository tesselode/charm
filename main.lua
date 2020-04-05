local charm = require 'charm'

local font = love.graphics.newFont(32)

local ui = charm.new()

function love.keypressed(key)
	if key == 'escape' then love.event.quit() end
end

function love.draw()
	ui
		:new('polygon', 0, 0, 50, 0, 75, 100, 25, 100)
			:x(100):y(100)
			:fillColor(1/3, 1/3, 1/3)
		:draw()

	love.graphics.print(('Memory usage: %ikb'):format(collectgarbage 'count'))
	love.graphics.print(('Elements in pool: %i'):format(#ui._pool), 0, 16)
	love.graphics.print(('Elements in tree: %i'):format(#ui._tree), 0, 32)
end
