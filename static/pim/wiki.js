use_tags(['div','row','textarea','a','h4','br','checkbox','img'])

var _wiki = {
    getInitialState: function() {
        var s = this.init(this.props.initial_state);
        // txt, date, pages
        s['editing'] = state['txt'] ? false : true;
        s['autoview'] = state['txt'] ? true : false;
        return s;
    },
    save: function() {
        var that = this;
        var state = this.state;
        post_json({ txt: unescape(this.state.txt)})
        .then(function(data){
            that.setState({ last_save: state.version })
        })
        .catch(logerr)
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
    files:  function() {
        return row(
            a( { href: "/up/florida-flight.pdf" },
                img({className:'up', src:"/thumb/florida-flight.pdf.png"})
            ),
            a( { href: "/up/florida-flight.pdf" },
                img({className:'up', src:"/thumb/florida-flight.pdf.png"})
            )
        )
    },
    edit_button: function() {
        var s = this.state;
        return div( { className: 'mode-switcher' },
                        s.editing ? (
                                    div( this.autoviewbutton(),
                                    a({className:'tiny hollow secondary button',onClick:this.viewMode},'view' ))
                                    )
                                  : a({className:'tiny hollow button',onClick:this.editMode},'edit')
                              )
    },
    render: function () {
        var s = this.state;
        return div(
                this.status_indicator(),
                this.edit_button(),
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
                    }),
                    this.files()
                )
                );
    }
};

var Wiki = React.createClass(Autosaver(_wiki));

