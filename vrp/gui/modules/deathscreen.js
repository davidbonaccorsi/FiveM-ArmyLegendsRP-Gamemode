const deathScreen = new Vue({
	el: ".main-deathscreen",
	data: {
		active: false,
		zoom: 0,
		respawnTime: [],
		sound: false,
	},
	mounted() {
		window.addEventListener("message", this.onMessage)
		window.addEventListener("resize", this.handleResize)
	},
	methods: {

		async post(url, data = {}) {
			const response = await fetch(`https://${GetParentResourceName()}/${url}`, {
			    method: 'POST',
			    headers: { 'Content-Type': 'application/json' },
			    body: JSON.stringify(data)
			});
			
			return await response.json();
		},
        
        onMessage() {
            const data = event.data;

            if (data.interface == "deathscreen") {
				if (data.event == "show") {
                	this.build();
				} else if (data.event == "setTime") {
					this.respawnTime = data.time;
				} else if (data.event == "hide") {
					this.destroy();
				}
			}
        },

        handleResize() {
            var zoomCountOne = $(window).width() / 1920;
            var zoomCountTwo = $(window).height() / 1080;

            if (zoomCountOne < zoomCountTwo) this.zoom = zoomCountOne;else this.zoom = zoomCountTwo;
        },


		build() {
			this.active = true;

			var audio = new Audio("../public/sounds/heartbeat.mp3");
			audio.volume = 0.5;
			audio.play();

			this.sound = audio;

		},
		
		destroy() {
			if (this.sound) this.sound.pause();

			this.active = false;
		},
	}
})