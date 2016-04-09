var el = React.createElement;

var Wiki = React.createClass({
    getInitialState: function() {
        return {
            editing: 0,
        }
    },

    save: function() {
        var t = $("#note").val()
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

    render: function () {
        return (
            el('div', {},
                el('row', {},
                    el('div', { className: 'text-right' },
                        el('a', { className: 'button', onClick: this.save.bind(this) },'save' )
                      )
                   ),
                el('textarea', { id: 'note', placeholder: 'New Page', rows: 19})
              )
        )
    }
});

