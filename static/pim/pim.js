function gen(el) {
    return function() {
        var args = Array.from(arguments);
        var attrs = {};
        var contents = [];
        if (typeof(args[0]) == 'object'
             && !Array.isArray(args[0])
             && !args[0]['type']
        ) {
            attrs = args.shift()
        }
        if (! Array.isArray(args[0]) ) {
            return React.createElement(el,attrs,args);
        }
        contents = args.shift();
        return contents.map( function(v) { return React.createElement(el, attrs, v) } )
    }
}

function escape(str) {
  return str.replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;')
    .replace(/'/g, '&apos;')
}
function unescape(str) {
    return str.replace('&amp;', '&', 'g')
    .replace('&lt;','<','g')
    .replace('&gt;','>','g')
    .replace('&quot;', '"', 'g')
    .replace('&apos;', "'", 'g')
}
