
test('get rss from url',()->
	url = Reader.get_rss('techcrunch.com')
	ok(1, 'Rss retriving result:'+url)
)

asyncTest('get feeds',()->
	url = Reader.get_rss('techcrunch.com')
	Reader.get_feeds(url,(data)->
		console.log 'back now'
		ok(true,'feeds get '+data.items.length+ ' items')
		start()
	)
)

asyncTest('get icon',()->
	Reader.get_icon('http://techcrunch.com',(icon)->
		ok(true,'icon retrived: '+icon)
		start()
	)
)

