use_tags(['div'])

function Autosaver(d) {
  function is_modified() {
      return this.state.version > this.state.last_save
  }
  d.is_modified = is_modified;

  function touch() {
      this.setState({ last_touch: new Date().getTime() });
  }
  d.touch = touch;

  function elapsed(t) {
        var e = new Date().getTime() - this.state.last_touch;
        return e > t;
  }
  d.elapsed = elapsed;

  function init(s) {
    s['last_touch'] = new Date().getTime();
    s['version'] = 1;
    s['last_save'] = 1;
    return s;
  }
  d.init = init;

  function status_indicator() {
    return div( { className: 'status-indicator ' + (this.is_modified() ? 'changed' : 'saved') } );
  }
  d.status_indicator = status_indicator;

  function componentDidMount() {
        setInterval(this.maybeSave,1000)
  }
  d.componentDidMount = componentDidMount;

  return d;
}
