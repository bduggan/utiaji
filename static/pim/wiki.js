use_tags(['div','row','textarea','a','h2','br'])

/* Wiki */
var Wiki = React.createClass({

    getInitialState: function() {
        var state = this.props.initial_state;
        // txt
        // date
        // pages
        state['editing'] = state['txt'] ? false : true;
        state['version'] = 1;
        state['last_save'] = 1;
        state['last_touch'] = new Date().getTime();
        return state;
    },

    componentDidMount: function() {
        setInterval(this.maybeSave,1000)
    },

    maybeSave: function() {
        if (this.is_modified()) {
            this.save();
            return;
        }
        if (this.state.editing && this.state.txt && this.elapsed(3000)) {
            this.setState({editing: false});
        }
        return;
    },

    elapsed: function(t) {
        var e = new Date().getTime() - this.state.last_touch;
        return e > t;
    },

    save: function() {
        var url = window.location.href;
        var that = this;
        var state = this.state;
        fetch(url, {
            method: 'POST',
            headers: { 'Content-Type':'application/json'},
            body: JSON.stringify({txt:unescape(this.state.txt)})
        })
        .then(function(data){
            that.setState({ last_save: state.version })
        })
        .catch(function(err) {
            console.log('error ' ,err);
        })
    },

    handleChange: function(e) {
        var value = e.target.value;
        this.setState(function(prev,curr) {
            return {
                version: prev.version + 1,
                last_touch: new Date().getTime(),
                txt: value
            };
        })
    },

    touch: function() {
        this.setState({ last_touch: new Date().getTime() });
    },

    editMode: function(e) {
        if (e.target.getAttribute('href')) { return; }
        this.setState({ editing: true } );
        this.touch();
    },
    viewMode: function(e) {
        this.setState({ editing: false } );
    },
    is_modified: function() {
        return this.state.version > this.state.last_save;
    },
    render: function () {
        var s = this.state;
        return div(
                h2( { className: 'text-center' }, s.name ),
                row( div( { className: 'linklist' },
                           ...s.dates.map( function(v) {
                                return a({className:'small hollow button', href:'/cal/' + v},v)
                              } ),
                           ...s.pages.map( function(v) {
                                return a({className:'small hollow button', href:'/wiki/' + v},v)
                              } )
                        )
                    ),
                    div( { className: 'status-indicator ' + (this.is_modified() ? 'changed' : 'saved') } ),
                    div( { className: 'mode-switcher' },
                        s.editing ? a({className:'tiny hollow secondary button',onClick:this.viewMode},'view' )
                                  : a({className:'tiny hollow button',onClick:this.editMode},'edit')
                    ),
                row(
                    s.editing ?
                    textarea(
                        {
                            className: 'wiki',
                            autoFocus: true,
                            id: 'note',
                            onChange: this.handleChange,
                            onKeyDown: this.touch,
                            placeholder: 'New Page (use @link to make links)',
                            rows: 19, value: s.txt
                        })
                    : div({
                        className: 'wiki',
                        onClick: this.editMode,
                        html: wikify(s.txt)
                    })
                )
                );
    }
});

