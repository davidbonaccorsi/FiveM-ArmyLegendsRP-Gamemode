
const adminMsg = new Vue({
	el: ".admin-announce",
	data: {
		announce: false,
		zoom: 0,
	},
	mounted() {
		window.addEventListener("message", this.onMessage)
		window.addEventListener("resize", this.handleResize)
	},
	methods: {
		onMessage: function() {
			const data = event.data;
		
			if (data.interface == "adminMsg") {
				this.showAnnounce(data.text, data.name)
			}
		},

		showAnnounce: function(text = '', admin = 'Necunoscut') {
            this.announce = {
                text,
                admin
            }
    
            setTimeout(function() {
                adminMsg.announce = false;
            }, 1000 * 10)
        },
		        
        handleResize() {
            var zoomCountOne = $(window).width() / 1920;
            var zoomCountTwo = $(window).height() / 1080;

            if (zoomCountOne < zoomCountTwo) this.zoom = zoomCountOne;else this.zoom = zoomCountTwo;
        },
	}
})
