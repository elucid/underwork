let Hooks = {};

Hooks.TimezoneOffset = {
  mounted() {
    this.pushEvent("timezone_offset", new Date().getTimezoneOffset());
  }
}

export default Hooks;