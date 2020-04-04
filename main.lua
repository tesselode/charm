local charm = require 'charm'

local loremIpsum = [[


Voluptate magnam sequi et accusantium officiis dignissimos.

Nisi eaque officia omnis.
]]

local font = love.graphics.newFont(16)

local ui = charm.new()

function love.keypressed(key)
	if key == 'escape' then love.event.quit() end
end

function love.draw()
	ui
		:new('text', font, loremIpsum, 'center', 600)
			:x(50):y(50)
			:color(1, 0, 0)
			:shadowColor(0, 1, 0)
			:shadowOffset(4, 40)
		:draw()
		:drawDebug()

	love.graphics.print(('Memory usage: %ikb'):format(collectgarbage 'count'))
	love.graphics.print(('Elements in pool: %i'):format(#ui._pool), 0, 16)
	love.graphics.print(('Elements in tree: %i'):format(#ui._tree), 0, 32)
end
