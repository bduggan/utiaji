els = ['div','table', 'tr', 'td','th']

str = els.map(function(v) {
    return "var " + v + " = React.createFactory('" + v + "');"
})
eval(str.join(' '));

function TH(attrs,contents) {
    return contents.map( function(v) { return th(attrs,v) } )
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
                tr( {} , TH( {}, ['sun', 'mon', 'tue', 'wed', 'thu', 'fri', 'sat'] ) )
            )
        )
    }
});


