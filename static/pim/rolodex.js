use_tags(['div','row','textarea','input','a','h4','br','hr','button'])

var Rolodex = React.createClass({
    getInitialState: function() {
        return this.props.initial_state;
    },
    handleNew: function(e) {
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
        }).catch(logerr)
    },
    handleFilter: function(e) {
        var str = e.target.value;
        var that = this;
        console.log('searching for ' + str );
        post_json('/rolodex/search',{ q : str})
        .then(function(res) {
            if (res.ok) {
                return res.json();
            } else {
                console.log('error searching',res.status);
            }
        }).then(function(j) {
            console.log('got json ',j);
            that.setState({ cards: j.results });
        }).catch(logerr);

    },
    render: function() {
        var s = this.state;
        console.log('cards',s.cards);
        return div(
            h4( { className: 'text-center' }, 'Rolodex'),
            row(
                div( {className: 'small-3 columns' },
                    input({type:'text', placeholder:'filter',
                        autoFocus: true,
                        onChange: this.handleFilter,
                    }) )
            ),
            hr(),
            row( div( {className: 'small-3 columns'},
                    textarea( {
                        className: 'rolodex trimv',
                        value: s.new_txt,
                        rows: 4,
                        placeholder: 'New Person',
                        onChange: this.handleNew } ),
                    a( {
                        className: 'small expanded success button',
                        onClick: this.savenew,
                        }, 'save')
               ),
               s.cards.map(function(d){
                   return row( div( { className: 'small-3 columns callout secondary card' }, d.text ) )
               })
            )
        )
    }
});

