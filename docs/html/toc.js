var work = 1;
var name_c = window.location.hostname + '-publican';
var num_days = 7;

function setCookie(name, value, expires, path, domain, secure) { 
	var curCookie = name + "=" + value + 
		((expires) ? ";expires=" + expires.toGMTString() : "") + 
		((path) ? ";path=" + path : "");
// + 
//		((domain) ? ";domain=" + domain : "") + 
//		((secure) ? ";secure" : ""); 

	document.cookie = curCookie; 
}

function addID(id) {
	var current_val = "";

	if(document.cookie) {
		var cookies = document.cookie.split(/ *; */);
		for(var i=0; i < cookies.length; i++) {
			var current_c = cookies[i].split("=");
			if(current_c[0] == name_c) {
				current_val = current_c[1];
				break;
			}
		}
	}

	if(current_val) {
		current_val += "," + id;
	} else {
		current_val = id;
	}

	var expDate = new Date();
	expDate.setDate(expDate.getDate() + num_days);
	setCookie(name_c, current_val, expDate, '/', false, false);
}

function removeID(id) {
	var current_val = "";

	if(document.cookie) {
		var cookies = document.cookie.split(/ *; */);
		for(var i=0; i < cookies.length; i++) {
			var current_c = cookies[i].split("=");
			if(current_c[0] == name_c) {
				current_val = current_c[1];
				break;
			}
		}
	}


	if(current_val == id) {
		current_val = "";
	}

	if(current_val.match("," + id + ",") != -1) {
		current_val = current_val.replace("," + id + ",", ",");
	}

	var rg = new RegExp("^" + id + ",");
	if(current_val.match(rg) != -1) {
		current_val = current_val.replace(rg, "");
	}

	rg = new RegExp("," + id + "\$");
	if(current_val.match(rg) != -1) {
		current_val = current_val.replace(rg, "");
	}

	var expDate = new Date();
	expDate.setDate(expDate.getDate() + num_days);
	setCookie(name_c, current_val, expDate, '/', false, false);
}

// TODO: Should really removeID all ID
function clearCookie(id) {
	// TODO: split and toggle
	var current_val = "";

	if(document.cookie) {
		var cookies = document.cookie.split(/ *; */);
		for(var i=0; i < cookies.length; i++) {
			var current_c = cookies[i].split("=");
			if(current_c[0] == name_c) {
				current_val = current_c[1];
				break;
			}
		}
	}

	var ids = current_val.split(',');
	for(var j = 0; j < ids.length; j++) {
		work = 1;
		toggle("", ids[j]);
	}
	
	work = 1;
	current_val = "";

	var expDate = new Date();
	expDate.setDate(expDate.getDate() + num_days);
	setCookie(name_c, current_val, expDate, '/', false, false);
}

function getCookie() {
	var current_val = "";

	if(document.cookie.length <= 0) { return;}

	var cookies = document.cookie.split(/ *; */);
	for(var i=0; i < cookies.length; i++) {
		var current_c = cookies[i].split("=");
		if(current_c[0] == name_c) {
			current_val = current_c[1];
			break;
		}
                else if(current_c[0] == name_c + '-lang') {
			var lang = current_c[1];
           		var loc = location.href;
                        var rg = new RegExp("/" + lang + "/");
                        if(loc.match(rg) == null) {
				location.href="../" + lang + "/toc.html";
			}                        
                }
	}

	if(current_val.length <= 0) { return;}

	var ids = current_val.split(",");

	for(var i=0; i < ids.length; i++) {
		var entity = document.getElementById(ids[i]);
		if(entity) {
			var my_class = entity.className;
			var my_parent = entity.parentNode;
			if(my_class.indexOf("hidden") != -1) {
				entity.className = my_class.replace(/hidden/,"visible");
				my_parent.className = my_parent.className.replace(/collapsed/,"expanded");
			}
		}
	}

}

function toggle(e, id) {
	if(work) {
		work = 0;
		var entity = document.getElementById(id);
		if(entity) {
			var my_class = entity.className;
			var my_parent = entity.parentNode;
			if(my_class.indexOf("hidden") != -1) {
				entity.className = my_class.replace(/hidden/,"visible");
				my_parent.className = my_parent.className.replace(/collapsed/,"expanded");
				addID(id);
			}
			else if(my_class.indexOf("visible") != -1) {
				entity.className = my_class.replace(/visible/,"hidden");
				my_parent.className = my_parent.className.replace(/expanded/,"collapsed");
				removeID(id);
			}
			else {

			}
		}
	}
}

function loadToc() {
	var my_select = document.getElementById('langselect');
	if (my_select.selectedIndex > 0) {
		var expDate = new Date();
		expDate.setDate(expDate.getDate() + num_days);
		setCookie(name_c + '-lang', my_select.options[my_select.selectedIndex].value, expDate, '/', false, false);              
		location.href="../" + my_select.options[my_select.selectedIndex].value + "/toc.html";
//		parent.frames.main.location.replace("../" + my_select.options[my_select.selectedIndex].value + "/index.html");
	}
}

function checkCookie() {
	var found = false;
	var testCookie = 'test_nocookie';

	addID(testCookie);

	if(document.cookie) {
		var cookies = document.cookie.split(/ *; */);
		for(var i=0; i < cookies.length; i++) {
			var current_c = cookies[i].split("=");
			if(current_c[0] == name_c) {
				var ids = current_c[1].split(',');
				for( var j=0; j < ids.length; j++) {
					if(ids[j] == testCookie) {
						found = true;
						break;
					}
				}
				break;
			}
		}
	}

	if (found) {
		removeID(testCookie);
	} else {
		var entity = document.getElementById('nocookie');
		var my_class = entity.className;
		entity.className = my_class.replace(/hidden/, "nocookie");
//		alert("DEBUG: The Navigation Menu requires cookies to be enabled to function correctly.");
	}
}

function hideNoJS() {
	var entity = document.getElementById('nojs');
	entity.className = 'hidden';
}

