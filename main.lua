local charm = require 'charm'

local ui = charm.new()

function love.draw()
	ui
		:new 'rectangle'
			:width(100 + 50 * math.sin(love.timer.getTime()))
			:height(100 + 50 * math.cos(love.timer.getTime() * 1.1))
			:center(200):middle(200)
			:set('fillColor', .5, .5, .5)
		:new 'rectangle'
			:size(ui:getSize '@previous')
			:center(500):middle(300)
			:set('fillColor', .5, .5, .5)
		:draw()

	love.graphics.print('Memory usage: ' .. math.floor(collectgarbage 'count') .. 'kb')
end
