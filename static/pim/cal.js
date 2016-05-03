
['div','table','tbody','tr','th','td','span']
  .map(function(v) {
    eval( v + " = gen('" + v + "');");
});

var Cal = React.createClass({

    getInitialState: function() {
        return this.props.initial_data
    },
    dt: function(i) {
        return this.state.first.addDays(i)
    },
    edit: function(e) {
        console.log('edit cell',e.target.firstChild.id);
    },
    cell: function(i) {
       var dt = this.dt(i);
       return [ span(
           {className:'dt', id: i}, dt.d()
                ), this.state.data[ dt.ymd() ] ];
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
            table( {className: 'cal', onClick: this.edit},
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


