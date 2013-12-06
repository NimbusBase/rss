QUnit.begin(()->
	test('get rss from url',()->
		url = Reader.get_rss('techcrunch.com')
		ok(1, 'Rss retriving result:'+url)
	)

	test('get feeds',()->
		url = Reader.get_rss('techcrunch.com')
		Reader.get_feeds(url,(data)->
			if data
				ok(1,'feed content length: '+data.length)
			else
				ok(0,'get feeds failed')
		)
	)

	test('get icon',()->
		Reader.get_icon('http://techcrunch.com',(icon)->
			if icon
				ok(1,'icon retrived :'+icon)
			else
				ok(0,'icon retrive failed')
		)
	)

	test('get first image',()->
		ok(1,'wait for test')
	)
)