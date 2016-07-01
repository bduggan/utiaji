use_tags(['div','table','tbody','tr','th','td','span','textarea','a','pre','i']);

var cache = {};   // map from index to date

var _cal = {

    getInitialState: function() {
        var s = this.props.initial_state;
        // initial_state:
        // first : new Date( ...)  -- date of first sunday
        // month : data['month'],  -- month number (1-12)
        //  year : data['year'],
        //  data : data['data']  -- map from yyyy-mm-dd to text for that day
        //  changed : { a subset of data: map from yyyy-mm-dd to text for that day (updated, not saved)}
        //  last_touch : timestamp of last keystroke

        return this.init(s);
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
    checkChanged: function() {
        if (!this.is_modified()) {
            this.setState({changed: false});
        }
    },
    edit: function(index, e) {
        if (e.target.getAttribute('href')) { return; }
        this.checkChanged();
        this.setState({ editing:index });
        this.touch();
    },
    cell: function(i) {
       var dt = this.dt(i);
       var td_class = 'normal';
       if (dt.month() != this.state.month) {
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
                className: 'cal ' + ( this.is_modified() ? 'changed' : 'saved' ),
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
        for (var i=from;i<to;i++) {
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
            if (this.elapsed(2000)) {
                this.stopEdit();
                this.reload();
            }
            return;
        }
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
        var next_month = this.state.month + 1;
        var next_year  = this.state.year;
        if (next_month==13) { next_month = 1; next_year += 1; };

        var first = this.state.first;
        while (first.month() != this.state.month) { first = first.addDays(7) }
        while (first.month() == this.state.month) { first = first.addDays(7) }
        if (first.getDate() > 1) { first = first.addDays(-7) }

        this.setState({ first: first, month: next_month, year:next_year } );
        this.load(first.addDays(-42), first.addDays(83));
    },
    prevmonth: function(e) {
        this.setState({editing: undefined });
        cache = {};
        var prev_month = this.state.month - 1;
        var prev_year  = this.state.year;
        if (prev_month==0) { prev_month = 12; prev_year -= 1; };

        var first = this.state.first;
        while (first.month() == this.state.month) { first = first.addDays(-7) }
        while (first.month() == prev_month)       { first = first.addDays(-7) }
        if (first.addDays(7).getDate() == 1) { first = first.addDays(7) }

        this.setState({ first: first, month: prev_month, year:prev_year } );
        this.load(first.addDays(-42), first.addDays(83));
    },
    permalink : function() {
        var m = this.state.month;
        if (m<10) { m = '0' + m }
        return '/cal/' + this.state.year + '-' + m + '-01';
    },
    render: function() {
        var stat = this.is_modified() ? 'changed' : 'saved';
        return div(
            div( {className: 'status-indicator ' + stat }, '' ),
            div( {className: 'row text-center'},
                div( {className: 'columns' },
                    div( {className: 'medium inlineblock button-group trimv'},
                        a( {className: 'black button', onClick: this.prevmonth },
                            i( {className:"fi-arrow-left "}, "" )
                        ),
                        a( {className: 'black button', href: this.permalink()},
                            month_name(this.state.month) + ' ' + this.state.year + ' ',
                                i({className: "fi-refresh"},"")
                            ),
                        a( {className: 'black button', onClick: this.nextmonth },
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
};

var Cal = React.createClass(Autosaver(_cal));
