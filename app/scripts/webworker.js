// Generated by CoffeeScript 1.6.3
(function() {
  var async, cors_server;

  cors_server = 'http://192.241.167.76:9292/';

  async = function(config) {
    var method, req;
    if (location.href.indexOf('chrome') === -1) {
      config.url = config.url.replace('http://', "").replace('www', "");
      config.url = cors_server + config.url;
    }
    req = new XMLHttpRequest();
    method = config.method ? config.method : 'get';
    req.open('get', config.url, true);
    req.onreadystatechange = function() {
      if (req.readyState === 4 && req.status) {
        return config.success(req.response);
      }
    };
    return req.send(null);
  };

  this.onmessage = function(evt) {
    var data;
    data = JSON.parse(evt.data);
    return async({
      url: data.url,
      success: function(res) {
        return postMessage(res);
      }
    });
  };

}).call(this);
