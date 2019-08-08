Charm <!-- omit in toc -->
=====
Charm is a library for LÖVE that makes it easier to arrange and draw graphics, such as shapes, images, and text. It excels at relative positioning, which can become cumbersome as a layout gets more complex. It also handles mouse events, so it can be used for basic UI tasks, like creating buttons.

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

- [Installation](#installation)
- [Usage](#usage)
	- [Drawing elements](#drawing-elements)
	- [Positioning elements relative to each other](#positioning-elements-relative-to-each-other)
	- [Grouping elements together](#grouping-elements-together)
	- [Element selectors](#element-selectors)
	- [Mouse events](#mouse-events)
- [API](#api)
	- [charm](#charm)
		- [`charm.new()`](#charmnew)
	- [Ui](#ui)
		- [`Ui:new(elementType, ...)`](#uinewelementtype-)
		- [`Ui:getX(name, anchor)`](#uigetxname-anchor)
		- [`Ui:getLeft(name)`](#uigetleftname)
		- [`Ui:getCenter(name)`](#uigetcentername)
		- [`Ui:getRight(name)`](#uigetrightname)
		- [`Ui:getY(name, anchor)`](#uigetyname-anchor)
		- [`Ui:getTop(name)`](#uigettopname)
		- [`Ui:getMiddle(name)`](#uigetmiddlename)
		- [`Ui:getBottom(name)`](#uigetbottomname)
		- [`Ui:getZ(name)`](#uigetzname)
		- [`Ui:getWidth(name)`](#uigetwidthname)
		- [`Ui:getHeight(name)`](#uigetheightname)
		- [`Ui:getSize(name)`](#uigetsizename)
		- [`Ui:isHovered(name)`](#uiishoveredname)
		- [`Ui:isEntered(name)`](#uiisenteredname)
		- [`Ui:isExited(name)`](#uiisexitedname)
		- [`Ui:isHeld(name, button)`](#uiisheldname-button)
		- [`Ui:isPressed(name, button)`](#uiispressedname-button)
		- [`Ui:isReleased(name, button)`](#uiisreleasedname-button)
		- [`Ui:isDragged(name, button)`](#uiisdraggedname-button)
		- [`Ui:x(x, anchor)`](#uixx-anchor)
		- [`Ui:left(x)`](#uileftx)
		- [`Ui:center(x)`](#uicenterx)
		- [`Ui:right(x)`](#uirightx)
		- [`Ui:y(y, anchor)`](#uiyy-anchor)
		- [`Ui:top(y)`](#uitopy)
		- [`Ui:middle(y)`](#uimiddley)
		- [`Ui:bottom(y)`](#uibottomy)
		- [`Ui:z(z)`](#uizz)
		- [`Ui:width(width)`](#uiwidthwidth)
		- [`Ui:height(height)`](#uiheightheight)
		- [`Ui:size(width, height)`](#uisizewidth-height)
		- [`Ui:name(name)`](#uinamename)
		- [`Ui:set(property, ...)`](#uisetproperty-)
		- [`Ui:clip()`](#uiclip)
		- [`Ui:transparent()`](#uitransparent)
		- [`Ui:opaque()`](#uiopaque)
		- [`Ui:beginChildren()`](#uibeginchildren)
		- [`Ui:endChildren()`](#uiendchildren)
		- [`Ui:wrap(padding)`](#uiwrappadding)
		- [`Ui:draw()`](#uidraw)
	- [Element properties](#element-properties)
		- [Rectangle](#rectangle)
			- [`fillColor(r, g, b, a)`](#fillcolorr-g-b-a)
			- [`fillColor(color)`](#fillcolorcolor)
			- [`outlineColor(r, g, b, a)`](#outlinecolorr-g-b-a)
			- [`outlineColor(color)`](#outlinecolorcolor)
			- [`lineWidth(width)`](#linewidthwidth)
			- [`radiusX(radiusX)`](#radiusxradiusx)
			- [`radiusY(radiusY)`](#radiusyradiusy)
			- [`radius(radiusX, radiusY)`](#radiusradiusx-radiusy)
			- [`segments(segments)`](#segmentssegments)
		- [Ellipse](#ellipse)
			- [`fillColor(r, g, b, a)`](#fillcolorr-g-b-a-1)
			- [`fillColor(color)`](#fillcolorcolor-1)
			- [`outlineColor(r, g, b, a)`](#outlinecolorr-g-b-a-1)
			- [`outlineColor(color)`](#outlinecolorcolor-1)
			- [`lineWidth(width)`](#linewidthwidth-1)
			- [`segments(segments)`](#segmentssegments-1)
		- [Image](#image)
			- [`image(image)`](#imageimage)
			- [`scaleX(scaleX)`](#scalexscalex)
			- [`scaleY(scaleY)`](#scaleyscaley)
			- [`scale(scaleX, scaleY)`](#scalescalex-scaley)
			- [`color(r, g, b, a)`](#colorr-g-b-a)
			- [`color(color)`](#colorcolor)
		- [Text](#text)
			- [`font(font)`](#fontfont)
			- [`text(text)`](#texttext)
			- [`limit(limit)`](#limitlimit)
			- [`align(align)`](#alignalign)
			- [`scaleX(scaleX)`](#scalexscalex-1)
			- [`scaleY(scaleY)`](#scaleyscaley-1)
			- [`scale(scaleX, scaleY)`](#scalescalex-scaley-1)
			- [`color(r, g, b, a)`](#colorr-g-b-a-1)
			- [`color(color)`](#colorcolor-1)
			- [`shadowColor(r, g, b, a)`](#shadowcolorr-g-b-a)
			- [`shadowColor(shadowColor)`](#shadowcolorshadowcolor)
			- [`shadowOffsetX(shadowOffsetX)`](#shadowoffsetxshadowoffsetx)
			- [`shadowOffsetY(shadowOffsetY)`](#shadowoffsetyshadowoffsety)
			- [`shadowOffset(shadowOffsetX, shadowOffsetY)`](#shadowoffsetshadowoffsetx-shadowoffsety)
		- [Paragraph](#paragraph)
			- [`font(font)`](#fontfont-1)
			- [`text(text)`](#texttext-1)
			- [`scaleX(scaleX)`](#scalexscalex-2)
			- [`scaleY(scaleY)`](#scaleyscaley-2)
			- [`scale(scaleX, scaleY)`](#scalescalex-scaley-2)
			- [`color(r, g, b, a)`](#colorr-g-b-a-2)
			- [`color(color)`](#colorcolor-2)
			- [`shadowColor(r, g, b, a)`](#shadowcolorr-g-b-a-1)
			- [`shadowColor(shadowColor)`](#shadowcolorshadowcolor-1)
			- [`shadowOffsetX(shadowOffsetX)`](#shadowoffsetxshadowoffsetx-1)
			- [`shadowOffsetY(shadowOffsetY)`](#shadowoffsetyshadowoffsety-1)
			- [`shadowOffset(shadowOffsetX, shadowOffsetY)`](#shadowoffsetshadowoffsetx-shadowoffsety-1)

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
You don't have to use method chaining, I just think it looks nice.

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
We can also set the positions of elements that we've created. `ui.x` and `ui.y` take two arguments: the target position and the anchor to set to that position. Note that the position setter functions do *not* take a name argument, as they will always modify the position of the most recently created element.

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

### Grouping elements together
Any element can have any number of **child elements**. We can assign elements to a parent by placing them between a `beginChildren` and an `endChildren` call.
```lua
function love.draw()
	ui
		:new('rectangle', 50, 50, 100, 150)
			:beginChildren()
				:new('rectangle', 10, 10, 25, 25)
					:set('fillColor', 1/2, 1/2, 1/2)
				:new('rectangle', 50, 50, 25, 25)
					:set('fillColor', 1/2, 1/2, 1/2)
			:endChildren()
			:set('fillColor', 1/4, 1/4, 1/4)
		:draw()
end
```
Child elements are positioned relative to their parent, so in this example, the two child rectangles would appear on screen at (60, 60) and (100, 100) respectively.

Earlier I said that setter functions always modify the most recently created element. There is one exception: when `endChildren` is called, the parent element is selected. So you can add children to an element and then modify the parent element after.

Sometimes you might want to position multiple elements as a single group. Charm provides a `wrap` function which adjusts the dimensions of a parent element to perfectly surround all its child elements. Then the parent element can be positioned, which moves the children as well. The following code will group two rectangles together and then center the whole group on screen.
```lua
function love.draw()
	ui
		:new 'rectangle'
			:beginChildren()
				:new('rectangle', 0, 0, 100, 100)
					:set('fillColor', 1/2, 1/2, 1/2)
				:new('rectangle', 110, 0, 100, 100)
					:set('fillColor', 1/2, 1/2, 1/2)
			:endChildren()
			:wrap()
			:center(love.graphics.getWidth()/2)
			:middle(love.graphics.getHeight()/2)
		:draw()
end
```

### Element selectors
Rather than using the names of an element to get information about it, we can use special keywords to select an element without having to give it a name first. Charm provides three keywords:
- `@current` - the element currently being modified
- `@previous` - the second-most recently created element
- `@parent` - the parent of the currently modified element

Here's a modified version of the above example that uses `@previous`, the most commonly useful keyword:
```lua
function love.draw()
	ui
		:new 'rectangle'
			:width(100)
			:beginChildren()
				:new('rectangle', 0, 0, 100, 100)
					:set('fillColor', 1/2, 1/2, 1/2)
				:new('rectangle', ui:getRight '@previous' + 10, 0, 100, 100)
					:set('fillColor', 1/2, 1/2, 1/2)
			:endChildren()
			:wrap()
			:center(love.graphics.getWidth()/2)
			:middle(love.graphics.getHeight()/2)
		:draw()
end
```

### Mouse events
We can use mouse events to create basic mouse-driven GUi elements, like buttons and windows. The UI object provides some functions for getting the state of certain elements, like `isPressed` and `isDragged`. Note, however, that **the UI object will only track the state of elements that have a name**.

Here's an example of how to make a simple button:
```lua
local charm = require 'charm'

local ui = charm.new()

local buttonIdleColor = {1/4, 1/4, 1/4}
local buttonHoveredColor = {1/2, 1/2, 1/2}

local bigFont = love.graphics.newFont(32)

function love.draw()
	ui
		:name 'button'
		:beginChildren()
			:new('text', bigFont, 'click me!')
				:center(buttonX):middle(buttonY)
				:set('fillColor', 1, 0, 0)
		:endChildren()
		:wrap(32)
		:set('fillColor', ui:isHovered 'button' and buttonHoveredColor or buttonIdleColor)
	if ui:isPressed 'button' then print 'hi!' end
end
```

API
---
### charm

#### `charm.new()`
Creates a new UI object.

Returns:
- `ui` (`Ui`) - the new UI object

### Ui

#### `Ui:new(elementType, ...)`
Creates a new element to be drawn this frame.

Parameters:
- `elementType` (`string` or `table`) - the type of element to create. Can be the name of a built-in element type, or a table with functions for a custom element type.
- `...` - additional arguments to pass to the element type's constructor

Returns:
- `ui` (`Ui`) - itself

#### `Ui:getX(name, anchor)`
Gets the x position of a point along the x-axis of an element.

Parameters:
- `name` (`string`) - the name of the element to get, or an element selector
- `anchor` (`number`) (optional, defaults to `0`) - a number from 0-1 representing how far along the axis to travel to get the point. `0` gets the left edge, `.5` gets the horizontal center, and `1` gets the right edge

Returns:
- `x` (`number`) - the x position of the element

#### `Ui:getLeft(name)`
Gets the x position of the left edge of an element.

Parameters:
- `name` (`string`) - the name of the element to get, or an element selector

Returns:
- `left` (`number`) - the x position of the left edge of the element

#### `Ui:getCenter(name)`
Gets the x position of the horizontal center of an element.

Parameters:
- `name` (`string`) - the name of the element to get, or an element selector

Returns:
- `center` (`number`) - the x position of the horizontal center of the element


#### `Ui:getRight(name)`
Gets the x position of the right edge of an element.

Parameters:
- `name` (`string`) - the name of the element to get, or an element selector

Returns:
- `right` (`number`) - the x position of the right edge of the element

#### `Ui:getY(name, anchor)`
Gets the y position of a point along the y-axis of an element.

Parameters:
- `name` (`string`) - the name of the element to get, or an element selector
- `anchor` (`number`) (optional, defaults to `0`) - a number from 0-1 representing how far along the axis to travel to get the point. `0` gets the top edge, `.5` gets the vertical center, and `1` gets the bottom edge

Returns:
- `y` (`number`) - the y position of the element

#### `Ui:getTop(name)`
Gets the y position of the top edge of an element.

Parameters:
- `name` (`string`) - the name of the element to get, or an element selector

Returns:
- `top` (`number`) - the y position of the top edge of the element

#### `Ui:getMiddle(name)`
Gets the y position of the vertical center of an element.

Parameters:
- `name` (`string`) - the name of the element to get, or an element selector

Returns:
- `middle` (`number`) - the y position of the vertical center of the element


#### `Ui:getBottom(name)`
Gets the y position of the bottom edge of an element.

Parameters:
- `name` (`string`) - the name of the element to get, or an element selector

Returns:
- `bottom` (`number`) - the y position of the bottom edge of the element

#### `Ui:getZ(name)`
Gets the z position of an element. Elements have a z position of 0 by default.

Parameters:
- `name` (`string`) - the name of the element to get, or an element selector

Returns:
- `z` (`number`) - the z position of the element

#### `Ui:getWidth(name)`
Gets the width of an element.

Parameters:
- `name` (`string`) - the name of the element to get, or an element selector

Returns:
- `width` (`number`) - the width of the element

#### `Ui:getHeight(name)`
Gets the height of an element.

Parameters:
- `name` (`string`) - the name of the element to get, or an element selector

Returns:
- `height` (`number`) - the height of the element

#### `Ui:getSize(name)`
Gets the width and height of an element.

Parameters:
- `name` (`string`) - the name of the element to get, or an element selector

Returns:
- `width` (`number`) - the width of the element
- `height` (`number`) - the height of the element

#### `Ui:isHovered(name)`
Gets whether the mouse is hovering over an element.

Parameters:
- `name` (`string`) - the name of the element to get, or an element selector

Returns:
- `hovered` (`boolean`) - whether the element is hovered

#### `Ui:isEntered(name)`
Gets whether the mouse just moved over an element.

Parameters:
- `name` (`string`) - the name of the element to get, or an element selector

Returns:
- `entered` (`boolean`) - whether the element was just entered

#### `Ui:isExited(name)`
Gets whether the mouse just left an element.

Parameters:
- `name` (`string`) - the name of the element to get, or an element selector

Returns:
- `exited` (`boolean`) - whether the element was just exited

#### `Ui:isHeld(name, button)`
Gets whether an element is held down with a certain mouse button.

Parameters:
- `name` (`string`) - the name of the element to get, or an element selector
- `button` (`number`) (optional, defaults to `1`) - the mouse button to check for

Returns:
- `held` (`boolean`) - whether the element is currently held down

#### `Ui:isPressed(name, button)`
Gets whether an element was just clicked with a certain mouse button.

Parameters:
- `name` (`string`) - the name of the element to get, or an element selector
- `button` (`number`) (optional, defaults to `1`) - the mouse button to check for

Returns:
- `pressed` (`boolean`) - whether the element was just pressed

#### `Ui:isReleased(name, button)`
Gets whether an element was just released with a certain mouse button.

Parameters:
- `name` (`string`) - the name of the element to get, or an element selector
- `button` (`number`) (optional, defaults to `1`) - the mouse button to check for

Returns:
- `released` (`boolean`) - whether the element was just released

#### `Ui:isDragged(name, button)`
Gets whether an element was just dragged.

Parameters:
- `name` (`string`) - the name of the element to get, or an element selector
- `button` (`number`) (optional, defaults to `1`) - the mouse button to check for

Returns:
- `dragged` (`boolean`) - whether the element was just dragged
- `dx` (`number` or `nil`) - how far the element was dragged on the x-axis (if it was dragged)
- `dy` (`number` or `nil`) - how far the element was dragged on the y-axis (if it was dragged)

#### `Ui:x(x, anchor)`
Sets the x position of the currently selected element.

Parameters:
- `x` (`number`) - the new x position for the element
- `anchor` (`number`) (optional, defaults to `0`) - the point on the element to set to the destination x. `0` sets the left edge, `.5` sets the horizontal center, `1` sets the right edge

Returns:
- `ui` (`Ui`) - itself

#### `Ui:left(x)`
Sets the left edge of the currently selected element to the specified position.

Parameters:
- `x` (`number`) - the new x position for the left edge of the element

Returns:
- `ui` (`Ui`) - itself

#### `Ui:center(x)`
Sets the horizontal center of the currently selected element to the specified position.

Parameters:
- `x` (`number`) - the new x position for the horizontal center of the element

Returns:
- `ui` (`Ui`) - itself

#### `Ui:right(x)`
Sets the right edge of the currently selected element to the specified position.

Parameters:
- `x` (`number`) - the new x position for the right edge of the element

Returns:
- `ui` (`Ui`) - itself

#### `Ui:y(y, anchor)`
Sets the y position of the currently selected element.

Parameters:
- `y` (`number`) - the new y position for the element
- `anchor` (`number`) (optional, defaults to `0`) - the point on the element to set to the destination y. `0` sets the top edge, `.5` sets the vertical center, `1` sets the bottom edge

Returns:
- `ui` (`Ui`) - itself

#### `Ui:top(y)`
Sets the top edge of the currently selected element to the specified position.

Parameters:
- `y` (`number`) - the new y position for the top edge of the element

Returns:
- `ui` (`Ui`) - itself

#### `Ui:middle(y)`
Sets the vertical center of the currently selected element to the specified position.

Parameters:
- `y` (`number`) - the new y position for the vertical center of the element

Returns:
- `ui` (`Ui`) - itself

#### `Ui:bottom(y)`
Sets the bottom edge of the currently selected element to the specified position.

Parameters:
- `y` (`number`) - the new y position for the bottom edge of the element

Returns:
- `ui` (`Ui`) - itself

#### `Ui:z(z)`
Sets the z position of the currently selected element.

Parameters:
- `z` (`number`) - the new z position for the element

Returns:
- `ui` (`Ui`) - itself

#### `Ui:width(width)`
Sets the width of the currently selected element.

Parameters:
- `width` (`number`) - the new width for the element

Returns:
- `ui` (`Ui`) - itself

#### `Ui:height(height)`
Sets the height of the currently selected element.

Parameters:
- `height` (`number`) - the new height for the element

Returns:
- `ui` (`Ui`) - itself

#### `Ui:size(width, height)`
Sets the width and height of the currently selected element.

Parameters:
- `width` (`number`) - the new width for the element
- `height` (`number`) - the new height for the element

Returns:
- `ui` (`Ui`) - itself

#### `Ui:name(name)`
Sets the name of the currently selected element.

Parameters:
- `name` (`string`) - the new name for the element

Returns:
- `ui` (`Ui`) - itself

#### `Ui:set(property, ...)`
Sets a property on the currently selected element. What this does depends on the type of the element.

Parameters:
- `property` (`string`) - the name of the property to set
- `...` - additional arguments to pass to the property setter

Returns:
- `ui` (`Ui`) - itself

#### `Ui:clip()`
Enables clipping for the currently selected element, which causes portions of the element's children that are outside the element's bounds to be hidden.

Returns:
- `ui` (`Ui`) - itself

#### `Ui:transparent()`
Sets the currently selected element to be transparent, which means that the element will not block lower elements from receiving mouse events. Text and paragraph elements are transparent by default.

Returns:
- `ui` (`Ui`) - itself

#### `Ui:opaque()`
Sets the currently selected element to be opaque, which means that the element will block lower elements from receiving mouse events. Most elements are opaque by default.

Returns:
- `ui` (`Ui`) - itself

#### `Ui:beginChildren()`
After this function is called, newly created elements will be children of the element that was selected before the function was called.

Returns:
- `ui` (`Ui`) - itself

#### `Ui:endChildren()`
Stops assigning new elements to a previously designated parent element. The parent element will be re-selected as the currently modified element. `beginChildren`/`endChildren` pairs can be nested to create multi-layer hierarchies of elements.

Returns:
- `ui` (`Ui`) - itself

#### `Ui:wrap(padding)`
Adjusts the current element's position and size to perfectly surround its children. The children's positions will also be adjusted to have the same position on screen.

Parameters:
- `padding` (`number`) (optional, defaults to `0`) - the amount of extra space the parent element should have around its children (in pixels)

Returns:
- `ui` (`Ui`) - itself

#### `Ui:draw()`
Draws all of the previously created elements to the screen. Creating a new element after calling this function will reset the element list.

Returns:
- `ui` (`Ui`) - itself

### Element properties
This section lists the properties available for Charm's built-in element types. Note that these functions are not called directly; rather, you set an element's properties by using `Ui:set(property, ...)`.

#### Rectangle

##### `fillColor(r, g, b, a)`
Sets the fill color of the rectangle.

Parameters:
- `r` (`number`) - the red component of the color (from 0-1)
- `g` (`number`) - the green component of the color (from 0-1)
- `b` (`number`) - the component component of the color (from 0-1)
- `a` (`number`) (optional, defaults to `1`) - the alpha component of the color (from 0-1)

##### `fillColor(color)`
Sets the fill color of the rectangle.

Parameters:
- `color` (`table`) - the new fill color for the rectangle. Should contain three values corresponding to the red, green, and blue components of the color, and optionally a fourth alpha component.

##### `outlineColor(r, g, b, a)`
Sets the outline color of the rectangle.

Parameters:
- `r` (`number`) - the red component of the color (from 0-1)
- `g` (`number`) - the green component of the color (from 0-1)
- `b` (`number`) - the component component of the color (from 0-1)
- `a` (`number`) (optional, defaults to `1`) - the alpha component of the color (from 0-1)

##### `outlineColor(color)`
Sets the outline color of the rectangle.

Parameters:
- `color` (`table`) - the new outline color for the rectangle. Should contain three values corresponding to the red, green, and blue components of the color, and optionally a fourth alpha component.

##### `lineWidth(width)`
Sets the width of the rectangle's outline.

Parameters:
- `width` (`number`) - the width of the rectangle's outline

##### `radiusX(radiusX)`
Sets the horizontal radius of the rectangle's corners. The radius is 0 by default.

Parameters:
- `radiusX` (`number`) - the horizontal radius of the rectangle's corners

##### `radiusY(radiusY)`
Sets the vertical radius of the rectangle's corners. The radius is 0 by default.

Parameters:
- `radiusY` (`number`) - the vertical radius of the rectangle's corners

##### `radius(radiusX, radiusY)`
Sets the horizontal and vertical radii of the rectangle's corners.

Parameters:
- `radiusX` (`number`) - the horizontal radius of the rectangle's corners
- `radiusY` (`number`) - the vertical radius of the rectangle's corners

##### `segments(segments)`
Sets the number of segments used to draw the rectangle's corners. 64 by default.

Parameters:
- `segments` (`number`) - the number of segments used to draw the rectangle's corners

#### Ellipse

##### `fillColor(r, g, b, a)`
Sets the fill color of the ellipse.

Parameters:
- `r` (`number`) - the red component of the color (from 0-1)
- `g` (`number`) - the green component of the color (from 0-1)
- `b` (`number`) - the component component of the color (from 0-1)
- `a` (`number`) (optional, defaults to `1`) - the alpha component of the color (from 0-1)

##### `fillColor(color)`
Sets the fill color of the ellipse.

Parameters:
- `color` (`table`) - the new fill color for the ellipse. Should contain three values corresponding to the red, green, and blue components of the color, and optionally a fourth alpha component.

##### `outlineColor(r, g, b, a)`
Sets the outline color of the ellipse.

Parameters:
- `r` (`number`) - the red component of the color (from 0-1)
- `g` (`number`) - the green component of the color (from 0-1)
- `b` (`number`) - the component component of the color (from 0-1)
- `a` (`number`) (optional, defaults to `1`) - the alpha component of the color (from 0-1)

##### `outlineColor(color)`
Sets the outline color of the ellipse.

Parameters:
- `color` (`table`) - the new outline color for the ellipse. Should contain three values corresponding to the red, green, and blue components of the color, and optionally a fourth alpha component.

##### `lineWidth(width)`
Sets the width of the ellipse's outline.

Parameters:
- `width` (`number`) - the width of the ellipse's outline

##### `segments(segments)`
Sets the number of segments used to draw the ellipse. 64 by default.

Parameters:
- `segments` (`number`) - the number of segments used to draw the ellipse

#### Image

##### `image(image)`
Sets the image that the element should display.

Parameters:
- `image` (`Image`) - the new image for the element to display

##### `scaleX(scaleX)`
Sets the horizontal scale of the image, or in other words, sets the width of the element relative to the original width of the image.

Parameters:
- `scaleX` (`number`) - the new horizontal scale of the image

##### `scaleY(scaleY)`
Sets the vertical scale of the image, or in other words, sets the height of the element relative to the original height of the image.

Parameters:
- `scaleY` (`number`) - the new vertical scale of the image

##### `scale(scaleX, scaleY)`
Sets the horizontal and vertical scale of the image.

Parameters:
- `scaleX` (`number`) - the new horizontal scale of the image
- `scaleY` (`number`) - the new vertical scale of the image

##### `color(r, g, b, a)`
Sets the blend color of the image.

Parameters:
- `r` (`number`) - the red component of the color (from 0-1)
- `g` (`number`) - the green component of the color (from 0-1)
- `b` (`number`) - the component component of the color (from 0-1)
- `a` (`number`) (optional, defaults to `1`) - the alpha component of the color (from 0-1)

##### `color(color)`
Sets the blend color of the image.

Parameters:
- `color` (`table`) - the new blend color for the image. Should contain three values corresponding to the red, green, and blue components of the color, and optionally a fourth alpha component.

#### Text

##### `font(font)`
Sets the font that the text should use.

Parameters:
- `font` (`Font`) - the font that the text should use

##### `text(text)`
Sets the text that the element should display.

Parameters:
- `text` (`string`) - the text that the element should display

##### `limit(limit)`
Sets the maximum width (in pixels) that the text can span before a line break occurs.

Parameters:
- `limit` (`number`) - the maximum width of a line of text

##### `align(align)`
Sets the alignment of the text.

Parameters:
- `align` (`alignMode`) - how text should be aligned within the paragraph

##### `scaleX(scaleX)`
Sets the horizontal scale of the text, or in other words, sets the width of the element relative to the natural width of the text.

Parameters:
- `scaleX` (`number`) - the new horizontal scale of the text

##### `scaleY(scaleY)`
Sets the vertical scale of the text, or in other words, sets the height of the element relative to the natural height of the text.

Parameters:
- `scaleY` (`number`) - the new vertical scale of the text

##### `scale(scaleX, scaleY)`
Sets the horizontal and vertical scale of the text.

Parameters:
- `scaleX` (`number`) - the new horizontal scale of the text
- `scaleY` (`number`) - the new vertical scale of the text

##### `color(r, g, b, a)`
Sets the color of the text. Text is white by default.

Parameters:
- `r` (`number`) - the red component of the color (from 0-1)
- `g` (`number`) - the green component of the color (from 0-1)
- `b` (`number`) - the component component of the color (from 0-1)
- `a` (`number`) (optional, defaults to `1`) - the alpha component of the color (from 0-1)

##### `color(color)`
Sets the color of the text.

Parameters:
- `color` (`table`) - the new color for the text. Should contain three values corresponding to the red, green, and blue components of the color, and optionally a fourth alpha component.

##### `shadowColor(r, g, b, a)`
Sets the color of the text's shadow.

Parameters:
- `r` (`number`) - the red component of the color (from 0-1)
- `g` (`number`) - the green component of the color (from 0-1)
- `b` (`number`) - the component component of the color (from 0-1)
- `a` (`number`) (optional, defaults to `1`) - the alpha component of the color (from 0-1)

##### `shadowColor(shadowColor)`
Sets the color of the text's shadow.

Parameters:
- `shadowColor` (`table`) - the new shadow color for the text. Should contain three values corresponding to the red, green, and blue components of the color, and optionally a fourth alpha component.

##### `shadowOffsetX(shadowOffsetX)`
Sets the horizontal offset of the text's shadow. Defaults to 1 pixel.

Parameters:
- `shadowOffsetX` (`number`) - the horizontal offset of the text's shadow (in pixels)

##### `shadowOffsetY(shadowOffsetY)`
Sets the vertical offset of the text's shadow. Defaults to 1 pixel.

Parameters:
- `shadowOffsetY` (`number`) - the vertical offset of the text's shadow (in pixels)

##### `shadowOffset(shadowOffsetX, shadowOffsetY)`
Sets the horizontal and vertical offset of the text's shadow.

Parameters:
- `shadowOffsetX` (`number`) - the horizontal offset of the text's shadow (in pixels)
- `shadowOffsetY` (`number`) - the vertical offset of the text's shadow (in pixels)

#### Paragraph

##### `font(font)`
Sets the font that the paragraph should use.

Parameters:
- `font` (`Font`) - the font that the paragraph should use

##### `text(text)`
Sets the text that the element should display.

Parameters:
- `text` (`string`) - the text that the element should display

##### `scaleX(scaleX)`
Sets the horizontal scale of the paragraph, or in other words, sets the width of the element relative to the natural width of the paragraph.

Parameters:
- `scaleX` (`number`) - the new horizontal scale of the paragraph

##### `scaleY(scaleY)`
Sets the vertical scale of the paragraph, or in other words, sets the height of the element relative to the natural height of the paragraph.

Parameters:
- `scaleY` (`number`) - the new vertical scale of the paragraph

##### `scale(scaleX, scaleY)`
Sets the horizontal and vertical scale of the paragraph.

Parameters:
- `scaleX` (`number`) - the new horizontal scale of the paragraph
- `scaleY` (`number`) - the new vertical scale of the paragraph

##### `color(r, g, b, a)`
Sets the color of the paragraph. Paragraphs are white by default.

Parameters:
- `r` (`number`) - the red component of the color (from 0-1)
- `g` (`number`) - the green component of the color (from 0-1)
- `b` (`number`) - the component component of the color (from 0-1)
- `a` (`number`) (optional, defaults to `1`) - the alpha component of the color (from 0-1)

##### `color(color)`
Sets the color of the paragraph.

Parameters:
- `color` (`table`) - the new color for the paragraph. Should contain three values corresponding to the red, green, and blue components of the color, and optionally a fourth alpha component.

##### `shadowColor(r, g, b, a)`
Sets the color of the paragraph's shadow.

Parameters:
- `r` (`number`) - the red component of the color (from 0-1)
- `g` (`number`) - the green component of the color (from 0-1)
- `b` (`number`) - the component component of the color (from 0-1)
- `a` (`number`) (optional, defaults to `1`) - the alpha component of the color (from 0-1)

##### `shadowColor(shadowColor)`
Sets the color of the paragraph's shadow.

Parameters:
- `shadowColor` (`table`) - the new shadow color for the paragraph. Should contain three values corresponding to the red, green, and blue components of the color, and optionally a fourth alpha component.

##### `shadowOffsetX(shadowOffsetX)`
Sets the horizontal offset of the paragraph's shadow. Defaults to 1 pixel.

Parameters:
- `shadowOffsetX` (`number`) - the horizontal offset of the paragraph's shadow (in pixels)

##### `shadowOffsetY(shadowOffsetY)`
Sets the vertical offset of the paragraph's shadow. Defaults to 1 pixel.

Parameters:
- `shadowOffsetY` (`number`) - the vertical offset of the paragraph's shadow (in pixels)

##### `shadowOffset(shadowOffsetX, shadowOffsetY)`
Sets the horizontal and vertical offset of the paragraph's shadow.

Parameters:
- `shadowOffsetX` (`number`) - the horizontal offset of the paragraph's shadow (in pixels)
- `shadowOffsetY` (`number`) - the vertical offset of the paragraph's shadow (in pixels)
