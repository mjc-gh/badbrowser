$(function(){
	var generate = $('#generate');

	var form = $('.form');
	var tarea = $('textarea', form);
	
	var lower = $('.lower');
	var radios = $('input[type="radio"]', form);
	
	radios.change(function(){
		var val = $(this).val();
		lower.hide().filter('.' + val).show();

	}).filter(':checked').trigger('change');

	lower.find(':input').keypress(function(ev){
		if (ev.which == 13)
			generate.trigger('click');
	});

	generate.click(function(){
		var params = {};
		var key = radios.filter(':checked').val();
		var val = lower.filter(':visible').find(':input').val();

		if (key == 'default')
			key = 'link';
		else if (!val)
			return alert('Enter a value for the ' + key);

		if (val)
			params[key] = val;
		
		var str = $.param(params);
		var src = document.location.href.replace('#', '') + 'detect.js' + (str ? '?' : '') + str;

		tarea.val('<script type="text/javascript" src="'+ src +'"></script>');
	});
});