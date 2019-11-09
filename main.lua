function love.load(arg)
	require('demos.' .. arg[1])
	local oldDraw = love.draw
	function love.draw()
		if oldDraw then oldDraw() end
		love.graphics.print(string.format('Memory usage: %ikb', collectgarbage 'count'))
	end
end
