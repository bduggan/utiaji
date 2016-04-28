els = ['div','table', 'tr', 'td']

str = els.map(function(v) {
    return "var " + v + " = React.createFactory('" + v + "');"
})
eval(str.join(' '));

function th() {
    var args = Array.from(arguments);
    var attrs = {};
    var contents = [];
    if (typeof args[0] == 'object' && ! Array.isArray(args[0])) {
        attrs = args.shift()
    }
    contents = args.shift();
    console.log('attrs', attrs);
    console.log('contents', contents);
    if (! Array.isArray(contents)) {
        contents = [ contents ]
    }
    return contents.map( function(v) { return React.createElement('th', attrs, v) } )
}

var Cal = React.createClass({

    getInitialState: function() {
        return { }
    },
    handleChange: function(e) {
        this.setState({ text: e.target.value } );
    },
    render: function() {
        return div( {},
            div( {className: 'text-center'} , 'April 2016' ),
            table( {className: 'cal'},
                tr( {} , th( ['sun', 'mon', 'tue', 'wed', 'thu', 'fri', 'sat'] ) )
            )
        )
    }
});


