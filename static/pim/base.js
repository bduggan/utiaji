use_tags(['div'])

function Autosaver(child) {
  var d = {};
  d.init = function(s) {
    s['last_touch'] = new Date().getTime();
    s['version'] = 1;
    s['last_save'] = 1;
    s['autoview'] = true;
    return s;
  };


  d.is_modified = function() {
      return this.state.version > this.state.last_save
  };

  d.touch = function() {
      this.setState({ last_touch: new Date().getTime() });
  };

  d.elapsed = function(t) {
        var e = new Date().getTime() - this.state.last_touch;
        return e > t;
  };

  d.status_indicator = function() {
    return div( { className: 'status-indicator ' + (this.is_modified() ? 'changed' : 'saved') } );
  };

  d.componentDidMount = function() {
        setInterval(this.maybeSave,1000)
  };

  d.stopEdit = function() {
        this.setState({editing:undefined});
  };

  d.maybeSave = function() {
        if (this.is_modified()) {
            this.save();
            return;
        }
        if (this.state.editing && this.elapsed(3000) && this.state.autoview) {
            console.log('stopping edit');
            this.stopEdit();
            this.reload();
        }
        return;
  };

  d.reload = function() {};

  for (var k in d) {
      if (!child[k]) {
        child[k] = d[k]
    }
  }
  return child;
}
