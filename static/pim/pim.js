var el = React.createElement;

var Wiki = React.createClass({

    getInitialState: function() {
        return {
            editing: (this.props.initial_text ? false : true),
            text: this.props.initial_text
        }
    },

    save: function() {
        var t = this.state.text;
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
            el('div', {},
                el('row', {},
                    el('div', { className: 'text-right' },
                        this.state.editing ?
                        el('a', { className: 'button', onClick: this.save },'save' ) :
                        el('a', { className: 'button', onClick: this.editMode },'edit' )
                      )
                   ),
                   this.state.editing ?
                   el('textarea', { id: 'note', onChange: this.handleChange,
                       placeholder: 'New Page', rows: 19, value: this.state.text })
                   :
                   el('pre', {}, this.state.text)
              )
        )
    }
});

