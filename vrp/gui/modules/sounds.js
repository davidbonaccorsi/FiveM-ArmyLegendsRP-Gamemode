let soundManager = {
  handler: false,
  
  stop() {
    if (!this.handler) return false;

    this.handler.pause();
  },

  play(sound_id, volume) {
    this.stop();
  
    this.handler = new Audio(`sounds/${sound_id}.mp3`);
    this.handler.volume = volume || 0.5;
    this.handler.play();
  },
};