use_tags(['div','row','textarea','a','h4','br','checkbox'])

var _wiki = {
    getInitialState: function() {
        var s = this.props.initial_state;
        // txt
        // date
        // pages
        s['editing'] = state['txt'] ? false : true;
        s['autoview'] = true;
        return this.init(s);
    },

    maybeSave: function() {
        if (this.is_modified()) {
            this.save();
            return;
        }
        if (this.state.editing && this.state.txt && this.elapsed(3000) && this.state.autoview) {
            this.setState({editing: false});
        }
        return;
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

    editMode: function(e) {
        if (e.target.getAttribute('href')) { return; }
        this.setState({ editing: true } );
        this.touch();
    },
    viewMode: function(e) {
        this.setState({ editing: false } );
    },
    autoviewon: function() { this.setState({ autoview: true } ) },
    autoviewoff: function() { this.setState({ autoview: false } ) },
    autoviewbutton: function()  {
        var s = this.state;
        if (s.autoview) {
            return a({className:'tiny hollow secondary button',onClick:this.autoviewoff},'autoview: on')
        }
        return a({className:'tiny hollow secondary button',onClick:this.autoviewon},'autoview: off')
    },
    render: function () {
        var s = this.state;
        return div(
                h4( { className: 'text-center' }, s.name ),
                row( div( { className: 'linklist' },
                           ...s.dates.map( function(v) {
                                return a({className:'small hollow button', href:'/cal/' + v},v)
                              } ),
                           ...s.pages.map( function(v) {
                                return a({className:'small hollow button', href:'/wiki/' + v},v)
                              } )
                        )
                    ),
                    this.status_indicator(),
                    div( { className: 'mode-switcher' },
                        s.editing ? (
                                    div( this.autoviewbutton(),
                                    a({className:'tiny hollow secondary button',onClick:this.viewMode},'view' ))
                                    )
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
};

var Wiki = React.createClass(Autosaver(_wiki));

