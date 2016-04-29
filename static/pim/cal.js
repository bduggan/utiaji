
['div','table','tbody','tr','th','td','span']
  .map(function(v) {
    eval( v + " = gen('" + v + "');");
});

var Cal = React.createClass({

    getInitialState: function() {
        return {
            month: 'April',
            year: '2016',
            first: new Date(2016,3,27),
            data: {
                '2016-04-30' : 'birthday'
            }
        }
    },
    dt: function(i) {
        return this.state.first.addDays(i)
    },
    cell: function(i) {
       var dt = this.dt(i);
       return [ span( {className:'dt'}, dt.d()), this.state.data[ dt.ymd() ] ];
    },
    cells: function(from,to) {
        x = [];
        for (i=from;i<to;i++) {
            x.push( this.cell(i) );
        }
        return x;
    },
    handleChange: function(e) {
        this.setState({ text: e.target.value } );
    },
    render: function() {
        return div(
            div( {className: 'text-center month'} , ( this.state.month + ' ' + this.state.year ) ),
            table( {className: 'cal'},
                tbody(
                  ...tr([
                        th( ['sun', 'mon', 'tue', 'wed', 'thu', 'fri', 'sat'] ),
                        td( this.cells(0,7)    ),
                        td( this.cells(14,21)  ),
                        td( this.cells(21,28)  ),
                        td( this.cells(28,35)  ),
                        td( this.cells(35,42)  ),
                      ])
                    )
                 )
            )
    }
});


