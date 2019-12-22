local charm = require 'charm'

local font = love.graphics.newFont(18)
local menuPadding = 10
local menuHeight = 300

local function renderMenuItem(layout, text, selected)
	local limit = layout:get('@parent', 'width') - menuPadding * 2
	layout:new 'rectangle'
		-- draw text
		:beginChildren()
			:new('paragraph', font, text, limit, 'left', menuPadding, menuPadding)
				:color(1, 1, 1)
				:shadowColor(0, 0, 0)
		:endChildren()
		:wrap()
		:pad(menuPadding)
		-- if the menu item is selected, add a background behind the text
		if selected then
			layout:beginChildren()
				:new 'rectangle'
					:size(layout:get('@parent', 'size'))
					:fillColor(.5, .5, .5)
					:z(-1)
			:endChildren()
		end
	return layout
end

local menuChoices = {
	'play',
	'options',
	'more options',
	'level editor',
	'this is a longer menu option that spans multiple lines.',
	'Asperiores voluptas quia quos aperiam est est. Delectus asperiores nihil officiis veritatis. Est in accusantium aut expedita.',
	'lorem',
	'ipsum',
	'dolor',
	'sit',
	'amet',
	'quit',
}
local selectedMenuChoice = 1
local targetMenuScrollY = 0
local menuScrollY = 0
local menuChoicesHeight = 0

function love.update(dt)
	menuScrollY = menuScrollY + (targetMenuScrollY - menuScrollY) * 10 * dt
	menuScrollY = math.min(menuScrollY, menuChoicesHeight - menuHeight)
	menuScrollY = math.max(menuScrollY, 0)
end

function love.keypressed(key)
	if key == 'up' and selectedMenuChoice > 1 then
		selectedMenuChoice = selectedMenuChoice - 1
	end
	if key == 'down' and selectedMenuChoice < #menuChoices then
		selectedMenuChoice = selectedMenuChoice + 1
	end
end

local layout = charm.new()

function love.draw()
	layout
		-- this rectangle is the blue bg/white outline rectangle
		-- that contains the menu
		:new 'rectangle'
			:centerX(love.graphics.getWidth() / 2)
			:centerY(love.graphics.getHeight() / 2)
			:size(400, menuHeight)
			:beginChildren()
				-- this rectangle holds all the menu items and handles scrolling
				:new 'rectangle'
					:width(layout:get('@parent', 'width'))
					:top(-menuScrollY)
					:beginChildren()
						local previousBottom = 0
						for choiceIndex, choice in ipairs(menuChoices) do
							local selected = choiceIndex == selectedMenuChoice
							renderMenuItem(layout, choice, selected)
								:top(previousBottom)
							if selected then
								targetMenuScrollY = layout:get('@current', 'centerY') - menuHeight/2
							end
							previousBottom = layout:get('@current', 'bottom')
						end
						menuChoicesHeight = previousBottom
					layout:endChildren()
			:endChildren()
			:clip()
			:fillColor(.1, .1, .2)
			:outlineColor(1, 1, 1)
			:outlineWidth(2)
			:cornerRadius(4)
		:draw()
end
