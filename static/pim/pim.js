
function escape(str) {
  return str.replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;')
    .replace(/'/g, '&apos;')
}
function unescape(str) {
    return str.replace('&amp;', '&', 'g')
    .replace('&lt;','<','g')
    .replace('&gt;','>','g')
    .replace('&quot;', '"', 'g')
    .replace('&apos;', "'", 'g')
}

function wikify(str) {
    return escape(str)
    .replace(/@(\w+)/g, "<a href='/wiki/$1'>$1</a>");
}

var el = React.createElement;
var div = React.createElement.bind(this, 'div');
var row = React.createElement.bind(this, 'row');
var textarea = React.createElement.bind(this, 'textarea');
var pre = React.createElement.bind(this, 'pre');
var a = React.createElement.bind(this, 'a');

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
                        a( { className: 'small-4 small-centered columns success button', onClick: this.save },'save' ) :
                        a( { className: 'small-4 small-centered columns hollow button', onClick: this.editMode },'edit' )
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

