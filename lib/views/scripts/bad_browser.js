(function() {
	function supportsFixed() {
		var container = document.body;

		if (document.createElement && container && container.appendChild && container.removeChild) {
			var el = document.createElement('div');

			if (!el.getBoundingClientRect) return null;

			el.innerHTML = 'x';
			el.style.cssText = 'position:fixed;top:100px;';
			container.appendChild(el);

			var originalHeight = container.style.height,
			originalScrollTop = container.scrollTop;

			container.style.height = '3000px';
			container.scrollTop = 500;

			var elementTop = el.getBoundingClientRect().top;
			container.style.height = originalHeight;

			var isSupported = (elementTop === 100);
			container.removeChild(el);
			container.scrollTop = originalScrollTop;

			return isSupported;
		}
		return null;
	}

	function getTopMargin(){
		if (window.getComputedStyle)
			return window.getComputedStyle(document.body).getPropertyValue("margin-top");

		var margin = document.body.currentStyle['margin'];
		var match = margin.match(/^\d+/)
		return (match ? match[0] : 0) + 'px';
	}
	
	function convertToPixels(_str, _context) {
		if (/px$/.test(_str)) {
			return parseFloat(_str);
		}
		
		if (!_context) {
			context = document.body;
		}
		
		var tmp = document.createElement('div');
		tmp.style.visbility = 'hidden';
		tmp.style.position = 'absolute';
		tmp.style.lineHeight = '0';

		if (/%$/.test(_str)) {
			context = _context.parentNode || _context;
			tmp.style.height = _str;
		} else {
			tmp.style.borderStyle = 'solid';
			tmp.style.borderBottomWidth = '0';
			tmp.style.borderTopWidth = _str;
		}
		
		context.appendChild(tmp);
		var px = tmp.offsetHeight;
		_context.removeChild(tmp);
		
		return px + 'px';
	}

	function show_banner() {
		var original_top_margin = getTopMargin();
		var message = 'You are using an out-of-date version of <%= browser_name %> (<%= version ? version.string : "?" %>). It is encouraged that you update your browser. <a href="<%= read_param(:link) || default_info_link %>?for=<%= browser || "u" %>&version=<%= version ? version.string : "" %>" style="color:#8B0000">Click here</a> for more details.';
		var positioning = supportsFixed() ? 'fixed' : 'absolute';

		var alert_box = document.createElement('div');
		alert_box.id = 'bad-browser-warning';
		alert_box.innerHTML = '<div style="background-color:#f4a83d;border-bottom:1px solid #d6800c;color:#735005;font-family:Verdana,Helvetica,Geneva,Arial,sans-serif;font-size:12px;font-weight:bold;height:25px;left:0;overflow:hidden;padding-top:5px;position:' + positioning + ';text-align:center;top:0;width:100%">'+ message +'<a id="bad-browser-warning-remove" style="position:absolute;right:0;margin-right:10px;border:2px solid #735005;background-color:#FAD163;padding:0 3px;text-decoration:none;color:#735005;height:16px;line-height:14px;cursor:pointer">X</a></div>'

		document.body.appendChild(alert_box);
		document.body.style.marginTop = (parseFloat(convertToPixels(original_top_margin)) + 25) + 'px';

		document.getElementById('bad-browser-warning-remove').onclick = function() {
			var alert_box = document.getElementById('bad-browser-warning');
			document.body.removeChild(alert_box);
			document.body.style.margin = original_top_margin;
		}
	}
	
	if(window.attachEvent) {
		window.attachEvent('onload', show_banner);
	} else {
		if(window.onload) {
			var curronload = window.onload;
			var newonload = function() {
				curronload();
				show_banner();
			};
			window.onload = newonload;
		} else {
			window.onload = show_banner;
		}
	}
}());
