local charm = require 'charm'

local ui = charm.new()

function love.draw()
	ui
		:beginGroup()
			:beginGroup()
				:new('rectangle', 50, 50, 200, 200)
					:set('fillColor', 1, 0, 0)
			:endGroup()
				:x(200):y(200)
				:size(100, 100)
				:clip()
				:set('fillColor', 1/4, 1/4, 1/4)
			:beginGroup()
				:new('rectangle', -50, -50, 60, 60)
					:set('fillColor', 1, 0, 0)
			:endGroup()
				:x(400):y(400)
				:size(100, 100)
				:clip()
				:set('fillColor', 1/4, 1/4, 1/4)
		:endGroup()
			:wrap(20)
			:size(ui:getWidth '@current' - 50, ui:getHeight '@current' - 50)
			:clip()
			:set('fillColor', 0, 1, 0)
		:draw()

	love.graphics.print('Memory usage: ' .. math.floor(collectgarbage 'count') .. 'kb')
end
