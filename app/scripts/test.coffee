
test('get rss from url',()->
	url = Reader.get_rss('techcrunch.com')
	ok(1, 'Rss retriving result:'+url)
)

test('get feeds',()->
	url = Reader.get_rss('techcrunch.com')
	Reader.get_feeds(url,(data)->
		
	)
)

test('get icon',()->
	Reader.get_icon('http://techcrunch.com',(icon)->
		
	)
)

test('get first image',()->
	
)
