var GLOBAL = this;
(function () {
	var DIM = {
		L:"meter",
		T:"second",
		M:"kilogram"
	};
	var UNIT = {
		"meter":{dim:{L:1}, factor:1, alias:["meter", "meters", "metre", "metres", "m"]},
		"centimeter":{dim:{L:1}, factor:0.01, alias:["centimeter", "centimeters", "centimetre", "centimetres", "cm"]},
		"milimeter":{dim:{L:1}, factor:0.001, alias:["milimeter", "milimeters", "milimetre", "milimetres", "mm"]},
		"kilometer":{dim:{L:1}, factor:1000, alias:["kilometer", "kilometers", "kilometre", "kilometres", "km"]},
		"inch":{dim:{L:1}, factor:0.0254, alias:["inch", "inches", "in", '"', "''"]},
		"foot":{dim:{L:1}, factor:0.3048, alias:["foot", "feet", "ft", "'"]},
		"yard":{dim:{L:1}, factor:0.9144, alias:["yard", "yards", "yd", "yds"]},
		"mile":{dim:{L:1}, factor:1609.344, alias:["mile", "miles", "mi"]},

		"second":{dim:{L:1}, factor:1, alias:["second", "seconds", "sec", "secs", "s"]},
		"minute":{dim:{L:1}, factor:60, alias:["minute", "minutes", "min", "mins"]},
		"hour":{dim:{L:1}, factor:3600, alias:["hour", "hours", "hr", "hrs"]},
		"day":{dim:{L:1}, factor:3600*24, alias:["day", "days"]},
		"year":{dim:{L:1}, factor:3600*24*365.242199, alias:["year", "years", "yr"]},
	};

	// expamd UNIT object to include all alias units
	(function () {
		for (var key in UNIT) {
			var alias = UNIT[key].alias, i = alias.length;
			while (i--) {
				UNIT[alias[i]] = UNIT[key];
			}
		}
	}());
	
	var ONE = {dim:{}, factor:1}, NEGATIVE_ONE = {dim:{}, factor:-1}, ZERO = {dim:{}, factor:0};
	
	function toUnitObj(x) {
		var resultUnit, xNum = +x;
		if (x.factor != null) {
			resultUnit = x;
		} else if (isNaN(xNum)) {
			resultUnit = UNIT[x];
		} else {
			resultUnit = {dim:{}, factor:xNum};
		}
		return resultUnit;
	}
	
	function unitPlus(u1, u2) {
		var resultUnit = {dim:{}}, dimAreCompatible = true;
		if (u1 == null) {
			resultUnit = toUnitObj(0);
		} else if (u2 == null) {
			resultUnit = toUnitObj(u1);
		} else {
			u1 = toUnitObj(u1);
			u2 = toUnitObj(u2);
			// check if units have compatiple dimensions
			for (var key in DIM) {
				dimAreCompatible = dimAreCompatible && u1.dim[key] == u2.dim[key];
			}

			if (dimAreCompatible) {
				// copy dim to resultUnit
				for (var key in u1.dim) {
					resultUnit.dim[key] = u1.dim[key];
				}
				// add factors
				resultUnit.factor = u1.factor + u2.factor;
			} else {
				resultUnit.incompatibleDim = true;
			}
		}
		//console.debug("resultUnit", resultUnit);
		return resultUnit;
	}
	
	function unitMinus(u1, u2) { 
		var resultUnit;
		if (u1 == null) {
			resultUnit = toUnitObj(0);
		} else if (u2 == null) {
			resultUnit = toUnitObj(u1);
		} else {
			resultUnit = unitPlus(u1, unitTimes(u2, -1));
		}
		return resultUnit;
	}
	
	function unitTimes(u1, u2) {
		//console.debug("unitTImes u1, u2", u1, u2);
		var resultUnit = {dim:{}};
		if (u1 == null) {
			resultUnit = toUnitObj(1);
		} else if (u2 == null) {
			resultUnit = toUnitObj(u1);
		} else {
			u1 = toUnitObj(u1);
			u2 = toUnitObj(u2);
			for (var key in DIM) {
				// add matching dimension powers
				//console.debug("dfs", u1, u2);
				resultUnit.dim[key] = (u1.dim[key] || 0) + (u2.dim[key] || 0);
				//console.debug("resultUnit.dim[key]", resultUnit.dim[key]);

				// remove any 0 dimension
				if (!resultUnit.dim[key]) {
					delete resultUnit.dim[key];
				}

				// multiply matching dimension factors
				resultUnit.factor = u1.factor*u2.factor;
			}
		}
		//console.debug("resultUnit", resultUnit);
		return resultUnit;
	}
	
	function unitDiv(u1, u2) {
		//console.debug("u1, u2", u1, u2);
		var resultUnit;
		if (u1 == null) {
			resultUnit = toUnitObj(1);
		} else if (u2 == null) {
			resultUnit = toUnitObj(u1);			
		} else {
			resultUnit = unitTimes(u1, unitPow(u2, -1));
		}
		return resultUnit;
	}
	
	function unitPow(u, p) {
		var resultUnit;		
		
		if (u == null) {
			resultUnit = toUnitObj(1);
		} else if (p == null) {
			resultUnit = toUnitObj(u);
		} else {				
			// p should be dimensionless	
			p = toNum(p);
			if (p != null) {
				resultUnit = {dim:{}};
				u = toUnitObj(u);			
				for (var key in u.dim) {
					resultUnit.dim[key] = u.dim[key]*p
				}
				resultUnit.factor = Math.pow(u.factor, p);
			}
		}
		//console.debug("resultUnit unitDiv ", u, p, resultUnit);
		return resultUnit;
	}
	
	function toNum(x) {
		// x can't be converted to number unless it's dimensionless
		var resultNum, xNum = +x; 
		if (!isNaN(xNum)) {
			resultNum = xNum;
		} else if (x.dim != null) {
			for (var key in x.dim) {				
				break;
			}
			if (!key) {
				resultNum = x.factor;
			}
		}
		return resultNum;
	}	

	function applyOpToArr(op, arr) {
		if (op.inReverse) {
			arr.reverse();
		}
		var resultUnit, dimAreCompatible = true;
		resultUnit = unitTimes(1, arr[0]);
		for (var i = 1, len = arr.length; i < len && !resultUnit.incompatibleDim; i++) {
			resultUnit = op(resultUnit, arr[i]);
		}
		//console.debug("resultUnit", resultUnit);
		return resultUnit;
	}

	function groupString(str) {
		str = str.replace(/[(]/g, "group('");
		str = str.replace(/[)]/g, "')");
		return str;
	}
	function parseString(str) {
		//console.debug("// str\n", str);
		// normalize space
		str = str.replace(/\s+/g, " ").replace(/^\s+|\s+$/g, "");
		//console.debug("// normalize space\n", str);
		// put a "|" betweeen numbers and units so we can make things like this work as expected: 10 ft / 5 ft = 2;
		str = str.replace(/([0-9])([a-zA-Z'"])/g, "$1|$2");
		str = str.replace(/([0-9a-zA-Z])\s+([a-zA-Z'"])/g, "$1|$2");
		//console.debug("// put a | betweeen numbers and units so we can make things like this work as expected: 10 ft / 5 ft = 2\n", str);
		// replace / before units with "`" so we can make things like this work as expected: 5 ft/sec / 5 in/sec = 12;
		str = str.replace(/([0-9a-zA-Z])\s*\/\s*([a-zA-Z])/g, "$1`$2");
		//console.debug("replace / before units with ` so we can make things like this work as expected: 5 ft/sec / 5 in/sec = 12\n", str);
		// replace spaces with * unless adjacent to and operator or followed by a letter
		str = str.replace(/([^\+\-\*\/\^\'\"])\s([^\+\-\*\/\^])/g, "$1*$2");		
		//console.debug("// replace spaces with * unless adjacent to and operator\n", str);
		// handle "e" notation
		str = str.replace(/([0-9])[eE]([-]*[0-9])/g, "$110^$2");
		//console.debug('// handle "e" notation\n', str);
		// remove all spaces around operators
		str = str.replace(/\s*([^\+\-\*\/\^])\s*/g, "$1");
		//console.debug("// remove all spaces around operators\n", str);
		// add plus sign ' or " and numbers		
		str = str.replace(/(["'])([0-9])/g, "$1+$2");
		// add times sign between letters an anything not a letter or operator
		str = str.replace(/([^a-zA-Z\+\-\*\/\^\|\`])([a-zA-Z])/g, "$1*$2");
		//console.debug("// add times sign between letters an anything not a letter or operator\n", str);
		str = str.replace(/([a-zA-Z])([^a-zA-Z\+\-\*\/\^\|\`])/g, "$1*$2");
		//console.debug("// add times sign between letters an anything not a letter or operator\n", str);				
		// replace minus operator with ~, but leave negative signs alone
		str = str.replace(/([^+\-\*\/\^\|\`])-/g, "$1~");
		//console.debug("// replace minus operator with ~, but leave negative signs alone\n", str);
		// surround operators with space
		//str = str.replace(/([\+\-\*\/\^\|\`])/g, " $1 ");
		////console.debug("// surround operators with space\n", str);
		// trim
		str = str.replace(/^\s+|\s+$/g, "");
		console.debug("// trim\n", str);
		// create an array from the string
		var arrPlus = str.split("+"), arrMinus, arrTimes, arrDiv, arrUnitTimes, arrUnitDiv, arrPow;
		var iPlus = arrPlus.length, iMinus, iTimes, iDiv, iUnitTimes, iUnitDiv, iPow;
		while (iPlus--) {
			arrPlus[iPlus] = arrMinus = arrPlus[iPlus].split(/~/);
			iMinus = arrMinus.length;
			while (iMinus--) {
				arrMinus[iMinus] = arrTimes = arrMinus[iMinus].split("*");
				iTimes = arrTimes.length;
				while (iTimes--) {
					arrTimes[iTimes] = arrDiv = arrTimes[iTimes].split("/");
					iDiv = arrDiv.length;
					while (iDiv--) {
						arrDiv[iDiv] = arrUnitTimes = arrDiv[iDiv].split("|");
						iUnitTimes = arrUnitTimes.length;
						while (iUnitTimes--) {
							arrUnitTimes[iUnitTimes] = arrUnitDiv = arrUnitTimes[iUnitTimes].split("`");
							iUnitDiv = arrUnitDiv.length;
							while (iUnitDiv--) {
								arrUnitDiv[iUnitDiv] = arrPow = arrUnitDiv[iUnitDiv].split("^");
							}
						}
					}
				}
			}
		}		
		//console.debug(arrPlus);
		return arrPlus;
	}
	
	unitPow.inReverse = true;
	function generateOrderedOpArray() {
		return [unitPlus, unitMinus, unitTimes, unitDiv, unitTimes, unitDiv, unitPow];
	}
	
	function copyArr(arr) {
		var i = arr.length, copy = [];
		while (i--) {
			copy[i] = arr[i];
		}
		return copy;
	}
	
	function calcUnitResult(str) {		
		return calcOpsFromFullArr(parseString(str), generateOrderedOpArray());	
	}	
	
	function calcOpsFromFullArr(arr, orderedOpArray) {		
		var nextFunc = orderedOpArray.length > 1 ? calcOpsFromFullArr : toUnitObj,
			op = orderedOpArray.shift();		
		
		for (var i = 0, len = arr.length; i < len; i++) {
			arr[i] = nextFunc(arr[i], copyArr(orderedOpArray));
		}
		
		return applyOpToArr(op , arr);		
	}	
	
	// export to GLOBAL	
	GLOBAL["unitPlus"] = unitPlus;
	GLOBAL["unitMinus"] = unitMinus;
	GLOBAL["unitTimes"] = unitTimes;
	GLOBAL["unitDiv"] = unitDiv;
	GLOBAL["unitPow"] = unitPow;	
	GLOBAL["groupString"] = groupString;
	GLOBAL["parseString"] = parseString;
	GLOBAL["calcUnitResult"] = calcUnitResult;
	GLOBAL["toNum"] = toNum;
	GLOBAL["toUnitObj"] = toUnitObj;
	
	
}());
//unitTimes({dim:{L:1, T:-3}, factor:3}, {dim:{L:2, T:3}, factor:5});
//unitPlus({dim:{L:1, T:-3}, factor:13}, {dim:{L:1, T:-3}, factor:5});
//unitPlus({dim:{}, factor:13}, {dim:{}, factor:5});
//unitPow({dim:{L:1, T:2, M:3}, factor:5}, 3);
//unitPlusArr([{dim:{L:1}, factor:5}, {dim:{L:1}, factor:5}, {dim:{L:1}, factor:5}, {dim:{L:1}, factor:5}, {dim:{L:1}, factor:5}]);
parseString

/*
	5*(10 m + 50 feet^2 / (4 in))^10 + 3

	["5", "*", ["10", "m", "+", "50", "feet", "^", "2", "/", "4", "in"], "^", "10", "+", "3"]
	group("5", "*", group("10", "m", "+", "feet", "^", "2", "/", group("4", "in")), "^", "10", "+", "3")
	group(["10", "m"],["50", "feet", "^", "2", group("4", "in"), "^", "-1"])
	group(["10", "m"],["50", ["feet","2"], [group(["4", "in"]), "-1"]]])

*/