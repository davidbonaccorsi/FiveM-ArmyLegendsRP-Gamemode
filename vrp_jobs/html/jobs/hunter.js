
const hunterJob = new Vue({
    el: ".main-hunter",
    data: {
        active: false,
        zoom: 0,
        job: "",
    },
    mounted() {
        window.addEventListener("keydown", this.onKey)
        window.addEventListener("message", this.onMessage)
        window.addEventListener("resize", this.handleResize)
    },
    methods: {
        		
		onKey() {
			var theKey = event.code;

			if (theKey == "Escape" && this.active)
				this.destroy();
		},

        onMessage() {
            const data = event.data;

            if (data.job == "hunter")
                this.build(data);
        },

		async post(url, data = {}, res = GetParentResourceName()) {
			const response = await fetch(`https://${res}/${url}`, {
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
            this.job = data.group;
            var tog = false;

            this.post("setFocus", [true]);
            this.post("vrp:triggerEvent", ["vrp-hud:updateMap", tog], "vrp");
            this.post("vrp:triggerEvent", ["vrp-hud:setComponentDisplay", {
                serverHud: tog,
                minimapHud: tog,
                bottomRightHud: tog,
                chat: tog
            }], "vrp");

        },

        destroy() {
            this.active = false;
            var tog = true;

            this.post("setFocus", [false]);
            this.post("vrp:triggerEvent", ["vrp-hud:updateMap", tog], "vrp");
            this.post("vrp:triggerEvent", ["vrp-hud:setComponentDisplay", {
                serverHud: tog,
                minimapHud: tog,
                bottomRightHud: tog,
                chat: tog
            }], "vrp");

        },
    }
})
