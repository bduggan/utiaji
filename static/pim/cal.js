
['div','table','tbody','tr','th','td','span']
  .map(function(v) {
    eval( v + " = gen('" + v + "');");
});

var Cal = React.createClass({

    getInitialState: function() {
        return {
            month: 'April',
            year: '2016',
            dates: [
                27,28,29,30,31, 1, 2,
                 3, 4, 5, 6, 7, 8, 9,
                10,11,12,13,14,15,16,
                17,18,19,20,21,22,23,
                24,25,26,27,28,29,30,
                 1, 2, 3, 4, 5, 6, 7
                ]
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
                        td( span( {className:'dt'}, this.state.dates.slice(0,7) ) ),
                        td( span( {className:'dt'}, this.state.dates.slice(7,14) ) ),
                        td( span( {className:'dt'}, this.state.dates.slice(14,21) ) ),
                        td( span( {className:'dt'}, this.state.dates.slice(21,28) ) ),
                        td( span( {className:'dt'}, this.state.dates.slice(28,35) ) ),
                        td( span( {className:'dt'}, this.state.dates.slice(35,42) ) )
                       ])
                     )
                 )
            )
    }
});


