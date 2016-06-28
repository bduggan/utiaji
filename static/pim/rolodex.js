use_tags(['div','row','textarea','a','h4','br'])

var Rolodex = React.createClass({
    getInitialState: function() {
        var state = this.props.initial_state;
        return state;
    },
    render: function() {
        return div(
            h4( { className: 'text-center' }, 'Rolodex' )
        )
    }
});

