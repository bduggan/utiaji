use_tags(['div','row','textarea','a','h4','br','button'])

var Rolodex = React.createClass({
    getInitialState: function() {
        var state = this.props.initial_state;
        return state;
    },
    handleChange: function(e) {
        var value = e.target.value;
        this.setState({ new_txt : value } )
    },
    savenew: function(e) {
        var value = this.state.new_txt;
        var that = this;
        post_json({ txt: value })
        .then(function(res) {
            if (res.ok) {
                console.log('saved');
            } else {
                console.log('error',res.status,res.statusText,res);
            }
        }).catch(function(err) {
            console.log('error saving')
        })
    },
    render: function() {
        var s = this.state;
        return div(
            h4( { className: 'text-center' }, 'Rolodex' ),
            row(
                div( {className: 'small-4 columns'},
                    textarea( {
                        className: 'rolodex',
                        autoFocus: true,
                        value: s.new_txt,
                        rows: 6,
                        placeholder: 'New Person',
                        onChange: this.handleChange } ),
                    a( {
                        className: 'small expanded success button',
                        onClick: this.savenew,
                        }, 'save')
                )
            )
        )
    }
});

