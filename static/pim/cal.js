
['div','table','tbody','tr','th','td','span','textarea']
  .map(function(v) {
    eval( v + " = gen('" + v + "');");
});

var cache = {}; // map from index to date

var Cal = React.createClass({

    getInitialState: function() {
        return this.props.initial_data
    },
    dt: function(i) {
        if (cache[i]) { return cache[i] };
        cache[i] = this.state.first.addDays(i);
        return cache[i];
    },
    edit: function(e) {
        if (!e.target.firstChild) { return; }
        var index = e.target.firstChild.id;
        if (typeof index === 'undefined' ) {
            return;
        }
        this.setState({ editing:index });
        console.log('edit cell',index);
    },
    cell: function(i) {
       var dt = this.dt(i);
       console.log('generating ',i,dt.d());
       return [ span(
           {className:'dt', id: i}, dt.d()
                ), this.state.data[ dt.ymd() ] ];
    },
    editcell: function(i) {
        var txt = this.state.data[this.dt(i).ymd()];
        return textarea({autoFocus: true, id: i, defaultValue:txt,onChange: this.handleChange });
    },
    cells: function(from,to) {
        var x = [];
        var e = this.state.editing;
        for (i=from;i<to;i++) {
            if (e==i) {
              x.push( this.editcell(i) );
            } else {
              x.push( this.cell(i) );
            }
        }
        return x;
    },
    maybeSave: function() {
        if (!this.state.changed) {
            return;
        }
        this.save();
    },
    save: function() {
        console.log('saving');
        var url = window.location.href;
        var that = this;
        fetch(url, {
            method: 'POST',
            headers: { 'Content-Type' : 'application/json' },
            body: JSON.stringify({data:this.state.data})
        })
        .then(function(data){
            console.log('got',data);
            that.setState({changed: false})
        })
        .catch(function(err) {
            console.log('error',err);
        })
    },
    componentDidMount: function() {
        setInterval(this.maybeSave,1500)
    },
    handleChange: function(e) {
        var i = e.target.id;
        console.log('looking up',i);
        var dt = this.dt(i);
        console.log('date is ',dt);
        var d = this.state.data;
        d[dt.ymd()] = e.target.value;
        this.setState({data: d});
        this.setState({changed: true});
    },
    render: function() {
        var stat = this.state.changed ? 'changed' : 'saved';
        return div(
            div( {className: 'status-indicator ' + stat }, '' ),
            div( {className: 'text-center month'} , ( this.state.month + ' ' + this.state.year ) ),
            table( {className: 'cal', onClick: this.edit},
                tbody(
                  ...tr([
                        th( ['sun', 'mon', 'tue', 'wed', 'thu', 'fri', 'sat'] ),
                        td( this.cells( 0, 7) ),
                        td( this.cells( 7,14) ),
                        td( this.cells(14,21) ),
                        td( this.cells(21,28) ),
                        td( this.cells(28,35) ),
                      ])
                    )
                 )
            )
    }
});


