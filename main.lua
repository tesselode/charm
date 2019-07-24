local charm = require 'charm'

local ui = charm.new()

function love.draw()
	ui
		:beginGroup()
			:new('rectangle')
				:size(50, 50)
				:set('fillColor', 1, 0, 0)
		:endGroup()
			:x(200):y(200)
			:size(100, 100)
			:set('fillColor', 1/4, 1/4, 1/4)
		:beginGroup()
			:new('rectangle')
				:size(50, 50)
				:set('fillColor', 1, 0, 0)
		:endGroup()
			:wrap(25)
			:x(400):y(400)
			:set('fillColor', 1/4, 1/4, 1/4)
		:draw()

	love.graphics.print('Memory usage: ' .. math.floor(collectgarbage 'count') .. 'kb')
end
