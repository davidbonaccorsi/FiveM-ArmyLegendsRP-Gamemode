const lifeInvader = new Vue({
    el: ".main-lifeinvader",
    data: {
        active: false,
        zoom: 0,
        phone: "",
        name: "",
        msg: "",
    },
    mounted() {
        window.addEventListener("keydown", this.onKey)
        window.addEventListener("message", this.onMessage)
        window.addEventListener("resize", this.handleResize)

        $('#lifeinvader-textarea').on('input', function() {
            this.style.height = 'auto';
            this.style.height = this.scrollHeight + 'px';
        });
    },
    methods: {

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
        
        onMessage() {
            const data = event.data;

            if (data.interface == "lifeInvader")
                this.build(data.data);
        },

        handleResize() {
            var zoomCountOne = $(window).width() / 1920;
            var zoomCountTwo = $(window).height() / 1080;

            if (zoomCountOne < zoomCountTwo) this.zoom = zoomCountOne;else this.zoom = zoomCountTwo;
        },

        truncateText(text, max) {
            return text.substr(0,max-1)+(text.length>max?'...':''); 
        },


        build(data) {
            this.active = true;
            this.phone = data.phone;
            this.name = this.truncateText(data.name, 20);
        },

        add() {
            if (this.msg.trim().length < 2)
                return false;

            this.post("addAnnouncement", [this.msg]);
            this.destroy();
        },

        destroy() {
            this.active = false;
            this.msg = "";

            this.post("setFocus", [false]);
        },
    },
})
