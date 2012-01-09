(function() {
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
	
	// TODO fix for IE
	var original_top_margin = window.getComputedStyle(document.body).getPropertyValue("margin-top");
	var message = 'You are using an out-of-date version of <%= browser_name %> (<%= version.string %>). It is encouraged that you update your browser. <a href="<%= read_param(:link) || default_info_link %>?for=<%= browser %>" style="color:#8B0000">Click here</a> for more details.';

	var alert_box = document.createElement('div');
	alert_box.id = 'bad-browser-warning';
	alert_box.innerHTML	= '<div style="background-color:#f4a83d;border-bottom:1px solid #d6800c;color:#735005;font-family:Verdana,Helvetica,Geneva,Arial,sans-serif;font-size:14px;font-weight:bold;height:25px;left:0;overflow:hidden;padding-top:5px;position:fixed;text-align:center;top:0;width:100%">'+ message +'<a id="bad-browser-warning-remove" style="position:absolute;right:0;margin-right:10px;border:2px solid #735005;background-color: #FAD163;inline-display: block;padding-left:2px;padding-right:2px;text-decoration:none;color:#735005;line-height:16px" href="#">x</a></div>'

	document.body.appendChild(alert_box);
	document.body.style.marginTop = (parseFloat(convertToPixels(original_top_margin)) + 25) + 'px';

	document.getElementById('bad-browser-warning-remove').onclick = function() {
		var alert_box = document.getElementById('bad-browser-warning');
		
		document.body.removeChild(alert_box);
		document.body.style.margin = original_top_margin;
	}
;}());
