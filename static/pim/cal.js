
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

['div','table','tbody','tr','th','td']
  .map(function(v) {
    eval( v + " = gen('" + v + "');");
});

var Cal = React.createClass({

    getInitialState: function() {
        return { }
    },
    handleChange: function(e) {
        this.setState({ text: e.target.value } );
    },
    render: function() {
        return div(
            div( {className: 'text-center'} , 'April 2016' ),
            table( {className: 'cal'},
                ...tr([
                    th( ['sun', 'mon', 'tue', 'wed', 'thu', 'fri', 'sat'] ),
                    td( ['0', '1', '2', '3', '4', '5', '6' ] ),
                    td( ['0', '1', '2', '3', '4', '5', '6' ] ),
                    td( ['0', '1', '2', '3', '4', '5', '6' ] ),
                    td( ['0', '1', '2', '3', '4', '5', '6' ] ),
                    td( ['0', '1', '2', '3', '4', '5', '6' ] ),
                    td( ['0', '1', '2', '3', '4', '5', '6' ] )
                 ])
            )
        )
    }
});


