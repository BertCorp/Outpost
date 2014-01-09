// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/sstephenson/sprockets#sprockets-directives) for details
// about supported directives.
//
// require jquery
//= require jquery_ujs
// require turbolinks
//= require pages
// require twitter/bootstrap
//= require bootstrap-3.0.2.min
// require moment-2.4.0
// require bootstrap-datetimepicker-2.1.20
// require_tree .

/*$(function() {
	$('.datetimepicker').datetimepicker();
});*/


function formatTime(d) {
	var y = d.getFullYear();
	var m = d.getMonth();
	var day = d.getDate();
	var hr = d.getHours();
	var min = d.getMinutes();
	var sec = d.getSeconds();
	m = m+1;
	if (m<10) m = "0" + m;
	if (day<10) day = "0" + day;
	if (hr<10) hr = "0" + hr;
	if (min<10) min = "0" + min;
	if (sec<10) sec = "0" + sec;
	return y + "-" + m + "-" + day + " " + hr + ":" + min + ":" + sec;
} //formatTime