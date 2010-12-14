$(document).ready(function(){
						   
	$("#login-toggle").click(function () {
		$("#login-wrapper").slideToggle("slow");
	});

});

$(document).ready(function(){
						   
	$("#overflow-toggle").click(function () {
		$("#overflow").slideToggle("slow");
		var toggle = document.getElementById("overflow-toggle");
		var toggleText = toggle.firstChild.nodeValue;

		if (toggleText == "Read more...") {
			document.getElementById("overflow-toggle").firstChild.nodeValue = "Read less...";
			return false;
		} 
		
		if (toggleText == "Read less...") {
			document.getElementById("overflow-toggle").firstChild.nodeValue = "Read more...";
			return false;
		}
	});

});