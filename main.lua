local charm = require 'charm'

local ui = charm.new()

function love.keypressed(key)
	if key == 'escape' then love.event.quit() end
end

function love.draw()
	ui
		:new('rectangle', 50, 50, 100, 150)
			:fillColor(ui:get('@current', 'hovered') and {1/2, 1/2, 1/2} or {1/4, 1/4, 1/4})
			:on('click', function(button) print(button) end)
		:draw()

	love.graphics.print(('Memory usage: %ikb'):format(collectgarbage 'count'))
	love.graphics.print(('Elements in pool: %i'):format(#ui._pool), 0, 16)
	love.graphics.print(('Elements in tree: %i'):format(#ui._tree), 0, 32)
end
