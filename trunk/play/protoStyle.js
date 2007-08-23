/* protoStyle object
PURPOSE: To make it easy to change styles for class of elements dynamically without javascript having to iterate over the elements. 
This is done by modifying one or more style tags in the head of the page. 

Example: 
var hiddenThings = protoStyle("hiddenThings").css(".ding .dong {display: none;}")
hiddenThings.selector

*/		
var protoStyle = (function () {
	// proto() is an exact copy of Douglas Crockford's object() operator
	function proto(o) {
		var F = function F() {};
		F.prototype = o;
		return new F();
	}
	var protoObj = {
		_elem: "",
		//** Not sure we need _id...
		_id: "",
		_style: {},
		//** Selector should be an object too (or an array)
		_selector: "",
		// Overwrites the style content (the selector is left untouched)
		// **think about changing name to properties
		style: function (style) {
			this._style = this.styleAsObj(style);
			return this.update();	
		},
		// Overwrites the selector only (the stuff in the curly brackets is left untouched)
		// **Think about changing name to selectors... or have one function that smartly does both... 
		// **update() to update selectors and properties
		// **replace() to replace selectors and properties. Expamples: replace(".even", ".odd"); replace(".ding"); replace("{color: red;}"); **Shouldn't need curly braces... could be a problem telling psudo-selectors from properties without curly braces.
		//**remove() to remove selectors and properties. Example: remove(".even");
		selector: function (selector) {
			this._selector = selector;
			return this.update();
		},		
		// Overwrites everything in the style tag
		css: function (css) {	
			firebug.log(this);
			if (css) {					
				var arr = css.replace(/\{/, "~~{").split('~~');
				this._selector = arr[0];
				this._style = this.styleAsObj(arr[1]);
			} else {
				this._selector = "";
				this._style = this.styleAsObj("");
			}
			return this.update();
		},
		// Updates the style. Does not delete any properties--only overwrites ones included in styleString. If selector is included, selector is overwritten (**should thing about changing this).
		update: function (styleString) {
			if (styleString) {
				var obj = this.styleAsObj(styleString);
				for (var i in obj) {
					this._style[i] = obj[i];
				}
			}
			var hasStyle = !!this._style;
			var hasSelector = !!this._selector;
			// Make sure either both or neither style and selector are defined (if niether, clear the style tag out)	
			if (hasStyle && hasSelector) {
				this._elem.empty().append(this._selector + this.styleAsString());
			} else if (!hasSelector) {
				this._elem.empty();
			}
			return this;
		},
		styleAsObj: function (styleString) {
			firebug.log(styleString);
			var obj = styleString
			.replace(/\s*;*\s*}\s*/g,";}")
			.replace(/\s*{\s*/g, "{'")
			.replace(/\s*:\s*/g,"':'")
			.replace(/\s*;\s*/g,"';'")
			.replace(/;'}/g,"}")
			.replace(/;/g,",");
			firebug.log(obj);
			return eval('(' + obj + ')');
		},
		styleAsString: function () {
			var obj = this._style;
			var style = "{";
			for (i in obj) {
				style += i + ":" + obj[i] + ";";
			}
			return style += "}";
		},
		make: function (id) {			
			//  If no id, create a new style element with no id
			if (!id) {
				this._elem = $("<style></style>").appendTo('head').eq(0);
			// If an id is passed, create a style element with that id
			} else if (id && $("#"+id).length < 1) {
				this._id = "#"+id;
				this._elem = $("<style id='"+id+"'></style>").appendTo('head').eq(0);
			// Else error... 
			} else {
				//**error. Or should we go ahead and create a protoStyle object?
				//this._elem = $("#"+id);
				return false;
			}
			return this;
		}
	}
	return function (id) {				
		return proto(protoObj).make(id);		
	}
})();
// Wrap firebug's firebug object so it doesn't break things when firebug is disabled
var firebug = function (i) {
	try {
		return console[i];
	} catch (err) {	
		return function () {}; //do nothing
	}
};
for (var i in console) {
	firebug[i] = firebug(i);
}
var f = firebug;