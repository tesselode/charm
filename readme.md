Charm
=====
Charm is a library for LÖVE that facilitates arranging and drawing graphics, such as shapes, images, and text. It also handles mouse events, so it can be used for basic UI tasks, like creating buttons.

This library is similar to [Boxer](https://github.com/tesselode/boxer), but it's **immediate mode**, which means that instead of creating objects that represent each graphic you want to draw, you simply tell Charm what you want to draw on each frame.

```lua
local ui = require 'charm'.new()
local labelFont = love.graphics.newFont(24)

function love.draw()
	ui
		:new 'rectangle'
			:name 'container'
			:beginChildren()
			for i = 1, 5 do
				ui:new('ellipse', nil, nil, 32, 32)
					:center(300 + 150 * math.sin(love.timer.getTime() * (1 + i/10)))
					:middle(300 + 150 * math.cos(love.timer.getTime() * (1 + i/11)))
					:set('outlineColor', 1, 1, 1)
			end
			ui:endChildren()
			:wrap()
			:set('outlineColor', 1, 1, 1)
		:new('text', labelFont, 'Microbes')
			:name 'label'
			:left(ui:getRight 'container' + 64)
			:middle(ui:getY('container', 2/3))
		:draw()
	love.graphics.line(
		ui:getRight 'label', ui:getBottom 'label',
		ui:getLeft 'label', ui:getBottom 'label',
		ui:getRight 'container', ui:getMiddle 'container'
	)
```

Installation
------------
To use Charm, place charm.lua in your project, and then `require` it in each file where you need to use it:

```lua
local charm = require 'charm' -- if your charm.lua is in the root directory
local charm = require 'path.to.charm' -- if it's in subfolders
```

Usage
-----

### Drawing elements
To use Charm, first we need to create a UI object.
```lua
local ui = charm.new()
```
This object is responsible for arranging and drawing graphics. In `love.draw`, we tell the UI object what to draw, and once we're done, we call the `draw` function to display those graphics on screen.

This code will draw a grey rectangle on the screen:
```lua
function love.draw()
	ui:new('rectangle', 50, 50, 100, 150)
	ui:set('fillColor', .5, .5, .5)
	ui:draw()
end
```
- The `new` function defines a new **element**. The first argument is always the type of the element. The arguments after that depend on what type of element we created. For rectangles, we can specify an x position, y position, width and height.
- The `set` function sets a property on the most recently created element. Which properties are available depends on what element we're modifying. In this case we're specifying a fill color for the rectangle (otherwise it would be invisible).
- The `draw` function tells the UI object that we're done specifying our elements and we can actually display them now.

Most of the UI object's functions return the UI object itself, so we can chain the methods together and write the same code like this:
```lua
function love.draw()
	ui
		:new('rectangle', 50, 50, 100, 150)
			:set('fillColor', .5, .5, .5)
		:draw()
end
```
Format the code based on your personal preference.

### Positioning elements relative to each other
Once we define an element, we can get any point along the x or y axis using `ui.getX` and `ui.getY`:
```lua
function love.draw()
	ui
		:new('rectangle', 50, 50, 100, 150)
			:name 'eleanor'
			:set('fillColor', .5, .5, .5)
		:draw()
	print(ui:getX('eleanor', .5), ui:getY('eleanor', 1))
end
```
`getX` and `getY` take two arguments:
- The first is the **name** of the element to get a point on. Elements don't have names by default, so in this example, I named the rectangle Eleanor, because sometimes abstract concepts should have human names.
- The second argument is the **anchor**, which is a number from 0-1 that represents how far along the axis we should travel to find the point. So `getX(name, 0)` would get the x position of the left edge of the box, `getX(name, 0.5)` would get the x position of the horizontal center of the box, and `getX(name, 1)` would get the x position of the right edge of the box. We can also use any anchor in between.

There's also some shortcut functions for getting x and y positions: `getLeft`, `getCenter`, and `getRight` return the left edge, horizontal center, and right edge of a box respectively, and `getTop`, `getMiddle`, and `getBottom` return the top edge, vertical center, and bottom edge of a box respectively. So we could write the above code like this:
```lua
function love.draw()
	ui
		:new('rectangle', 50, 50, 100, 150)
			:name 'eleanor'
			:set('fillColor', .5, .5, .5)
		:draw()
	print(ui:getCenter 'eleanor', ui:getBottom 'eleanor')
end
```
Now that we know how to get the positions of objects, we can set them as well. `ui.x` and `ui.y` take two arguments: the target position and the anchor to set to that position. Note that the position setter functions do *not* take a name argument, as they will always modify the position of the most recently created element.

This code will draw a rectangle that's always flush with the bottom-right corner of the screen:
```lua
function love.draw()
	ui
		:new 'rectangle' -- we can leave off the x, y, width, and height arguments, as they will default to 0
			:width(100) -- surprise! there are also "width" and "height" functions
			:height(150)
			:x(love.graphics.getWidth(), 1)
			:y(love.graphics.getHeight(), 1)
			:set('fillColor', .5, .5, .5)
		:draw()
end
```
Like with the position getter functions, we have shortcut functions for setting the position of an element: `left`, `center`, `right`, `top`, `middle`, and `bottom`. So we could write the above code like this:
```lua
function love.draw()
	ui
		:new 'rectangle'
			:width(100)
			:height(150)
			:right(love.graphics.getWidth())
			:bottom(love.graphics.getHeight())
			:set('fillColor', .5, .5, .5)
		:draw()
end
```
We can use the getters and setters to easily position graphics relative to each other without having to do a lot of math. The following code will display a white rectangle and a red rectangle that's 50 pixels to the right and vertically aligned:
```lua
function love.draw()
	ui
		:new('rectangle', 50, 50, 100, 150)
			:name 'eleanor'
			:set('fillColor', 1, 1, 1)
		:new 'rectangle'
			:width(50):height(50)
			:left(ui:getRight 'eleanor')
			:middle(ui:getMiddle 'eleanor')
		:draw()
end
```
