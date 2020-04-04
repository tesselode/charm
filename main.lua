local charm = require 'charm'

local ui = charm.new()

function love.keypressed(key)
	if key == 'escape' then love.event.quit() end
end

function love.draw()
	ui
		:name 'fred':new('element', 50, 50, 100, 150)
			:beginChildren()
				:new('element', 50, 50, 50, 50)
			:endChildren()
	if love.keyboard.isDown 'space' then
		ui:new 'element'
			:width(100)
			:height(100)
			:x(ui:get('@previous', 'x', 1))
			:y(ui:get('@previous', 'y', .5), .5)
	end
	ui:drawDebug()

	love.graphics.print(('Memory usage: %ikb'):format(collectgarbage 'count'))
	love.graphics.print(('Elements in pool: %i'):format(#ui._pool), 0, 16)
end
