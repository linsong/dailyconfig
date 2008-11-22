/**
 * ==VimperatorPlugin==
 * @name			webdev.js
 * @description		Controlling WebDeveloper from Vimperator's CLI
 * @description-ru	Управление WebDeveloper-ом из командной строки Vimperator-а
 * @author			Artem S. <spriritedflow@gmail.com>
 * @link			http://github.com/spiritedflow/vimperator-webdev/wikis
 * @version			0.1
 * ==/VimperatorPlugin==
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * Usage:
 *  :webdev <command path>
 *
 * Use 'Tab' for autocompletition and '?' to discover subcommands
 *
 * There is hidden subtree ":webdev .debug" with commands which
 * may be helpful to you if you want to add some new commands or
 * debug the plugin.
 *
 * Tested on:
 *	WebDeveloper version: 1.1.5
 *		url: https://addons.mozilla.org/en-US/firefox/addon/60
 *	Vimperator version: 1.2
 *		url: https://addons.mozilla.org/en-US/firefox/addon/4891
 */


(function() {

/* ********************
 *   COMMAND   TREE
 * ********************/
var commandTree = {

	// Base commands
	'toolbar': [webdeveloper_toggleToolbar, 'Toggle toolbar'],
	'preferences': [webdeveloper_options, 'Web Developer\'s Options'],

	// Clearing cache, cookies and so on
	'clear': {
		'_descr_': 'Clear data ...',
		'auth':	[webdeveloper_clearHTTPAuthentication, "Clear HTTP authentication"],
		'cache':   [webdeveloper_clearCache, "Clear cache"],
		'history': [webdeveloper_clearHistory, "Clear history"],
		'cookies': [webdeveloper_clearSessionCookies, "Clear session cookies"],
	},

	// Outlining frames, tables ... everything
	'outline': {
		'_descr_': 'Outline objects ...',
		'frames': [getMenuClicker("outline-frames"), "Outline frames"],
		'headings': [getMenuClicker("outline-headings"), "Outline headings"],


		'blocklevel':[getMenuClicker("outline-block-level-elements"),
			"Outline block level elements"],
		'depricated':[getMenuClicker("outline-depricated-elements"),
			"Outline depricated elements"],

		'current':[getMenuClicker("outline-current-element"),
			"Outline current element"],
		'custom':[getMenuClicker("outline-custom-elements"),
			"Outline custom element"],

		'tables': {
			'_descr_': "Outline tables ...",
			'_default_': [getMenuClicker("outline-all-tables"),
				"Outline tables"],
			'cells':[getMenuClicker("outline-table-cells"),
				"Outline table cells"],
			'captions':[getMenuClicker("outline-table-captions"),
				"Outline table captions"],
		},

		// Outline links
		'links': {
			'_descr_': 'Outline links ...',
			'external': [getMenuClicker("outline-external-links"),
			"Outline external links"],
			'ping': [getMenuClicker("outline-links-with-ping-attributes"),
			"Outline links with ping attribute"],
			'notitle': [getMenuClicker("outline-links-without-title-attributes"),
			"Outline links without title attribute"],
		},

		// Outline positioned elements
		'positioned': {
			'_descr_': 'Outline positioned elements ...',
			'absolute':[getMenuClicker("outline-absolute-positioned-elements"),
				"Outline absolute positioned elements"],
			'fixed':[getMenuClicker("outline-fixed-positioned-elements"),
				"Outline fixed elements"],
			'relative':[getMenuClicker("outline-relative-positioned-elements"),
				"Outline relative positioned elements"],
			'float':[getMenuClicker("outline-floated-elements"),
				"Outline floated elements"],
		},
	},

	// All about forms
	'form': {
		'_descr_': 'Do something with forms ...',
		'convert': {
			'_descr_': 'Convert forms method ...',
			'post2get': [getMenuClicker("convert-form-methods-posts-gets"),
				'Convert forms from POST to GET'],
			'get2post': [getMenuClicker("convert-form-methods-gets-posts"),
				'Convert forms from GET to POST'],
		},
		'details': [getMenuClicker("display-form-details"),
			"Show details for all forms"],
		'info': [getMenuClicker("view-form-information"),
			"Show information for all forms"],
	},

/*
	// Show source, css and so on
	'show': {
		'_descr_': 'Show info or display tools ...',
		'source':   [null, "Show source code"],
		'css':	  [null, "Show CSS"],
		'forms':	[null, "Show forms information"],
		'size': 	[null, "Show window size"],
	},
*/

	// cmd 'toggle' is more suitable for disable/enable commands,
	// but it begins with 't' as 'toolbar' does and it makes
	// autocompletition a bit more difficult :)
	// So disable -- toggle various things
	'disable': {
		'_descr_': 'Toggle various things ...',
		'cache': [getMenuClicker("disable-cache"), "Disable caching"],
		'java' : [getMenuClicker("disable-java"), "Disable Java"],
		'javascript' : [getMenuClicker("disable-all-javascript"),
			"Disable JavaScript"],
	},

	'resize': {
		'_descr_': 'Resize main window ...',
		'_expand_': expandResizeSubmenu,
		'custom': [webdeveloper_customResizeWindow, "Custom resize window"],
		'preferences': [function() {webdeveloper_options("resize");},
				"Edit resize preferences"]
	},

	// Hidden menu .debug
	'.debug': {
		'loaded_styles': [displayLoadedStyles, "Display loaded styles"],
		'cmd_tree': [displayCommandTree, "Display command tree"],
	},

};

/* ********************
 *     VARIABLES
 * ********************/
var show_hidden = false;
var quick_complete = false;


/* *******************
 *  Helpful functions
 * *******************/

// Main wrapper for WebDeveloper's menuitems.
// Pass it's id in the webdeveloper.xul (smth like
// webdeveloper-*-menu) or it's shorter variant
// (what was replaced with * in the example)
function getMenuClicker (menuId) {
	return function() {
		elem = document.getElementById(menuId)
			|| document.getElementById("webdeveloper-" + menuId + "-menu");

		if (!elem) {
			liberator.echoerr ("can not find menu item with id" + menuId);
			return null;
		}

		// Change status of checkboxes
		if (elem.getAttribute("type") == "checkbox")
			elem.setAttribute("checked",
				! webdeveloper_convertToBoolean(elem.getAttribute("checked")));

		 elem.doCommand();
	}
}

// wrapper to webdeveloper_resizeWindow
function getResizeWindowFunction (width, height, viewport) {
	return function () {
			webdeveloper_resizeWindow(width, height, viewport);
		}
}


// gets all settings about resizing windows and
// returns subtree whith them.
// see webdeveloper_updateResizeMenu for details
function expandResizeSubmenu () {

	// loads resize item from preferences
	function getResizeItem (index) {
		return {
			descr: webdeveloper_getStringPreference(
				"webdeveloper.resize." + index + ".description", true),
			height: webdeveloper_getIntegerPreference(
				"webdeveloper.resize." + index + ".height", true),
			width: webdeveloper_getIntegerPreference(
				"webdeveloper.resize." + index + ".width", true),
			viewport: webdeveloper_getBooleanPreference(
				"webdeveloper.resize." + index + ".viewport", true)
		};
	};

	var submenu = {};

	var count = webdeveloper_getIntegerPreference("webdeveloper.resize.count", true);
	for(var i = 1; i <= count; i++) {
		var item = getResizeItem(i);
		if (item.descr == '')
			continue;
		submenu[item.descr] = [
			getResizeWindowFunction(item.width, item.height, item.viewport),
			"Resize window to " + item.width + "x" + item.height];
	}

	return submenu;
}

// displayLoadedStyles: helpful function for searching styleIds
function displayLoadedStyles () {
	liberator.echo(webdeveloper_appliedStyles.toString() || "none");
	liberator.log(webdeveloper_appliedStyles);
}

// displayCommandTree: shows all command list
// as tabbed tree. This is quick way to get
// all commands at once
function displayCommandTree () {

	//buildTree:
	// recursive walk through expanded command tree
	// see 'expandCommandTree' for details
	// returns formated list of strings to output.
	function formatTree (list, prefix) {
		var res=[];

		for each(var node in list) {
			res.push (prefix + node[0]);
			if (node[1])
				res = res.concat(formatTree (node[1], prefix + "\t"));
		}

		return res;
	}

	var list = formatTree (expandCommandTree (), "\t");
	var result = "webdev\n" + list.join("\n");

	liberator.echo (result);
	//liberator.log ("Command tree:\n" + result);
}




/* ********************
 *   PLUGIN  ENGINE
 * ********************/

// keys:
// like keys for hashes/dictonaries in
// other languages, but with one difference:
// If there is a key '_expand_' then result
// hash will be autoexpanded with results of
// the function the key points to.
function getKeys(obj) {
	var res = [];
	for (var key in obj) {

		if (key == '_expand_') {
			expanded = getKeys(obj['_expand_']());
			res = res.concat(expanded); //TODO: may be we should remove doubles
			continue;
		}
		res.push(key);
	}
	return res;
}

// getValue:
// works as obj[key] but with respect to
// key '_expand_' as it does func "getKeys(obj)"
function getValue(obj, key) {
	if (key in obj)
		return obj[key];

	if (obj['_expand_'])
		return getValue(obj['_expand_'](), key);

	return null;
}

// isIn:
// works as 'key on obj' but with respect to
// key '_expand_'.
function isIn(obj, key) {
	if (key in obj)
		return true;

	if (obj['_expand_'])
		return isIn(obj['_expand_'](), key);

	return false;
}

// expandCommandTree:
// converts command tree into smth like:
//   TREE ::= ["node_name", [SUBTREE]]
//   SUBTREE ::= TREE
// Only node names will be in result tree
function expandCommandTree () {

	//spider: simple depth-first search.
	//with omiting hidden elements.
	function spider (node) {

		// Skip not leafes
		if (node instanceof Array)
			return [];

		// Construct array for this node
		var res = [];
		for each(var k in getKeys(node).sort()) {

			if (k == '_descr_')
				continue;

			if (k[0] == '.' && !show_hidden)
				continue;

			res.push ([k, spider(getValue(node,k))]);
		}
		return res;
	}

	return spider(commandTree);
}

// getSubTree:
// walks in the command tree along a path
// and returns sanitized path and the node at the end
function getSubTree (args) {

	// findLike: finds similar items
	//  Ex:
	//   in:  ('cle', ['clear', 'clearall', 'bear'])
	//	 out: ['clear', 'clearall']
	function findLike (item, array) {
		var res = [];
		for each(var c in array) {
			if (c.substring(0, item.length) == item)
				res.push(c);
		}
		return res;
	}

	// matchCommand:
	// try to find item or similar items
	// in the keys of the node
	function matchCommand(node, item) {
		// If match exactly -> return it
		if (isIn(node,item))
			return [item];

		var like = findLike (item, getKeys(node));
		return (like.length == 0)? [null]:like;
	}

	// walkTree:
	// Recursive tree walking along the path
	// Returns pair: [path, node] where
	//   path = sanitized path or null if there was errors
	//   nore = node where the wolking was stopped
	function walkTree (node, path) {
		//liberator.log ("recursive tree walk: node = " + node + " path = " + path);

		if (path.length == 0)
		return ['', node];

		var head = path.shift();
		if (head == '?')
			return ['', node];

		var like = matchCommand(node, head);

		if (!like) {
			//Nothing found :(

			//liberator.log("for \"" + head + "\" cmd not found");
			return [null, null];
		}
		else  if (like.length == 1) {
			// Direct hit!

			var cmd = like[0];
			//liberator.log("cmd found for \"" + head + "\" : " + cmd);

			var [rpath, rnode] = walkTree (getValue(node,cmd), path);
			if (rpath == null)
				return [rpath, rnode];

			return [cmd + " " + rpath, rnode];
		}
		else {
			// We have variants ...

			//liberator.log("for \"" + head + "\" cmd not found,"
			//	+ "but there are similar commands: "
			//	+ like.toString());

			//Make new node with only subnodes similar to cmd
			var new_node = {}
			for each(var k in like)
				new_node[k] = node[k];

			return ["", new_node];
		}
	}

	var path = args.split(/\s+/);
	return walkTree (commandTree, path);
}

// completeCommand:
// find variants for autocompletition
function completeCommand (args) {

	// getDescr:
	// try to get description from the object
	// or return empty string.
	function getDescr(node) {

		if (node instanceof Array)
			return node[1];
		else if ( isIn(node,"_descr_"))
			return node._descr_;
		else
			return "";
	}

	// If was an error, return no condidates
	var [prefix, obj] = getSubTree (args);
	if (!obj)
		return [0,[]];

	// If there was direct hit, return one candidate
	if (obj instanceof Array)
		return [0, [[prefix, getDescr(obj)]]];

	// Otherwise, format candidates list
	var candidates = [];
	var insert_parent = true;

	for each(var k in getKeys(obj).sort()) {
		if (k == '_default_') {
			candidates.push ([prefix, getDescr(getValue(obj,k))]);
			insert_parent = false;
		}
		else if (k == '_descr_')
			continue;
		else if (k[0] == '.' && !show_hidden)
			continue;
		else
			candidates.push ([prefix + k, getDescr(getValue(obj,k))]);
	}

	// Insert parent "..." if needed
	if (!quick_complete && insert_parent && candidates.length > 1)
		candidates.unshift ([prefix, '...']);

	return [0,candidates];
}

// processCommand:
// finds command in the tree and runs it's function
function processCommand (args) {

	var [prefix, obj] = getSubTree (args);

	if (!obj) {
		liberator.echo ("unknown command");
		return
	}

	if ( !(obj instanceof Array) ) {
		if (isIn(obj,"_default_"))
		obj = obj._default_
		else {
			liberator.echo ("incomplete command, use <Tab> for variants");
			return
		}
	}

	try {
		obj[0]();
	} catch (e) {
		liberator.echo ("error: " + e);
	}
}

// Add user command
liberator.commands.addUserCommand(['webdev'], 'webdeveloper',
	processCommand,
	{
		completer: completeCommand,
	}, true);


})();

// vim: set fdm=marker sw=4 ts=4 et:
