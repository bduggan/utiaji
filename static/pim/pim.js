var el = React.createElement;

var Wiki = React.createClass({

    getInitialState: function() {
        return {
            editing: 0,
            text: this.props.initial_text
        }
    },

    save: function() {
        var t = this.state.text;
        console.log('saving ' + t);
        var url = window.location.href;
        console.log('to ' + url);
        fetch(url, {
            method: 'post',
            headers: { 'content-type':'application/json'},
            body: JSON.stringify({content:t})
        })
        .then(function(data){
            console.log('got ', data)
        })
        .catch(function(err) {
            console.log('error ' + err);
        })
    },

    handleChange: function(e) {
        this.setState({ text: e.target.value } );
    },

    render: function () {
        return (
            el('div', {},
                el('row', {},
                    el('div', { className: 'text-right' },
                        el('a', { className: 'button', onClick: this.save },'save' )
                      )
                   ),
                   el('textarea', { id: 'note', onChange: this.handleChange,
                       placeholder: 'New Page', rows: 19, value: this.state.text })
              )
        )
    }
});

