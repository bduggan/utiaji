use_tags(['div','table','tbody','tr','th','td','span','textarea','a','pre']);

var cache = {};   // map from index to date

var Cal = React.createClass({

    getInitialState: function() {
        var props = this.props.initial_data;
        // initial_data:
        // first : new Date( ...)  -- date of first sunday
        // month : data['month'],  -- month name
        //  year  : data['year'],
        //  data : data['data']  -- map from yyyy-mm-dd to text for that day
        //  changed : { a subset of data: map from yyyy-mm-dd to text for that day (updated, not saved)}
        //  last_touch : timestamp of last keystroke

        props['last_touch'] = new Date().getTime();
        return props;
    },
    save: function() {
        var url = window.location.href;
        var that = this;
        var data = this.state.changed;
        this.setState({changed: false});
        fetch(url, {
            method: 'POST',
            headers: { 'Content-Type' : 'application/json' },
            body: JSON.stringify({data:data})
        })
        .then(function(data){
            that.touch();
        })
        .catch(function(err) {
            console.log('error',err,'unsaved:',data);
            var reverted_state = Object.assign( data, this.state.changed || {})
            that.setState(reverted_state);
        })
    },
    load: function(from,to) {
        console.log('loading');
        var url = window.location.href;
        url += '/range/' + from.ymd() + '/' + to.ymd();
        var that = this;
        fetch(url, {
            headers: { 'Content-Type' : 'application/json' },
        }).then(function(res){
            return res.json();
        }).then(function(j){
            that.setState({ data: j, changed: false });
        }).catch(function(err) {
            console.log('error',err);
        })
    },
    reload: function() {
        var first = this.state.first;
        this.load(first.addDays(-42), first.addDays(83));
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
       var cl = 'normal';
       if (dt.mon() != this.state.month) {
           cl = 'other';
       }
       return td( { className: cl, onClick: this.edit.bind(this,i) },
                  span( { className:'dt', id: i}, dt.d()),
                  span( { html: wikify( this.state.data[ dt.ymd() ] ) })
                );
    },
    editcell: function(i) {
        var txt = this.state.data[this.dt(i).ymd()];
        return td( {className:'edit'},
            textarea({autoFocus: true,
                id: i,
                className: ( this.state.changed ? 'changed' : 'saved' ),
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
        console.log('maybe save');
        if (this.state.changed) {
            console.log('save');
            this.save();
            return;
        }
        if (this.state.editing !== undefined) {
            var now = new Date().getTime();
            var last = this.state.last_touch;
            if (now - this.state.last_touch > 4000) {
                this.setState({editing: undefined });
            }
        }
        if (!this.state.changed && !this.state.editing && (now - this.state.last_touch) > 4000) {
            console.log('reload');
            this.reload();
        }
    },
    touch: function() {
        this.setState({ last_touch: new Date().getTime() });
    },
    componentDidMount: function() {
        setInterval(this.maybeSave,1500)
    },
    handleChange: function(e) {
        var i = e.target.id;
        var dt = this.dt(i);
        var d = this.state.data;
        var changed = this.state.changed || {};
        d[dt.ymd()] = e.target.value;
        changed[dt.ymd()] = e.target.value;
        console.log('changed',changed);
        this.touch();
        this.setState({data: d});
        this.setState({changed: changed});
    },
    nextmonth: function(e) {
        this.setState({editing: undefined });
        cache = {};
        var first = this.state.first.addDays(6);
        var thismonth = first.getMonth();
        while (first.getMonth() == thismonth) {
            first = first.addDays(7);
        }
        first = first.addDays(-6);
        this.setState({ first: first } );
        this.setState({ month: next_month(this.state.month) });
        if (this.state.month == 'Jan' ) {
            this.setState({ year: this.state.year + 1 });
        }
        this.load(first.addDays(-42), first.addDays(83));
    },
    prevmonth: function(e) {
        this.setState({editing: undefined });
        cache = {};
        var first = this.state.first.addDays(-1);
        var lastmonth = first.getMonth();
        while (first.getMonth() == lastmonth) {
            first = first.addDays(-7);
        }
        first = first.addDays(1);
        this.setState({ first: first } );
        this.setState({ month: prev_month(this.state.month) });
        if (this.state.month == 'Dec' ) {
            this.setState({ year: this.state.year - 1 });
        }
        this.load(first.addDays(-42), first.addDays(83));
    },
    render: function() {
        var stat = this.state.changed ? 'changed' : 'saved';
        return div(

            div( {className: 'status-indicator ' + stat }, '' ),

            div( {className: 'row text-center'},
                div( {className: 'columns' },
                    div( {className: 'tiny inlineblock secondary button-group'},
                        a( {className: 'button', onClick: this.prevmonth }, '<-' ),
                        div( {className: 'button month'},
                            ( this.state.month + ' ' + this.state.year ) ),
                        a( {className: 'button', onClick: this.nextmonth }, '->' )
                    )
                )
            ),

            table( {className: 'cal' },
                tbody(
                  ...tr([
                        th( ['sun', 'mon', 'tue', 'wed', 'thu', 'fri', 'sat'] ),
                        this.cells( 0, 7),
                        this.cells( 7,14),
                        this.cells(14,21),
                        this.cells(21,28),
                        this.cells(28,35),
                        this.cells(35,42),
                      ])
                    )
                 )
               //,pre(JSON.stringify(this.state.changed))
            )
    }
});


