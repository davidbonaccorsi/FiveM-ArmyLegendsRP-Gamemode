const investment = new Vue({
	el: ".main-investments",
    data: {
        active: false,
        zoom: 0,
        cooldown: false,
        remaining: false,
        progress: 0,
    },
	mounted() {
		window.addEventListener("keydown", this.onKey)
        window.addEventListener("message", this.onMessage)
        window.addEventListener("resize", this.handleResize)
	},
	methods: {

        onMessage() {
            const data = event.data;

            if (data.interface == "investment")
                this.build(data);
        },

		onKey() {
			var theKey = event.code;

			if (theKey == "Escape" && this.active)
				this.destroy();
		},

		async post(url, data = {}) {
			const response = await fetch(`https://${GetParentResourceName()}/${url}`, {
			    method: 'POST',
			    headers: { 'Content-Type': 'application/json' },
			    body: JSON.stringify(data)
			});
			
			return await response.json();
		},

        handleResize() {
            var zoomCountOne = $(window).width() / 1920;
            var zoomCountTwo = $(window).height() / 1080;

            if (zoomCountOne < zoomCountTwo) this.zoom = zoomCountOne;else this.zoom = zoomCountTwo;
        },

		build(data) {
            this.active = true;
            this.cooldown = data.cooldown;
            this.remaining = data.remaining;
            this.progress = data.progress;
            this.post("setFocus", [true]);
		},

        start(investment) {
            this.post("vrp:triggerServerEvent", ["vrp-investments:start", investment]);
            this.destroy();
        },

		destroy() {
			this.active = false;
            this.post("setFocus", [false]);
            this.post("vrp:triggerEvent", ["vrp-hud:updateMap", true]);
            this.post("vrp:triggerEvent", ["vrp-hud:setComponentDisplay", {"*": true}]);
        },

	},
})