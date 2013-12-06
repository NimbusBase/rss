cors_server = 'http://192.241.167.76:9292/'

async = (config)->
	if location.href.indexOf('chrome') is -1
		config.url = config.url.replace('http://', "").replace('www', "")
		config.url = cors_server+config.url

	req = new XMLHttpRequest()
	method = if config.method then config.method else 'get'
	req.open('get',config.url,true)
	req.onreadystatechange = ()->
		if (req.readyState == 4 and req.status) 
			config.success(req.response)
	req.send(null)

this.onmessage = (evt)->
	data = JSON.parse(evt.data)
	async(
		url : data.url
		success : (res)->
			postMessage(res)

	)


