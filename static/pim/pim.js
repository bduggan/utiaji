function gen(el) {
    return function() {
        var args = Array.from(arguments);
        var attrs = {};
        var contents = [];
        if (typeof(args[0]) == 'object'
             && !Array.isArray(args[0])
             && ( !args[0]['type'] || el=='input' )
        ) {
            attrs = args.shift()
        }
        if (attrs['html']) {
            var h = attrs['html'];
            delete attrs['html'];
            attrs['dangerouslySetInnerHTML'] = { __html: h };
        }
        if (args.length == 0 ) {
           return React.createElement(el,attrs);
        }
        if (! Array.isArray(args[0]) ) {
            return React.createElement(el,attrs,args);
        }
        contents = args.shift();
        return contents.map( function(v) {
            return React.createElement(el, attrs, v)
        } )
    }
}

function use_tags(els) {
  els.map(function(v) {
    eval( v + " = gen('" + v + "');");
  });
}

function escape(str) {
  if (str == null) { str = ''; }
  return str.replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;')
    .replace(/'/g, '&apos;')
}
function unescape(str) {
  if (str == null) { str = ''; }
    return str.replace('&amp;', '&', 'g')
    .replace('&lt;','<','g')
    .replace('&gt;','>','g')
    .replace('&quot;', '"', 'g')
    .replace('&apos;', "'", 'g')
}
function pad(p) {
    if ( p > 9 ) return p;
    return '0' + p;
}
Date.prototype.addDays = function(days) {
    var result = new Date(this);
    result.setDate(result.getDate() + days);
    return result;
}
Date.prototype.ymd = function(d) {
    return this.toISOString().substr(0,10);
}
Date.prototype.d = function(d) {
    return this.getDate()
}


function wikify(str) {
    return escape(str)
    .replace(/@(\w+)/g, "<a href='/wiki/$1'>$1</a>");
}

var months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec' ];
function month_name(i) {
    return months[i-1];
}

Date.prototype.month = function() {
    return this.getMonth() + 1;
}

function post_json() {
   var args = Array.from(arguments);
   var url;
   if (typeof(args[0])=='string') {
       url = args.shift();
   } else {
       url = window.location.href;
   }
   var j = args[0];
   return fetch(url,{
       credentials: 'same-origin',
       method: 'POST',
       headers: { 'Content-Type':'application/json'},
       body: JSON.stringify(j)
   })
}

function put_file(id) {
   var file = document.getElementById(id).files[0];
   return fetch('/up/' + file.name, {
       credentials: 'same-origin',
       method: 'PUT',
       headers: { 'Content-Type': file.type },
       body: file
   });
}

function logerr(err) {
    console.log(err);
}

function get_json() {
  var url = window.location.href;
  url += '.json';
  return fetch(url, {
     credentials: 'same-origin',
     headers: { 'Content-Type' : 'application/json' },
  }).then(function(res){
     return res.json();
  })
}
