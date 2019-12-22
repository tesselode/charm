local charm = require 'charm'

local font = love.graphics.newFont(18)

local layout = charm.new()

local text = [[Good afternoon. The Lakitu Bros., here, reporting live from just outside the Princess's castle. Mario has just arrived on the scene, and we'll be filming the action live as he enters the castle and pursues the missing Power Stars. As seasoned cameramen, we'll be shooting from the recommended angle, but you can change the camera angle by pressing the camera up, camera right, camera down, and camera left buttons. If we can't adjust the view any further, we'll buzz. To take a look at the surroundings, stop and press the camera up button. Press A to resume play. Switch camera modes with the R Button. Signs along the way will review these instructions. For now, reporting live, this has been the Lakitu Bros.]]
local textScrollY = 0
local textHeight = 0

local targetAnimationProgress = 0
local animationProgress = 0

function love.update(dt)
	if love.keyboard.isDown 'up' then
		textScrollY = textScrollY - 300 * dt
	end
	if love.keyboard.isDown 'down' then
		textScrollY = textScrollY + 300 * dt
	end
	textScrollY = math.min(textScrollY, textHeight - 230)
	textScrollY = math.max(textScrollY, 0)

	animationProgress = animationProgress + (targetAnimationProgress - animationProgress) * 10 * dt
end

function love.keypressed(key)
	if key == 'space' then
		targetAnimationProgress = targetAnimationProgress == 0 and 1 or 0
	end
end

function love.draw()
	layout
		:new 'transform'
			:beginChildren()
				:new('rectangle', 0, 0, 300, 250)
					:beginChildren()
						:new('paragraph', font, text, 280, 'left', 10, 10 - textScrollY)
							:color(0, 0, 0)
						textHeight = layout:get('@current', 'height')
					layout:endChildren()
					:fillColor(.8, .8, .8)
					:clip()
			:endChildren()
			:left(100):top(100)
			:scale(animationProgress)
			:angle((1 + animationProgress) * math.pi)
		layout:draw()
end
