Reader = 
  tasks : 0
  worker : null
  cache : {}
  refresh : (sites)->
    if @tasks
      console.log 'refresh in progress'
      return
    sites = FeedSite.all() if !sites
    @tasks = sites.length
    @spin('Updating')
    for site,i in sites
      @.get_feeds(site)

    return
  stop : ()->
    # hide spinner
    $('span.spinner').hide()
    angular.element(document.getElementById('app_body')).scope().app_loading = false
    angular.element(document.getElementById('app_body')).scope().$apply()
    @spinner.hide() if @spinner

  get_rss : (url)->
    # get rss address from url
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

  get_feeds :  (site)->
    # get feeds for site
    _this = @
    if site.link.indexOf('feeds.feedburner.com') isnt -1
      if site.link.indexOf('?format=xml') is -1
        link = site.link+'?format=xml'
      else
        link = site.link
    else
      link = site.link
    $.ajax
      url : link
      dataType : 'xml'
      headers: 
        Accept : "text/xml; charset=UTF-8"
      success : (data)->
        log data
        json = $.xmlToJSON(data)
        if json.rss
          _this.save_feeds(json.rss,site)
        else
          _this.save_feeds(json.feed,site)
      error : (req,msg,e)->
        log msg
        _this.tasks-- if _this.tasks>0
        if !_this.tasks
          angular.element(document.getElementById('app_body')).scope().load()
          _this.stop()
      
    return
  save_feeds : (json,site)->
    _this = this
    
    worker = new Worker('js/feed_loader.js')
    worker.postMessage(JSON.stringify(json))
    # process data back
    worker.onmessage = (evt)->
      log(JSON.parse(evt.data))
      data = JSON.parse(evt.data)
      # save site data
      if data.site.title
        if !data.site.icon
          delete data.site.icon
        
        site.updateAttributes(data.site)
      
      # save feed data
      FeedItem.batch_mode = true
      FeedItem.on_batch_save = false

      for feed,i in data.items
        if i is data.items.length-1
          FeedItem.on_batch_save = true
        
        item = FeedItem.findByAttribute('link',feed.link)
        if !item
          item = FeedItem.create(feed)
        else
          item.save()
      # save batch
      FeedItem.batch_mode = FeedItem.on_batch_save = false

      _this.tasks-- if _this.tasks>0
      if !_this.tasks
        angular.element(document.getElementById('app_body')).scope().load()
        _this.stop()
      # terminate worker
      worker.terminate()
      return