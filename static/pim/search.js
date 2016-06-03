use_tags(['input','div','ul','li','a']);
var search_cache = {};
var Search = React.createClass({
    getInitialState: function() {
        var state = {
            query: "",
            results: [ ]
                //{ href: '/cal/x', label: 'one' },
                //{ href: '/wiki/', label: 'two' },
                //{ href: '/people/z', label: 'three' }
        };
        return state;
    },
    handleKeys: function(e) {
        if (e.keyCode == 27) {
            this.clear();
        }
    },
    clear: function() {
        this.setState({ results : [], query: "" });
    },
    handleChange: function(e) {
        var query = e.target.value;
        if (!query.length) {
            return this.clear();
        }
        if (search_cache[query]) {
            this.setState({ query: query, results: search_cache[query] });
            return;
        }
        var that = this;
        fetch( '/search', {
            method: 'POST',
            headers: { 'Content-Type' : 'application/json' },
            body: JSON.stringify({txt: query})
        }).then(function(response){
            return response.json();
        }).then(function(results) {
            search_cache[query] = results;
            that.setState({ query: query, results: results })
        })
    },
    render: function() {
        var s = this.state;
        return div( { className:'searchbox' },
            input( { className: 'search',
                type: 'text',
                value: s.txt,
                placeholder: 'search',
                autocomplete: 'off',
                onKeyDown: this.handleKeys,
                onChange: this.handleChange } ),
            (s.results.length==0 ? undefined :
            div({className: 'searchresults'},
                ul({className:'menu vertical'},
                    li({className:'query'},s.query),
                    ...s.results.map( function(v) {
                        return li(a({href: v['href']},v['label']))
                    })
                )
            ))
        )
    }
});
