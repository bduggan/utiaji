use_tags(['div','row','textarea','a','pre'])

/* Wiki */
var Wiki = React.createClass({

    getInitialState: function() {
        var text = this.props.initial_state.text;
        var dates = this.props.initial_state.dates;
        return {
            editing: (text ? false : true),
            text: text,
            dates: dates
        }
    },

    save: function() {
        var t = unescape(this.state.text);
        var url = window.location.href;
        var that = this;
        fetch(url, {
            method: 'POST',
            headers: { 'Content-Type':'application/json'},
            body: JSON.stringify({txt:t})
        })
        .then(function(data){
            console.log('got ', data);
            that.setState({ text: t, editing: false })
        })
        .catch(function(err) {
            console.log('error ' ,err);
        })
    },

    handleChange: function(e) {
        this.setState({ text: e.target.value } );
    },

    editMode: function(e) {
        this.setState({ text: this.state.text, editing: true } );
    },
    render: function () {
        return (
            div( {},
                row( {},
                    div( { className: 'text-right' },
                        this.state.editing ?
                        a( { className: 'small-4 small-centered columns success button',
                             onClick: this.save },
                            'save' ) :
                        a( { className: 'small-4 small-centered columns hollow button',
                             onClick: this.editMode },
                            'edit' )
                      )
                   ),
                   div( {className: 'datelist'},
                       this.state.dates.map( function(v) {
                           return a({className:'small hollow button', href:'/cal/' + v},v)
                       } )
                   ),
                   this.state.editing ?
                   textarea( { id: 'note', onChange: this.handleChange,
                       placeholder: 'New Page (use @link to make links)',
                       rows: 19, value: this.state.text })
                   :
                   pre({
                       className: 'secondary callout',
                       html: wikify(this.state.text)
                   })
              )
        )
    }
});

