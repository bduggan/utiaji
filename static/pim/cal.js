use_tags(['div','table','tbody','tr','th','td','span','textarea']);
var cache = {}; // map from index to date

var Cal = React.createClass({

    getInitialState: function() {
        var props = this.props.initial_data;
        props['last_touch'] = new Date().getTime();
        return props;
    },
    dt: function(i) {
        if (cache[i]) { return cache[i] };
        cache[i] = this.state.first.addDays(i);
        return cache[i];
    },
    edit: function(index, e) {
        if (e.target.getAttribute('href')) { return; }
        this.setState({ editing:index });
        this.touch();
    },
    cell: function(i) {
       var dt = this.dt(i);
       return td( { onClick: this.edit.bind(this,i) },
                  span( { className:'dt', id: i}, dt.d()),
                  span( { html: wikify( this.state.data[ dt.ymd() ] ) })
                );
    },
    editcell: function(i) {
        var txt = this.state.data[this.dt(i).ymd()];
        return td(
            textarea({autoFocus: true,
                id: i,
                onKeyDown: this.touch,
                defaultValue: txt,
                onChange: this.handleChange })
               );
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
        if (this.state.editing !== undefined) {
            var now = new Date().getTime();
            var last = this.state.last_touch;
            if (now - this.state.last_touch > 4000) {
                this.setState({editing: undefined });
            }
        }
        if (!this.state.changed) {
            return;
        }
        this.save();
    },
    touch: function() {
        this.setState({ last_touch: new Date().getTime() });
    },
    save: function() {
        var url = window.location.href;
        var that = this;
        fetch(url, {
            method: 'POST',
            headers: { 'Content-Type' : 'application/json' },
            body: JSON.stringify({data:this.state.data})
        })
        .then(function(data){
            that.setState({changed: false})
            that.touch();
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
        var dt = this.dt(i);
        var d = this.state.data;
        d[dt.ymd()] = e.target.value;
        this.touch();
        this.setState({data: d});
        this.setState({changed: true});
    },
    render: function() {
        var stat = this.state.changed ? 'changed' : 'saved';
        return div(
            div( {className: 'status-indicator ' + stat }, '' ),
            div( {className: 'text-center month'} , ( this.state.month + ' ' + this.state.year ) ),
            table( {className: 'cal' },
                tbody(
                  ...tr([
                        th( ['sun', 'mon', 'tue', 'wed', 'thu', 'fri', 'sat'] ),
                        this.cells( 0, 7),
                        this.cells( 7,14),
                        this.cells(14,21),
                        this.cells(21,28),
                        this.cells(28,35),
                      ])
                    )
                 )
            )
    }
});


