var el = React.createElement;

var Cal = React.createClass({
    getInitialState: function () {
        return {
            day: 'today',
            events: [],
            loaded: false
        }
    },

    fetchEvents: function (day) {
        var that = this;
        return fetch('/' + day).then(function(response) {
            return response.json();
        }).then(function(json) {
            console.log(json);
            that.setState({ events: json.events, loaded: true });
        }).catch(function(err) {
            console.log(err);
            console.warn('failed to load');
        });
    },

    componentDidMount: function () {
        this.fetchEvents(this.state.day);
    },

    componentWillUpdate: function (nextProps, nextState) {
        if (nextState.day !== this.state.day) {
            this.fetchEvents(nextState.day);
        }
    },

    handleDayChange: function (day) {
        console.log(day);
        this.setState({ day: day, loaded: false })
    },

    render: function () {
        if (!this.state.loaded) {
            return el('div', {}, 'loading...');
        }
        return (
            el('div', {},
//                el(DayNav, {days: ['today', 'tomorrow']})
                el('a', { onClick: this.handleDayChange.bind(this, 'today') }, 'Today'),
                el('a', { onClick: this.handleDayChange.bind(this, 'tomorrow') }, 'Tomorrow'),
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

