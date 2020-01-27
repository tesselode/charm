# Basic usage

## Installation
To use Charm, place charm.lua in your project, and then `require` it in each file where you need to use it:

```lua
local charm = require 'charm' -- if your charm.lua is in the root directory
local charm = require 'path.to.charm' -- if it's in subfolders
```

## Drawing elements
To use Charm, first we need to create a layout object.
```lua
local layout = charm.new()
```
This object is responsible for arranging and drawing graphics. In `love.draw`, we tell the layout object what to draw, and once we're done, we call the `draw` function to display those graphics on screen.

This code will draw a grey rectangle on the screen:
```lua
function love.draw()
	layout:new('rectangle', 50, 50, 100, 150)
	layout:fillColor(.5, .5, .5)
	layout:draw()
end
```
- The `new` function defines a new **element**. The first argument is always the type of the element. The arguments after that depend on what type of element we created. For rectangles, we can specify an x position, y position, width and height.
- Functions like `fillColor` set a property on the most recently created element. Which properties are available depends on what element we're modifying. In this case we're specifying a fill color for the rectangle (otherwise it would be invisible).
- The `draw` function tells the layout object that we're done specifying our elements and we can actually display them now.

Most of the layout object's functions return the layout object itself, so we can chain the methods together and write the same code like this:
```lua
function love.draw()
	layout
		:new('rectangle', 50, 50, 100, 150)
			:fillColor(.5, .5, .5)
		:draw()
end
```
You don't have to use method chaining, I just think it looks nice.

## Positioning elements relative to each other
Once we define an element, we can get any point along the x or y axis using `layout.get`:
```lua
function love.draw()
	layout
		:new('rectangle', 50, 50, 100, 150)
			:name 'eleanor'
			:fillColor(.5, .5, .5)
		:draw()
	print(layout:get('eleanor', 'x', .5), layout:get('eleanor', 'y', 1))
end
```
`get` takes at least two arguments:
- The first is the **name** of the element to get a point on. Elements don't have names by default, so in this example, I named the rectangle Eleanor, because sometimes abstract concepts should have human names.
- The second is the name of the **property** we want to get. In this case, we're getting "x" and "y".

The next arguments depend on the property we're getting. In this case, the third argument is the **origin**, which is a number from 0-1 that represents how far along the axis we should travel to find the point. So `get(name, 'x', 0)` would get the x position of the left edge of the box, `get(name, 'x', 0.5)` would get the x position of the horizontal center of the box, and `get(name, 'x', 1)` would get the x position of the right edge of the box. We can also use any origin in between.

There's also some shortcut properties for getting x and y positions: `left`, `center`, and `right` return the left edge, horizontal center, and right edge of a box respectively, and `top`, `middle`, and `bottom` return the top edge, vertical center, and bottom edge of a box respectively. So we could write the above code like this:
```lua
function love.draw()
	layout
		:new('rectangle', 50, 50, 100, 150)
			:name 'eleanor'
			:fillColor(.5, .5, .5)
		:draw()
	print(layout:get('eleanor', 'left'), layout:get('eleanor', 'bottom'))
end
```
We can also set the positions of elements that we've created. `layout.x` and `layout.y` take two arguments: the target position and the origin to set to that position. Note that the position setter functions do *not* take a name argument, as they will always modify the position of the most recently created element.

This code will draw a rectangle that's always flush with the bottom-right corner of the screen:
```lua
function love.draw()
	layout
		:new 'rectangle' -- we can leave off the x, y, width, and height arguments, as they will default to 0
			:width(100) -- surprise! there are also "width" and "height" functions
			:height(150)
			:x(love.graphics.getWidth(), 1)
			:y(love.graphics.getHeight(), 1)
			:fillColor(.5, .5, .5)
		:draw()
end
```
Like with the position getter functions, we have shortcut functions for setting the position of an element: `left`, `center`, `right`, `top`, `middle`, and `bottom`. So we could write the above code like this:
```lua
function love.draw()
	layout
		:new 'rectangle'
			:width(100)
			:height(150)
			:right(love.graphics.getWidth())
			:bottom(love.graphics.getHeight())
			:fillColor(.5, .5, .5)
		:draw()
end
```
We can use the getters and setters to easily position graphics relative to each other without having to do a lot of math. The following code will display a white rectangle and a red rectangle that's 50 pixels to the right and vertically aligned:
```lua
function love.draw()
	layout
		:new('rectangle', 50, 50, 100, 150)
			:name 'eleanor'
			:fillColor(1, 1, 1)
		:new 'rectangle'
			:width(50):height(50)
			:left(layout:get('eleanor', 'right'))
			:middle(layout:get('eleanor', 'middle'))
		:draw()
end
```

## Grouping elements together
Any element can have any number of **child elements**. We can assign elements to a parent by placing them between a `beginChildren` and an `endChildren` call.
```lua
function love.draw()
	layout
		:new('rectangle', 50, 50, 100, 150)
			:beginChildren()
				:new('rectangle', 10, 10, 25, 25)
					:fillColor(1/2, 1/2, 1/2)
				:new('rectangle', 50, 50, 25, 25)
					:fillColor(1/2, 1/2, 1/2)
			:endChildren()
			:fillColor(1/4, 1/4, 1/4)
		:draw()
end
```
Child elements are positioned relative to their parent, so in this example, the two child rectangles would appear on screen at (60, 60) and (100, 100) respectively.

Earlier I said that setter functions always modify the most recently created element. There is one exception: when `endChildren` is called, the parent element is selected. So you can add children to an element and then modify the parent element after.

Sometimes you might want to position multiple elements as a single group. Charm provides a `wrap` function which adjusts the dimensions of a parent element to perfectly surround all its child elements. Then the parent element can be positioned, which moves the children as well. The following code will group two rectangles together and then center the whole group on screen.
```lua
function love.draw()
	layout
		:new 'rectangle'
			:beginChildren()
				:new('rectangle', 0, 0, 100, 100)
					:fillColor(1/2, 1/2, 1/2)
				:new('rectangle', 110, 0, 100, 100)
					:fillColor(1/2, 1/2, 1/2)
			:endChildren()
			:wrap()
			:center(love.graphics.getWidth()/2)
			:middle(love.graphics.getHeight()/2)
		:draw()
end
```

## Element selectors
Rather than using the names of an element to get information about it, we can use special keywords to select an element without having to give it a name first. Charm provides three keywords:
- `@current` - the element currently being modified
- `@previous` - the previously selected element
- `@parent` - the parent of the currently modified element

Here's a modified version of the above example that uses `@previous`, the most commonly useful keyword:
```lua
function love.draw()
	layout
		:new 'rectangle'
			:width(100)
			:beginChildren()
				:new('rectangle', 0, 0, 100, 100)
					:fillColor(1/2, 1/2, 1/2)
				:new 'rectangle'
					:left(layout:get('@previous', 'right') + 10)
					:y(0)
					:size(100, 100)
					:fillColor(1/2, 1/2, 1/2)
			:endChildren()
			:wrap()
			:center(love.graphics.getWidth()/2)
			:middle(love.graphics.getHeight()/2)
		:draw()
end
```
