let Hooks = {};

// HT to https://fly.io/phoenix-files/dates-formatting-with-hooks/
Hooks.LocalTime = {
  mounted(){
    this.updated()
  },

  updated() {
    let dt = new Date(this.el.textContent.trim());
    this.el.textContent =
      dt.toLocaleTimeString('en-US', { hour: '2-digit', minute: '2-digit', hour12: true }).replace(/^0+/, '');
  }
}

Hooks.PlayAudio = {
  mounted() {
    let audio = new Audio(this.el.dataset.audioSrc);
    audio.play();
  }
}

export default Hooks;