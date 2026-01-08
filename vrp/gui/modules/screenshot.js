
const adminScreenshot = new Vue({
    el: ".main-screenshot",
    data: {
        active: false,
        zoom: 0,
        name: "",
        image: "",
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

            if (data.interface == "screenshot")
                this.build(data);
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
            this.image = data.image;
            this.name = data.name;

            $(".main-screenshot").fadeIn(1000);
            this.post("setFocus", [true]);
        },

        destroy() {
            this.active = false;

            $(".main-screenshot").fadeOut(1000);
            this.post("setFocus", [false]);
        }

    }
})
