
['div','table','tbody','tr','th','td']
  .map(function(v) {
    eval( v + " = gen('" + v + "');");
});

var Cal = React.createClass({

    getInitialState: function() {
        return {
            month: 'April',
            year: '2016'
        }
    },

    handleChange: function(e) {
        this.setState({ text: e.target.value } );
    },

    render: function() {
        return div(
            div( {className: 'text-center'} , ( this.state.month + ' ' + this.state.year ) ),
            table( {className: 'cal'},
                tbody(
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
            )
    }
});


