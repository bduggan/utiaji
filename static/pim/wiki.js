use_tags(['div','row','textarea','a','pre'])

/* Wiki */
var Wiki = React.createClass({

    getInitialState: function() {
        var txt = this.props.initial_state.txt;
        var dates = this.props.initial_state.dates;
        return {
            editing: (txt ? false : true),
            txt: txt,
            dates: dates,
            version: 1,
            last_save: 1
        }
    },

    componentDidMount: function() {
        setInterval(this.maybeSave,1500)
    },

    maybeSave: function() {
        if (!this.is_modified()) {
            return;
        }
        this.save();
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
        this.setState({ txt: this.state.txt, editing: true } );
    },

    is_modified: function() {
        return this.state.version > this.state.last_save;
    },
    render: function () {
        return div(
                row( ...div( { className: 'datelist' },
                           this.state.dates.map( function(v) {
                              return a({className:'small hollow button', href:'/cal/' + v},v)
                            } )
                        )
                    ),
                div( { className: 'status-indicator ' + (this.is_modified() ? 'changed' : 'saved') }, ''),
                row(
                    this.state.editing ?
                    textarea( { id: 'note', onChange: this.handleChange,
                        placeholder: 'New Page (use @link to make links)',
                        rows: 19, value: this.state.txt })
                    : pre({
                        className: 'secondary callout',
                        onClick: this.editMode,
                        html: wikify(this.state.txt)
                    })
                )
                );
    }
});

