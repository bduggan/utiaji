els = ['div','table', 'tr', 'td']

str = els.map(function(v) {
    return "var " + v + " = React.createFactory('" + v + "');"
})
eval(str.join(' '));

var Cal = React.createClass({

    getInitialState: function() {
        return { }
    },
    handleChange: function(e) {
        this.setState({ text: e.target.value } );
    },
    render: function() {
        return div( {},
            div( {className: 'text-center'} , 'April 2016' )
        )
    }
});


