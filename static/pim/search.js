use_tags(['input','div','ul','li','a']);
var timeout;
var Search = React.createClass({
    getInitialState: function() {
        var state = {
            query: "",
            search_cache : {},
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
        this.setState({ txt: "", results : [], query: "" });
    },
    cached: function(v) {
        return this.state.search_cache[v];
    },
    add_to_cache: function(k,v) {
        var cache = this.state.search_cache;
        cache[k] = v;
        this.setState({ search_cache : cache });
    },
    handleChange: function(e) {
        var query = e.target.value;
        if (!query.length) {
            return this.clear();
        }
        this.setState({txt:query});
        if (c = this.cached(query)) {
            this.setState({ query: query, results: c });
            return;
        }
        var that = this;
        if (timeout) {
            clearTimeout(timeout);
        }
        timeout = setTimeout(function() {
            fetch( '/search', {
                method: 'POST',
                headers: { 'Content-Type' : 'application/json' },
                body: JSON.stringify({txt: query})
            }).then(function(response){
                return response.json();
            }).then(function(results) {
                that.add_to_cache(query,results);
                that.setState({ query: query, results: results })
            })
        },250);
    },
    render: function() {
        var s = this.state;
        var query;
        var results;
        if (c = this.cached(s.txt)) {
            query = s.txt;
            results = c;
        } else {
            query = s.query;
            results = s.results;
        }
        return div( { className:'searchbox' },
            input( { className: 'search',
                type: 'text',
                value: s.txt,
                placeholder: 'search',
                autocomplete: 'off',
                onKeyDown: this.handleKeys,
                onChange: this.handleChange } ),
            (query.length==0 ? undefined :
            div({className: 'searchresults'},
                ul({className:'menu vertical'},
                    li({className:'query'},query),
                    ...results.map( function(v) {
                        return li(a({href: v['href']},v['label']))
                    })
                )
            ))
        )
    }
});
