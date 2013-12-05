// Generated by CoffeeScript 1.6.3
(function() {
  window.Reader = {
    tasks: 0,
    worker: null,
    cache: {},
    cors: 'http://192.241.167.76:9292/',
    refresh: function(sites) {
      var i, site, _i, _len;
      if (this.tasks) {
        console.log('refresh in progress');
        return;
      }
      if (!sites) {
        sites = FeedSite.all();
      }
      this.tasks = sites.length;
      this.spin('Updating');
      for (i = _i = 0, _len = sites.length; _i < _len; i = ++_i) {
        site = sites[i];
        this.get_feeds(site);
      }
    },
    get_rss: function(url) {
      var config, is_feedburner_ok, is_rss_url, original_url, rss_tag_present, _this;
      if (url.indexOf('http') !== 0) {
        url = 'http://' + url;
      }
      this.cache.url = url;
      original_url = url;
      is_rss_url = false;
      rss_tag_present = false;
      config = {
        'url': url,
        dataType: 'xml',
        async: false,
        success: function(data, status, xhr) {
          console.log('ok');
          is_rss_url = true;
          return Reader.cache.url = config.url.replace('?format=xml', '');
        },
        error: function(req, msg, e) {
          var icon, icon_exp, icon_reg, icons, link, link_exp, match, regexp;
          console.log('error');
          regexp = /<link.*type=['"]application\/rss\+xml['"].*\/*>/;
          match = regexp.exec(req.responseText);
          if (match) {
            rss_tag_present = true;
            link_exp = new RegExp('href=[\'\"][^\'^\"]+');
            link = link_exp.exec(match)[0].replace('href=', '').replace('"', '').replace("'", '');
            url = link.indexOf('http') !== -1 ? link : url + link;
            Reader.cache.url = url;
          }
          icon_reg = /<link.*rel="shortcut icon".*href=(\S*)\s*\/?>/;
          icons = icon_reg.exec(req.responseText);
          if (icons) {
            icon_exp = new RegExp('href=[\'\"][^\'^\"]+');
            icon = icon_exp.exec(icons)[0].replace('href=', '').replace('"', '').replace("'", '');
            if (icon.indexOf('http://') === -1 || icon.indexOf('https://') === -1) {
              icon = original_url + '/' + icon;
            }
            Reader.cache.icon = icon;
          }
        }
      };
      $.ajax(config);
      if (is_rss_url || rss_tag_present) {
        return Reader.cache.url;
      }
      _this = this;
      if (!rss_tag_present) {
        is_feedburner_ok = false;
        config.url = this.feedburner_url(original_url) + '?format=xml';
        config.error = function(req, msg, e) {
          return console.log(e);
        };
        $.ajax(config);
        if (is_rss_url) {
          return config.url.replace('?format=xml', '');
        } else {
          return is_rss_url;
        }
      }
    },
    feedburner_url: function(url) {
      var index;
      if (url.indexOf("feedburner.com") !== -1) {
        return url;
      }
      url = url.replace("http://", "").replace("https://", "").replace("www.", "");
      index = url.indexOf("/");
      if (index !== -1) {
        url = url.substring(0, index);
      }
      url = 'http://feeds.feedburner.com/' + url;
      return url;
    },
    get_feeds: function(site, callback) {
      var link, _this;
      _this = this;
      if (site.link.indexOf('feeds.feedburner.com') !== -1) {
        if (site.link.indexOf('?format=xml') === -1) {
          link = site.link + '?format=xml';
        } else {
          link = site.link;
        }
      } else {
        link = site.link;
      }
      $.ajax({
        url: link,
        dataType: 'xml',
        headers: {
          Accept: "text/xml; charset=UTF-8"
        },
        success: function(data) {
          return log(data);
        },
        error: function(req, msg, e) {
          return log(msg);
        }
      });
    }
  };

  if (Reader.cors !== false) {
    $.ajaxPrefilter(function(options, originalOptions, jqXHR) {
      options.url = options.url.replace('http://', "");
      options.url = Reader.cors + options.url;
      return console.log("option.url", options.url);
    });
  }

}).call(this);
