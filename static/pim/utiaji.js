var el = React.createElement;

var Cal = React.createClass({
    getInitialState: function () {
        return {
            events: [],
            loaded: false
        }
    },

    componentDidMount: function () {
        var that = this;
        // Simple response handling
        fetch('/today').then(function(response) {
            // console.log(response);
            return response.json();
        }).then(function(json) {
            console.log(json);
            that.setState({ events: json.events, loaded: true });
        }).catch(function(err) {
            console.log(err);
            console.warn('failed to load');
        });
    },

    render: function () {
        return (
            el('div', {},
                el('h1', {}, 'Today'),
                el('div', { className: 'events' },
                    this.state.events.map(evt)
                )
            )
        )
    }
})

var evt = function (evt) {
    return el('div', { className: 'event' }, evt);
}

