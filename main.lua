local charm = require 'charm'

local font = love.graphics.newFont(32)

local ui = charm.new()

function love.keypressed(key)
	if key == 'escape' then love.event.quit() end
end

function love.draw()
	ui
		:new('ellipse', 50, 50, 100, 150)
			:fillColor(ui:get('@current', 'hovered') and {.5, .5, .5} or {.25, .25, .25})
		:draw()

	love.graphics.print(('Memory usage: %ikb'):format(collectgarbage 'count'))
	love.graphics.print(('Elements in pool: %i'):format(#ui._pool), 0, 16)
	love.graphics.print(('Elements in tree: %i'):format(#ui._tree), 0, 32)
end
