// asynchronously load the rss feed and pull out the news items
function loadLatestNews( targetList, rssFeedURL, maxItems ) {	
	$.ajax({ type: "GET", url: rssFeedURL, dataType: "xml", success: function(xml) {
		// get the news items from the feed
		var items = $(xml).find("channel").find("item:lt("+maxItems+")");
		
		// create links to items
		items.each(function(i) {
			var title = $(this).find("title").text();
			var description = $(this).find("description").text().replace(' [...]','... ');
			var pubDate = $(this).find("pubDate").text();
			var link = $(this).find("link").text();
			//$(targetList).append("<li><a href='"+link+"'>"+title+"</a></li>");
			$(targetList).append("<li><a href='"+link+"'>"+title+"</a><br /><span>Posted on "+pubDate+"</span> <p>"+description+"<a href='"+link+"'>Read more</a></p></li>");
		});
		
	}});
}