local charm = require 'charm'

local testFont = love.graphics.newFont(32)

local layout = charm.new()

function love.draw()
	local time = love.timer.getTime()
	layout
		:new 'rectangle'
			:beginChildren()
				:new 'transform'
					:center(love.graphics.getWidth()/2)
					:middle(love.graphics.getHeight()/2)
					:angle(time % (2 * math.pi))
					:shearX(1 + .5 * math.sin(time * 1.1))
					:shearY(.5 * math.cos(time * 1.3))
					:beginChildren()
						:new('rectangle', 0, 0, 200, 100)
							:outlineColor(.8, .2, .2)
							:outlineWidth(20)
					:endChildren()
				:new 'transform'
					:center(love.graphics.getWidth()/2)
					:middle(love.graphics.getHeight()/2)
					:angle(time % (2 * math.pi))
					:shearX(1 + .5 * math.cos(time * 1.3))
					:shearY(.5 * math.sin(time * 1.5))
					:beginChildren()
						:new('rectangle', 0, 0, 200, 100)
							:outlineColor(.8, .2, .2)
							:outlineWidth(20)
					:endChildren()
			:endChildren()
			:wrap(32)
			:outlineColor(.2, .2, .8)
			:outlineWidth(5)
			:cornerRadius(10)
		:new('text', testFont, 'The Rhombus')
			:center(layout:get('@previous', 'center'))
			:top(layout:get('@previous', 'bottom') + 8)
		:draw()

	love.graphics.print(string.format('Memory usage: %ikb', collectgarbage 'count'))
end
