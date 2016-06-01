use_tags(['div','table','tbody','tr','th','td','span','textarea','a','pre','i']);

var cache = {};   // map from index to date

var Cal = React.createClass({

    getInitialState: function() {
        var props = this.props.initial_state;
        // initial_data:
        // first : new Date( ...)  -- date of first sunday
        // month : data['month'],  -- month name
        //  year  : data['year'],
        //  data : data['data']  -- map from yyyy-mm-dd to text for that day
        //  changed : { a subset of data: map from yyyy-mm-dd to text for that day (updated, not saved)}
        //  last_touch : timestamp of last keystroke

        props['last_touch'] = new Date().getTime();
        props['version'] = 1;
        props['last_save'] = 1;
        return props;
    },
    save: function(stop_edit) {
        var url = '/cal';  // window.location.href;
        var that = this;
        var state = this.state;
        fetch(url, {
            method: 'POST',
            headers: { 'Content-Type' : 'application/json' },
            body: JSON.stringify({data:state.changed})
        })
        .then(function(response){
            if (response.ok) {
                that.touch();
                that.setState({last_save: state.version});
            } else {
                console.log('response is not ok', response);
            }
        })
        .catch(function(err) {
            console.log("network error", err);
        })
    },
    load: function(from,to) {
        var url = '/cal/range/' + from.ymd() + '/' + to.ymd();
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
       var td_class = 'normal';
       if (dt.mon() != this.state.month) {
           td_class = 'other';
       }
       var dt_class = this.is_modified() && this.state.changed[dt.ymd()] ? 'pending' : '';
       return td( { className: td_class, onClick: this.edit.bind(this,i) },
           span(
               { className:dt_class + ' dt ',
                 id: i
           }, dt.d()),
                  span( { html: wikify( this.state.data[ dt.ymd() ] ) })
                );
    },
    editcell: function(i) {
        var txt = this.state.data[this.dt(i).ymd()];
        var dt_class = this.is_modified() ? 'changed' : 'saved';
        return td( { className:'edit'},
            span(
                { className:'dt ' + dt_class,
                  id: i,
                  onClick: this.sync,
                }, ''),
            textarea({autoFocus: true,
                id: i,
                className: ( this.is_modified() ? 'changed' : 'saved' ),
                onKeyDown: this.touch,
                defaultValue: txt,
                onChange: this.handleChange })
               );
    },
    sync: function() {
        this.stopEdit();
        if (this.is_modified()) {
            this.save();
        }
        this.reload();
    },
    stopEdit: function() {
        this.setState({editing:undefined});
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
        if (this.is_modified()) {
            this.save();
            return;
        }
        if (this.state.editing !== undefined) {
            var now = new Date().getTime();
            if (now - this.state.last_touch > 2000) {
                this.stopEdit();
                this.reload();
            }
            return;
        }
        if ((now - this.state.last_touch) > 2000) {
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
        this.setState(function(prev,curr) {
            return {
                data: d,
                changed: changed,
                version: prev.version + 1,
                last_touch: new Date().getTime()
                }
            });
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
    is_modified : function() {
        return this.state.version > this.state.last_save
    },
    render: function() {
        var stat = this.is_modified() ? 'changed' : 'saved';
        return div(

            div( {className: 'status-indicator ' + stat }, '' ),

            div( {className: 'row text-center'},
                div( {className: 'columns' },
                    div( {className: 'small inlineblock secondary button-group'},
                        a( {className: 'button', onClick: this.prevmonth },
                            i( {className:"fi-arrow-left "}, "" )
                        ),
                        a( {className: 'button month'},
                            this.state.month + ' ' + this.state.year + ' ',
                                i({className: "fi-refresh"},"")
                            ),
                        a( {className: 'button', onClick: this.nextmonth },
                            i( {className:"fi-arrow-right"}, "" )
                        )
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
               //,pre( 'version: ', this.state.version, '  last save: ', this.state.last_save)
            )
    }
});


