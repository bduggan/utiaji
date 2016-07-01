use_tags(['div','row','textarea','input','a','h4','br','hr','button'])

var Rolodex = React.createClass({
    getInitialState: function() {
        var s = this.props.initial_state;
        // state:
        //   editing: handle of contact being edited
        //   new_txt: new text to save
        //   cards : array of cards being displayed
        //   filter: current filter
        s.editing = '';
        s.new_txt = '';
        s.filter = '';
        return s;
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
                that.setState({new_txt: ""});
                return res.json();
            } else {
                console.log('error',res.status,res.statusText,res);
            }
        }).then(function(j) {
            var cards = that.state.cards;
            cards.unshift(j['card']);
            that.setState({cards: cards});
        }).catch(logerr)
    },
    handleFilter: function(e) {
        var str = e.target.value;
        var that = this;
        post_json('/rolodex/search',{ q : str})
        .then(function(res) {
            if (res.ok) {
                return res.json();
            } else {
                console.log('error searching',res.status);
            }
        }).then(function(j) {
            that.setState({ cards: j.results, filter: str });
        }).catch(logerr);

    },
    editCard: function(handle) {
        var that = this;
        return function(e) {
            that.setState({ editing: handle });
        }
    },
    render: function() {
        var s = this.state;
        var that = this;
        return div(
            h4( { className: 'text-center' }, 'Rolodex'),
            row(
                div( {className: 'small-3 columns' },
                    input({type:'text', placeholder:'filter',
                        autoFocus: true,
                        value: s.filter,
                        onChange: this.handleFilter,
                    }) )
            ),
            hr(),
            row( div( {className: 'small-2 columns callout card'},
                    textarea( {
                        className: 'rolodex trimv',
                        value: s.new_txt,
                        placeholder: 'New Person',
                        onChange: this.handleNew } ),
                    a( {
                        className: 'small expanded button squishv',
                        onClick: this.savenew,
                        }, 'save')
               ),
               s.cards.map(function(d){
                   return row(
                       s.editing == d.handle
                       ? div( { className: 'small-2 columns callout secondary card' },
                           textarea({className: 'rolodexedit trimv', value: d.text } ) )
                       : div( { className: 'small-2 columns callout secondary card',
                           onClick: that.editCard(d.handle) }, d.text )

                   )
               })
            )
        )
    }
});

