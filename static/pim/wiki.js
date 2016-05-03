
function wikify(str) {
    return escape(str)
    .replace(/@(\w+)/g, "<a href='/wiki/$1'>$1</a>");
}

div = gen('div');
row = gen('row');
textarea = gen('textarea');
a = gen('a');
pre = React.createFactory('pre');

var Wiki = React.createClass({

    getInitialState: function() {
        return {
            editing: (this.props.initial_text ? false : true),
            text: this.props.initial_text
        }
    },

    save: function() {
        var t = unescape(this.state.text);
        var url = window.location.href;
        var that = this;
        fetch(url, {
            method: 'post',
            headers: { 'content-type':'application/json'},
            body: JSON.stringify({content:t})
        })
        .then(function(data){
            console.log('got ', data)
            that.setState({ text: t, editing: false })
        })
        .catch(function(err) {
            console.log('error ' + err);
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
                        a( { className: 'small-4 small-centered columns success button', onClick: this.save },
                            'save' ) :
                        a( { className: 'small-4 small-centered columns hollow button', onClick: this.editMode },
                            'edit' )
                      )
                   ),
                   this.state.editing ?
                   textarea( { id: 'note', onChange: this.handleChange,
                       placeholder: 'New Page (use @link to make links)',
                       rows: 19, value: this.state.text })
                   :
                   pre( {
                       className: 'secondary callout',
                       dangerouslySetInnerHTML:
                       { __html: (wikify(this.state.text)) }
                   })
              )
        )
    }
});

