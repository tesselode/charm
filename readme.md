Charm <!-- omit in toc -->
=====
Charm is a library for LÖVE that makes it easier to arrange and draw graphics, such as shapes, images, and text. It excels at relative positioning, which can become cumbersome as a layout gets more complex. It also handles mouse events, so it can be used for basic UI tasks, like creating buttons.

This library is similar to [Boxer](https://github.com/tesselode/boxer), but it's **immediate mode**, which means that instead of creating objects that represent each graphic you want to draw, you simply tell Charm what you want to draw on each frame.

Table of contents <!-- omit in toc -->
-----------------
- [Installation](#installation)
- [Usage](#usage)
  - [Drawing elements](#drawing-elements)
  - [Positioning elements relative to each other](#positioning-elements-relative-to-each-other)
  - [Grouping elements together](#grouping-elements-together)
  - [Element selectors](#element-selectors)
  - [Mouse events](#mouse-events)
- [API](#api)
  - [charm](#charm)
    - [Functions](#functions)
      - [`local ElementClass = charm.extend(parent)`](#local-elementclass--charmextendparent)
      - [`local ui = charm.new()`](#local-ui--charmnew)
  - [Base](#base)
    - [Fields](#fields)
      - [`Base.get` (table)](#baseget-table)
      - [`Base.preserve` (table)](#basepreserve-table)
    - [Callbacks](#callbacks)
      - [`Base:new(...)`](#basenew)
      - [`local containsPoint = Base:containsPoint(x, y)`](#local-containspoint--basecontainspointx-y)
      - [`Base:onAddChild(element)`](#baseonaddchildelement)
      - [`Base:drawSelf()`](#basedrawself)
      - [`Base:stencil()`](#basestencil)
      - [`Base:beforeDraw()`](#basebeforedraw)
      - [`Base:afterDraw()`](#baseafterdraw)
    - [Property getters](#property-getters)
      - [`local x = Base.get:x(anchor)`](#local-x--basegetxanchor)
      - [`local left = Base.get:left()`](#local-left--basegetleft)
      - [`local center = Base.get:center()`](#local-center--basegetcenter)
      - [`local right = Base.get:right()`](#local-right--basegetright)
      - [`local y = Base.get:y(anchor)`](#local-y--basegetyanchor)
      - [`local top = Base.get:top()`](#local-top--basegettop)
      - [`local middle = Base.get:middle()`](#local-middle--basegetmiddle)
      - [`local bottom = Base.get:bottom()`](#local-bottom--basegetbottom)
      - [`local z = Base.get:z()`](#local-z--basegetz)
      - [`local width = Base.get:width()`](#local-width--basegetwidth)
      - [`local height = Base.get:height()`](#local-height--basegetheight)
      - [`local width, height = Base.get:size()`](#local-width-height--basegetsize)
      - [`local hovered = Base.get:hovered()`](#local-hovered--basegethovered)
      - [`local entered = Base.get:entered()`](#local-entered--basegetentered)
      - [`local exited = Base.get:exited()`](#local-exited--basegetexited)
      - [`local pressed = Base.get:pressed(button)`](#local-pressed--basegetpressedbutton)
      - [`local released = Base.get:released(button)`](#local-released--basegetreleasedbutton)
      - [`local held = Base.get:held(button)`](#local-held--basegetheldbutton)
      - [`local dragged = Base.get:dragged(button)`](#local-dragged--basegetdraggedbutton)
    - [Property setters](#property-setters)
      - [`Base:x(x, anchor)`](#basexx-anchor)
      - [`Base:left(x)`](#baseleftx)
      - [`Base:center(x)`](#basecenterx)
      - [`Base:right(x)`](#baserightx)
      - [`Base:y(y, anchor)`](#baseyy-anchor)
      - [`Base:top(y)`](#basetopy)
      - [`Base:middle(y)`](#basemiddley)
      - [`Base:bottom(y)`](#basebottomy)
      - [`Base:z(z)`](#basezz)
      - [`Base:width(width)`](#basewidthwidth)
      - [`Base:height(height)`](#baseheightheight)
      - [`Base:size(width)`](#basesizewidth)
      - [`Base:name(name)`](#basenamename)
      - [`Base:clip()`](#baseclip)
      - [`Base:opaque()`](#baseopaque)
      - [`Base:transparent()`](#basetransparent)
    - [Other functions](#other-functions)
      - [`local state = Base:getState()`](#local-state--basegetstate)
      - [`Base:shift(dx, dy)`](#baseshiftdx-dy)
      - [`Base:wrap(padding)`](#basewrappadding)
  - [Rectangle](#rectangle)
    - [Constructors](#constructors)
      - [`Rectangle:new(x, y, width, height)`](#rectanglenewx-y-width-height)
    - [Property setters](#property-setters-1)
      - [`Rectangle:fillColor(r, g, b, a)`](#rectanglefillcolorr-g-b-a)
      - [`Rectangle:outlineColor(r, g, b, a)`](#rectangleoutlinecolorr-g-b-a)
      - [`Rectangle:outlineWidth(width)`](#rectangleoutlinewidthwidth)
      - [`Rectangle:cornerRadiusX(radius)`](#rectanglecornerradiusxradius)
      - [`Rectangle:cornerRadiusY(radius)`](#rectanglecornerradiusyradius)
      - [`Rectangle:cornerRadius(radiusX, radiusY)`](#rectanglecornerradiusradiusx-radiusy)
      - [`Rectangle:cornerSegments(segments)`](#rectanglecornersegmentssegments)
  - [Ellipse](#ellipse)
    - [Constructors](#constructors-1)
      - [`Ellipse:new(x, y, width, height)`](#ellipsenewx-y-width-height)
    - [Property setters](#property-setters-2)
      - [`Ellipse:fillColor(r, g, b, a)`](#ellipsefillcolorr-g-b-a)
      - [`Ellipse:outlineColor(r, g, b, a)`](#ellipseoutlinecolorr-g-b-a)
      - [`Ellipse:outlineWidth(width)`](#ellipseoutlinewidthwidth)
      - [`Ellipse:segments(segments)`](#ellipsesegmentssegments)
  - [Image](#image)
    - [Constructors](#constructors-2)
      - [`Image:new(image, x, y)`](#imagenewimage-x-y)
    - [Property setters](#property-setters-3)
      - [`Image:scaleX(scaleX)`](#imagescalexscalex)
      - [`Image:scaleY(scaleY)`](#imagescaleyscaley)
      - [`Image:scale(scaleX, scaleY)`](#imagescalescalex-scaley)
      - [`Image:color(r, g, b, a)`](#imagecolorr-g-b-a)
  - [Paragraph](#paragraph)
    - [Constructors](#constructors-3)
      - [`Paragraph:new(font, text, limit, align, x, y)`](#paragraphnewfont-text-limit-align-x-y)
    - [Property setters](#property-setters-4)
      - [`Paragraph:scaleX(scaleX)`](#paragraphscalexscalex)
      - [`Paragraph:scaleY(scaleY)`](#paragraphscaleyscaley)
      - [`Paragraph:scale(scaleX, scaleY)`](#paragraphscalescalex-scaley)
      - [`Paragraph:color(r, g, b, a)`](#paragraphcolorr-g-b-a)
      - [`Paragraph:shadowColor(r, g, b, a)`](#paragraphshadowcolorr-g-b-a)
      - [`Paragraph:shadowOffsetX(offsetX)`](#paragraphshadowoffsetxoffsetx)
      - [`Paragraph:shadowOffsetY(offsetY)`](#paragraphshadowoffsetyoffsety)
      - [`Paragraph:shadowOffset(offsetX, offsetY)`](#paragraphshadowoffsetoffsetx-offsety)
  - [Text](#text)
    - [Constructors](#constructors-4)
      - [`Text:new(font, text, x, y)`](#textnewfont-text-x-y)
    - [Property setters](#property-setters-5)
      - [`Text:scaleX(scaleX)`](#textscalexscalex)
      - [`Text:scaleY(scaleY)`](#textscaleyscaley)
      - [`Text:scale(scaleX, scaleY)`](#textscalescalex-scaley)
      - [`Text:color(r, g, b, a)`](#textcolorr-g-b-a)
      - [`Text:shadowColor(r, g, b, a)`](#textshadowcolorr-g-b-a)
      - [`Text:shadowOffsetX(offsetX)`](#textshadowoffsetxoffsetx)
      - [`Text:shadowOffsetY(offsetY)`](#textshadowoffsetyoffsety)
      - [`Text:shadowOffset(offsetX, offsetY)`](#textshadowoffsetoffsetx-offsety)
  - [Ui](#ui)
    - [Functions](#functions-1)
      - [`Ui:new(elementClass, ...)`](#uinewelementclass)
      - [`local element = Ui:getElement(name)`](#local-element--uigetelementname)
      - [`local value = Ui:get(element, propertyName, ...)`](#local-value--uigetelement-propertyname)
      - [`local elementState = Ui:getState(element)`](#local-elementstate--uigetstateelement)
      - [`Ui:select(element)`](#uiselectelement)
      - [`Ui:beginChildren()`](#uibeginchildren)
      - [`Ui:endChildren()`](#uiendchildren)
      - [`Ui:draw()`](#uidraw)
      - [`Ui:start()`](#uistart)
- [Contributing](#contributing)

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
	ui:fillColor(.5, .5, .5)
	ui:draw()
end
```
- The `new` function defines a new **element**. The first argument is always the type of the element. The arguments after that depend on what type of element we created. For rectangles, we can specify an x position, y position, width and height.
- Functions like `fillColor` set a property on the most recently created element. Which properties are available depends on what element we're modifying. In this case we're specifying a fill color for the rectangle (otherwise it would be invisible).
- The `draw` function tells the UI object that we're done specifying our elements and we can actually display them now.

Most of the UI object's functions return the UI object itself, so we can chain the methods together and write the same code like this:
```lua
function love.draw()
	ui
		:new('rectangle', 50, 50, 100, 150)
			:fillColor(.5, .5, .5)
		:draw()
end
```
You don't have to use method chaining, I just think it looks nice.

### Positioning elements relative to each other
Once we define an element, we can get any point along the x or y axis using `ui.get`:
```lua
function love.draw()
	ui
		:new('rectangle', 50, 50, 100, 150)
			:name 'eleanor'
			:fillColor(.5, .5, .5)
		:draw()
	print(ui:get('eleanor', 'x', .5), ui:get('eleanor', 'y', 1))
end
```
`get` takes at least two arguments:
- The first is the **name** of the element to get a point on. Elements don't have names by default, so in this example, I named the rectangle Eleanor, because sometimes abstract concepts should have human names.
- The second is the name of the **property** we want to get. In this case, we're getting "x" and "y".

The next arguments depend on the property we're getting. In this case, the third argument is the **anchor**, which is a number from 0-1 that represents how far along the axis we should travel to find the point. So `get(name, 'x', 0)` would get the x position of the left edge of the box, `get(name, 'x', 0.5)` would get the x position of the horizontal center of the box, and `get(name, 'x', 1)` would get the x position of the right edge of the box. We can also use any anchor in between.

There's also some shortcut properties for getting x and y positions: `left`, `center`, and `right` return the left edge, horizontal center, and right edge of a box respectively, and `top`, `middle`, and `bottom` return the top edge, vertical center, and bottom edge of a box respectively. So we could write the above code like this:
```lua
function love.draw()
	ui
		:new('rectangle', 50, 50, 100, 150)
			:name 'eleanor'
			:fillColor(.5, .5, .5)
		:draw()
	print(ui:get('eleanor', 'left'), ui:get('eleanor', 'bottom'))
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
			:fillColor(.5, .5, .5)
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
			:fillColor(.5, .5, .5)
		:draw()
end
```
We can use the getters and setters to easily position graphics relative to each other without having to do a lot of math. The following code will display a white rectangle and a red rectangle that's 50 pixels to the right and vertically aligned:
```lua
function love.draw()
	ui
		:new('rectangle', 50, 50, 100, 150)
			:name 'eleanor'
			:fillColor(1, 1, 1)
		:new 'rectangle'
			:width(50):height(50)
			:left(ui:get('eleanor', 'right'))
			:middle(ui:get('eleanor', 'middle'))
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
	ui
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

### Element selectors
Rather than using the names of an element to get information about it, we can use special keywords to select an element without having to give it a name first. Charm provides three keywords:
- `@current` - the element currently being modified
- `@previous` - the previously selected element
- `@parent` - the parent of the currently modified element

Here's a modified version of the above example that uses `@previous`, the most commonly useful keyword:
```lua
function love.draw()
	ui
		:new 'rectangle'
			:width(100)
			:beginChildren()
				:new('rectangle', 0, 0, 100, 100)
					:fillColor(1/2, 1/2, 1/2)
				:new 'rectangle'
					:left(ui:get('@previous', 'right') + 10)
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

### Mouse events
We can use mouse events to create basic mouse-driven GUI elements, like buttons and windows. Elements have properties for getting the state of certain elements, like `pressed` and `dragged`. Note, however, that **the UI object will only track the state of elements that have a name**.

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
				:fillColor(1, 0, 0)
		:endChildren()
		:wrap(32)
		:fillColor(ui:get('button', 'hovered') and buttonHoveredColor or buttonIdleColor)
	if ui:get('button', 'pressed') then print 'hi!' end
end
```

API
---

### charm
The main module that lets you create new `Ui` objects and element classes.

#### Functions

##### `local ElementClass = charm.extend(parent)`
Creates a new element class.

Parameters:
- `parent` (`ElementClass` or `string`) (optional, defaults to `'base'`) - the element class the new class should inherit from

Returns:
- `elementClass` (`ElementClass`) - the new element class

##### `local ui = charm.new()`
Creates a new `Ui` object.

### Base
The base element class that all other element classes inherit from.

#### Fields

##### `Base.get` (table)
A table of functions that can be accessed via `Ui.get`. Additional arguments to `Ui.get` will be passed to these functions, and `Ui.get` will return whatever these functions return.

##### `Base.preserve` (table)
A list of all of the keys of an element instance that should not be cleared out when a new draw frame is started.

#### Callbacks
These are functions that can be overridden to change the behavior of custom element classes.

##### `Base:new(...)`
Called when the element is initialized. Additional arguments from `Ui.new` will be passed to this function.

##### `local containsPoint = Base:containsPoint(x, y)`
Gets whether a point is within the element's bounds.

Returns:
- `containsPoint` (`boolean`)

##### `Base:onAddChild(element)`
Called when an element is added as this element's child.

Parameters:
- `element` (`Element`) - the child element

##### `Base:drawSelf()`
Defines the drawing operations used to display the element on screen.

##### `Base:stencil()`
Defines the drawing operations used to crop child elements if clipping is enabled.

##### `Base:beforeDraw()`
Called before the element is drawn.

##### `Base:afterDraw()`
Called after the element is drawn.

#### Property getters

##### `local x = Base.get:x(anchor)`
Returns the x position of a certain point along the element's x-axis.

Parameters:
- `anchor` (`number`) (defaults to `0`) - the point along the x-axis to get (`0` is left, `.5` is center, `1` is right)

Returns:
- `x` (`number`)

##### `local left = Base.get:left()`
Returns the x position of the left edge of the element.

Returns:
- `left` (`number`)

##### `local center = Base.get:center()`
Returns the x position of the horizontal center of the element.

Returns:
- `center` (`number`)

##### `local right = Base.get:right()`
Returns the x position of the right edge of the element.

Returns:
- `right` (`number`)

##### `local y = Base.get:y(anchor)`
Returns the y position of a certain point along the element's y-axis.

Parameters:
- `anchor` (`number`) (defaults to `0`) - the point along the y-axis to get (`0` is top, `.5` is middle, `1` is bottom)

Returns:
- `y` (`number`)

##### `local top = Base.get:top()`
Returns the y position of the top edge of the element.

Returns:
- `top` (`number`)

##### `local middle = Base.get:middle()`
Returns the y position of the vertical center of the element.

Returns:
- `middle` (`number`)

##### `local bottom = Base.get:bottom()`
Returns the y position of the bottom edge of the element.

Returns:
- `bottom` (`number`)

##### `local z = Base.get:z()`
Returns the z position of the element.

Returns:
- `z` (`number`)

##### `local width = Base.get:width()`
Returns the width of the element.

Returns:
- `width` (`number`)

##### `local height = Base.get:height()`
Returns the height of the element.

Returns:
- `height` (`number`)

##### `local width, height = Base.get:size()`
Returns the width and height of the element.

Returns:
- `width` (`number`)
- `height` (`number`)

##### `local hovered = Base.get:hovered()`
Returns whether the element was hovered by the mouse this frame.

Returns:
- `hovered` (`boolean`)

##### `local entered = Base.get:entered()`
Returns whether the element was entered by the mouse this frame.

Returns:
- `entered` (`boolean`)

##### `local exited = Base.get:exited()`
Returns whether the element was exited by the mouse this frame.

Returns:
- `exited` (`boolean`)

##### `local pressed = Base.get:pressed(button)`
Returns whether the element was pressed by a certain mouse button this frame.

Parameters:
- `button` (`number`) - the mouse button to check

Returns:
- `pressed` (`boolean`)

##### `local released = Base.get:released(button)`
Returns whether the element was released by a certain mouse button this frame.

Parameters:
- `button` (`number`) - the mouse button to check

Returns:
- `released` (`boolean`)

##### `local held = Base.get:held(button)`
Returns whether the element was held by a certain mouse button this frame.

Parameters:
- `button` (`number`) - the mouse button to check

Returns:
- `held` (`boolean`)

##### `local dragged = Base.get:dragged(button)`
Returns whether the element was dragged by a certain mouse button this frame, and if so, how far it was dragged.

Parameters:
- `button` (`number`) - the mouse button to check

Returns:
- `dragged` (`boolean`)
- `dx` (`number` or `nil`) - the number of pixels the element was dragged horizontally, or `nil` if it wasn't dragged
- `dy` (`number` or `nil`) - the number of pixels the element was dragged vertically, or `nil` if it wasn't dragged

#### Property setters

##### `Base:x(x, anchor)`
Sets the x position of a point along the element's x-axis.

Parameters:
- `x` (`number`) - the desired x position
- `anchor` (`number`) (defaults to `0`) - the position along the x-axis to set (`0` is left, `.5` is center, `1` is right)

##### `Base:left(x)`
Sets the x position of the left edge of the element.

Parameters:
- `x` (`number`) - the desired x position

##### `Base:center(x)`
Sets the x position of the horizontal center of the element.

Parameters:
- `x` (`number`) - the desired x position

##### `Base:right(x)`
Sets the x position of the right edge of the element.

Parameters:
- `x` (`number`) - the desired x position

##### `Base:y(y, anchor)`
Sets the y position of a point along the element's y-axis.

Parameters:
- `y` (`number`) - the desired y position
- `anchor` (`number`) (defaults to `0`) - the position along the y-axis to set (`0` is left, `.5` is center, `1` is right)

##### `Base:top(y)`
Sets the y position of the top edge of the element.

Parameters:
- `y` (`number`) - the desired y position

##### `Base:middle(y)`
Sets the y position of the vertical center of the element.

Parameters:
- `y` (`number`) - the desired y position

##### `Base:bottom(y)`
Sets the y position of the bottom edge of the element.

Parameters:
- `y` (`number`) - the desired y position

Returns:
- `state` (`table`)

##### `Base:z(z)`
Sets the z position of the element.

Parameters:
- `z` (`number`)

##### `Base:width(width)`
Sets the width of the element.

Parameters:
- `width` (`number`)

##### `Base:height(height)`
Sets the height of the element.

Parameters:
- `height` (`number`)

##### `Base:size(width)`
Sets the width and height of the element.

Parameters:
- `width` (`number`)
- `height` (`number`)

##### `Base:name(name)`
Gives the element a name. This is required to use persistent state.

Parameters:
- `name` (`string`)

##### `Base:clip()`
Enables clipping for this element, causing child elements to be drawn cropped to this element's visible area.

##### `Base:opaque()`
Sets the element to be opaque, meaning that this element will block mouse events from elements behind it.

##### `Base:transparent()`
Sets the element to be transparent, meaning that mouse events can pass through this element to elements behind it.

#### Other functions

##### `local state = Base:getState()`
Gets the persistent state of the element.

##### `Base:shift(dx, dy)`
Shifts the element by a certain number of pixels horizontally and vertically.

Parameters:
- `dx` (`number`) (defaults to `0`) - the amount of the shift the element horizontally
- `dy` (`number`) (defaults to `0`) - the amount of the shift the element vertically

##### `Base:wrap(padding)`
Adjusts the element to perfectly surround all of its children. The children's positions will be adjusted so they maintain the same position on screen.

Parameters:
- `padding` (`number`, defaults to `0`) - the amount of extra space to surround the children with

### Rectangle

#### Constructors

##### `Rectangle:new(x, y, width, height)`
Initializes the rectangle.

Parameters:
- `x` (`number`, defaults to `0`) - the x position of the rectangle
- `y` (`number`, defaults to `0`) - the y position of the rectangle
- `width` (`number`, defaults to `0`) - the width of the rectangle
- `height` (`number`, defaults to `0`) - the height of the rectangle

#### Property setters

##### `Rectangle:fillColor(r, g, b, a)`
Sets the color to draw the inside of the rectangle with.

Parameters:
- `r` (`number` or `table`) - the red component of the color, or a table in the form `{r, g, b, a}`
- `g` (`number`) (optional) - the green component of the color
- `b` (`number`) (optional) - the blue component of the color
- `a` (`number`) (optional) - the alpha component of the color

##### `Rectangle:outlineColor(r, g, b, a)`
Sets the color to draw the outline of the rectangle with.

Parameters:
- `r` (`number` or `table`) - the red component of the color, or a table in the form `{r, g, b, a}`
- `g` (`number`) (optional) - the green component of the color
- `b` (`number`) (optional) - the blue component of the color
- `a` (`number`) (optional) - the alpha component of the color

##### `Rectangle:outlineWidth(width)`
Sets the line width of the rectangle's outline.

Parameters:
- `width` (`number`)

##### `Rectangle:cornerRadiusX(radius)`
Sets the horizontal radius of the rectangle's corners.

Parameters:
- `radiusX` (`number`)

##### `Rectangle:cornerRadiusY(radius)`
Sets the vertical radius of the rectangle's corners.

Parameters:
- `radiusY` (`number`)

##### `Rectangle:cornerRadius(radiusX, radiusY)`
Sets the horizontal and vertical radius of the rectangle's corners.

Parameters:
- `radiusX` (`number`)
- `radiusY` (`number`)

##### `Rectangle:cornerSegments(segments)`
Sets the number of segments used to draw the rectangle's corners.

Parameters:
- `segments` (`number`)

### Ellipse

#### Constructors

##### `Ellipse:new(x, y, width, height)`
Initializes the ellipse.

Parameters:
- `x` (`number`, defaults to `0`) - the x position of the ellipse
- `y` (`number`, defaults to `0`) - the y position of the ellipse
- `width` (`number`, defaults to `0`) - the width of the ellipse
- `height` (`number`, defaults to `0`) - the height of the ellipse

#### Property setters

##### `Ellipse:fillColor(r, g, b, a)`
Sets the color to draw the inside of the ellipse with.

Parameters:
- `r` (`number` or `table`) - the red component of the color, or a table in the form `{r, g, b, a}`
- `g` (`number`) (optional) - the green component of the color
- `b` (`number`) (optional) - the blue component of the color
- `a` (`number`) (optional) - the alpha component of the color

##### `Ellipse:outlineColor(r, g, b, a)`
Sets the color to draw the outline of the ellipse with.

Parameters:
- `r` (`number` or `table`) - the red component of the color, or a table in the form `{r, g, b, a}`
- `g` (`number`) (optional) - the green component of the color
- `b` (`number`) (optional) - the blue component of the color
- `a` (`number`) (optional) - the alpha component of the color

##### `Ellipse:outlineWidth(width)`
Sets the line width of the ellipse's outline.

Parameters:
- `width` (`number`)

##### `Ellipse:segments(segments)`
Sets the number of segments to draw the ellipse with.

Parameters:
- `segments` (`number`)

### Image

#### Constructors

##### `Image:new(image, x, y)`
Initializes the image.

Parameters:
- `image` (`Image`) - the image to use
- `x` (`number`, default to `0`) - the x position of the image
- `y` (`number`, default to `0`) - the y position of the image

#### Property setters

##### `Image:scaleX(scaleX)`
Sets the horizontal scale of the image (as a multiplier of its original size).

Parameters:
- `scaleX` (`number`)

##### `Image:scaleY(scaleY)`
Sets the vertical scale of the image (as a multiplier of its original size).

Parameters:
- `scaleY` (`number`)

##### `Image:scale(scaleX, scaleY)`
Sets the scale of the image (as a multiplier of its original size).

Parameters:
- `scaleX` (`number`, defaults to `1`)
- `scaleY` (`number`, defaults to `scaleX`)

##### `Image:color(r, g, b, a)`
Sets the blend color of the image.

Parameters:
- `r` (`number` or `table`) - the red component of the color, or a table in the form `{r, g, b, a}`
- `g` (`number`) (optional) - the green component of the color
- `b` (`number`) (optional) - the blue component of the color
- `a` (`number`) (optional) - the alpha component of the color

### Paragraph

#### Constructors

##### `Paragraph:new(font, text, limit, align, x, y)`
Initializes the paragraph.

Parameters:
- `font` (`Font`) - the font to use
- `text` (`string`) - the text to display
- `limit` (`number`) - the maximum horizontal width in pixels the text is allowed to span
- `align` (`AlignMode`) - the alignment of the text
- `x` (`number`, defaults to `0`) - the x position of the paragraph
- `y` (`number`, defaults to `0`) - the y position of the paragraph

#### Property setters

##### `Paragraph:scaleX(scaleX)`
Sets the horizontal scale of the paragraph (as a multiplier of its original size).

Parameters:
- `scaleX` (`number`)

##### `Paragraph:scaleY(scaleY)`
Sets the vertical scale of the paragraph (as a multiplier of its original size).

Parameters:
- `scaleY` (`number`)

##### `Paragraph:scale(scaleX, scaleY)`
Sets the scale of the paragraph (as a multiplier of its original size).

Parameters:
- `scaleX` (`number`, defaults to `1`)
- `scaleY` (`number`, defaults to `scaleX`)

##### `Paragraph:color(r, g, b, a)`
Sets the color of the paragraph.

Parameters:
- `r` (`number` or `table`) - the red component of the color, or a table in the form `{r, g, b, a}`
- `g` (`number`) (optional) - the green component of the color
- `b` (`number`) (optional) - the blue component of the color
- `a` (`number`) (optional) - the alpha component of the color

##### `Paragraph:shadowColor(r, g, b, a)`
Sets the color of the paragraph's shadow.

Parameters:
- `r` (`number` or `table`) - the red component of the color, or a table in the form `{r, g, b, a}`
- `g` (`number`) (optional) - the green component of the color
- `b` (`number`) (optional) - the blue component of the color
- `a` (`number`) (optional) - the alpha component of the color

##### `Paragraph:shadowOffsetX(offsetX)`
Sets the horizontal offset of the paragraph's shadow.

Parameters:
- `offsetX` (`number`)

##### `Paragraph:shadowOffsetY(offsetY)`
Sets the vertical offset of the paragraph's shadow.

Parameters:
- `offsetY` (`number`)

##### `Paragraph:shadowOffset(offsetX, offsetY)`
Sets the horizontal and vertical offset of the paragraph's shadow.

Parameters:
- `offsetX` (`number`)
- `offsetY` (`number`)

### Text

#### Constructors

##### `Text:new(font, text, x, y)`
Initializes the text.

Parameters:
- `font` (`Font`) - the font to use
- `text` (`string`) - the text to display
- `x` (`number`, defaults to `0`) - the x position of the text
- `y` (`number`, defaults to `0`) - the y position of the text

#### Property setters

##### `Text:scaleX(scaleX)`
Sets the horizontal scale of the text (as a multiplier of its original size).

Parameters:
- `scaleX` (`number`)

##### `Text:scaleY(scaleY)`
Sets the vertical scale of the text (as a multiplier of its original size).

Parameters:
- `scaleY` (`number`)

##### `Text:scale(scaleX, scaleY)`
Sets the scale of the text (as a multiplier of its original size).

Parameters:
- `scaleX` (`number`, defaults to `1`)
- `scaleY` (`number`, defaults to `scaleX`)

##### `Text:color(r, g, b, a)`
Sets the color of the text.

Parameters:
- `r` (`number` or `table`) - the red component of the color, or a table in the form `{r, g, b, a}`
- `g` (`number`) (optional) - the green component of the color
- `b` (`number`) (optional) - the blue component of the color
- `a` (`number`) (optional) - the alpha component of the color

##### `Text:shadowColor(r, g, b, a)`
Sets the color of the text's shadow.

Parameters:
- `r` (`number` or `table`) - the red component of the color, or a table in the form `{r, g, b, a}`
- `g` (`number`) (optional) - the green component of the color
- `b` (`number`) (optional) - the blue component of the color
- `a` (`number`) (optional) - the alpha component of the color

##### `Text:shadowOffsetX(offsetX)`
Sets the horizontal offset of the text's shadow.

Parameters:
- `offsetX` (`number`)

##### `Text:shadowOffsetY(offsetY)`
Sets the vertical offset of the text's shadow.

Parameters:
- `offsetY` (`number`)

##### `Text:shadowOffset(offsetX, offsetY)`
Sets the horizontal and vertical offset of the text's shadow.

Parameters:
- `offsetX` (`number`)
- `offsetY` (`number`)

### Ui
Manages and draws graphical elements.

#### Functions

##### `Ui:new(elementClass, ...)`
Adds a new element to be drawn this frame.

Parameters:
- `elementClass` (`ElementClass` or `string`) - the type of element to add
- `...` - additional arguments to pass to the element class' constructor

Returns:
- `self` (`Ui`) - itself

##### `local element = Ui:getElement(name)`
Gets the table representing an element.

Parameters:
- `name` (`string`) - the name of the element, or one of the following keywords:
  - `'@current'` - the currently selected element
  - `'@previous'` - the previously selected element
  - `'@parent'` - the parent of the currently selected element (if there is one)

Returns:
- `element` (`Element` or `nil`) - the element table, or `nil` if there's no element with the given name or no element that matches the given keyword

##### `local value = Ui:get(element, propertyName, ...)`
Gets the value of an element property.

Parameters:
- `element` (`Element` or `string`) - the element or name of the element to get the property from
- `propertyName` (`string`) - the name of the property to get the value of
- `...` - additional arguments to pass to the property getter function

Returns:
- `value` - the value of the property

##### `local elementState = Ui:getState(element)`
Gets the persistent state table for an element.

Parameters:
- `element` (`Element` or `string`) - the element or name of the element to get the state of

Returns:
- `elementState` (`table` or `nil`) - the persistent state of the element, or `nil` if the element doesn't have a persistent state

##### `Ui:select(element)`
Sets the element that subsequent function calls should modify.

Parameters:
- `element` (`Element`) - the element to select

##### `Ui:beginChildren()`
Starts adding children to the currently selected element.

##### `Ui:endChildren()`
Stops adding children to the current parent element and re-selects the parent element.

##### `Ui:draw()`
Draws the previously added elements and updates their state. After `draw` is called, the next `new` call will clear out the existing elements.

##### `Ui:start()`
Manually starts a new draw frame. Normally this is called automatically the first time you call `Ui:new()` after calling `Ui:draw()`.

Returns:
- `self` (`Ui`) - itself

Contributing
------------
Charm is in very early development. Feel free to ask questions, point out bugs, and even make some pull requests! If you use this library in a game, let me know how it goes.
