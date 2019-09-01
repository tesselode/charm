local ui = require 'charm'.new()

function love.draw()
	if love.keyboard.isDown 'space' then
		ui:new('rectangle', 50, 50, 100, 100)
			:name 'test'
			:fillColor(.5, .5, .5)
	end
	ui:draw()
	love.graphics.print('Memory usage: ' .. math.floor(collectgarbage 'count') .. 'kb')
end
