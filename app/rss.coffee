window.Reader = 
  tasks : 0
  worker : null
  cache : {}
  cors : 'http://192.241.167.76:9292/'
  refresh : (url,callback)->
    Reader.get_feeds(url,callback)

  get_rss : (url)->
    # get rss address from url
    if url.indexOf('http') isnt 0
      url = 'http://'+url
    
    @cache.url = url
    original_url = url
    is_rss_url = false
    rss_tag_present = false
    # ajax url test
    config = 
      'url' : url
      dataType : 'xml'
      async : false
      success : (data,status,xhr)->
        # save as url
        console.log 'ok'
        is_rss_url = true
        Reader.cache.url = config.url.replace('?format=xml','')
      error : (req,msg,e)->
        # try parse content for rss tag
        console.log 'error'
        regexp = /<link.*type=['"]application\/rss\+xml['"].*\/*>/
        match = regexp.exec(req.responseText)
        if match 
          rss_tag_present = true
          link_exp = new RegExp('href=[\'\"][^\'^\"]+')
          link = link_exp.exec(match)[0].replace('href=','').replace('"','').replace("'",'')
          url = if link.indexOf('http') isnt -1 then link else url+link
          Reader.cache.url = url

        # retrive favico
        icon_reg = /<link.*rel="shortcut icon".*href=(\S*)\s*\/?>/
        icons = icon_reg.exec(req.responseText)
        if icons
          icon_exp = new RegExp('href=[\'\"][^\'^\"]+')
          icon = icon_exp.exec(icons)[0].replace('href=','').replace('"','').replace("'",'')
          if icon.indexOf('http://') is -1 or icon.indexOf('https://') is -1
            icon = original_url+'/'+icon
          
          Reader.cache.icon = icon
          
        return
    $.ajax config
    return Reader.cache.url if is_rss_url || rss_tag_present
    # test rss tag
    _this = @
    if !rss_tag_present
      is_feedburner_ok = false
      # test feed burner url instead
      config.url = @.feedburner_url(original_url)+'?format=xml'
      config.error = (req,msg,e)->
        console.log e
      $.ajax config
      if is_rss_url
       return config.url.replace('?format=xml','')
      else 
        return is_rss_url
    
  feedburner_url : (url)->
    # generate feedburner url
    return url if url.indexOf("feedburner.com") != -1
    url = url.replace("http://", "").replace("https://", "").replace("www.", "")
    index = url.indexOf("/")
    url = url.substring(0, index) if index != -1
    url = 'http://feeds.feedburner.com/'+url
    url

  get_feeds :  (site,callback,on_error)->
    # get feeds for site
    _this = @
    if site.indexOf('feeds.feedburner.com') isnt -1
      if site.indexOf('?format=xml') is -1
        link = site+'?format=xml'
      else
        link = site
    else
      link = site

    # run with webworker
    worker = new Worker('scripts/webworker.js')
    worker.postMessage(JSON.stringify(site))
    # process data back
    worker.onmessage = (evt)->
      feed = new JFeed(evt.data)
      console.log feed
      if callback
        callback(feed)
      
    return

  get_icon : (url,callback)->
    #url = feedItem.link
    icon = ""

    last = url.length-1
    if url[last] is "/"
      icon = url+"favicon.ico"
    else
      icon = url+"/favicon.ico"

    icon = icon.replace('feeds.feedburner.com/',"").replace('?format=xml',"")

    config = 
      'url': icon,  
      success: (data)->
        if callback
          callback(icon)

      error: (data) ->
        console.log("THERE IS NO ICON AT DEFAULT LOCATION")
        config =
          'url': url,  
          success: (data)->
            iframe = document.getElementById('parse-iframe')
            document.body.removeChild(iframe) if iframe        
            iframe = document.createElement("iframe");
            iframe.id = 'parse-iframe'
            iframe.style.display = 'none'
            document.body.appendChild(iframe)
            iframeDoc = document.getElementById('parse-iframe').contentWindow.document
            iframeDoc.body.innerHTML = data   
            nodeList = iframeDoc.getElementsByTagName("link")
            for node in nodeList
              if node.getAttribute("rel").toLowerCase() == "shortcut icon"
                found_icon = node.getAttribute("href")
                
                #attach address
                if found_icon[0..3] isnt "http"
                  found_icon = feedSite.link + found_icon
            if callback
               callback(found_icon)
            
        $.ajax(config)

    $.ajax(config)

  get_first_image : (content)->
    regexp = /<img\s*[^>]*\s*src='?(\S+)'?[^>]*>/
    regexp.test(content)

    first = RegExp.$1
    first = first.replace('"', "").replace('"', "").replace("'", "").replace("'", "")
    return first

if Reader.cors isnt false
  $.ajaxPrefilter(( options, originalOptions, jqXHR )->
    options.url = options.url.replace('http://', "")
    options.url = Reader.cors+options.url
    console.log("option.url", options.url)
  )
