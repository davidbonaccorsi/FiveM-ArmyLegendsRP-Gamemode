const achievements = new Vue({
    el: ".main-achievements",
    data: {
        active: false,
        zoom: 0,
        username: "",
        achievements: [],
        userAchievements: [],
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

            if (data.interface == "achievements")
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
            this.username = data.username;
            this.achievements = data.achievements || [];
            this.userAchievements = data.userAchievements || [];

            this.post("setFocus", [true]);
        },

        formatString: function(str, ...args) {
            return str.replace(/{(\d+)}/g, (match, index) => args[index] || "");
        },

        getShownAchievements() {
            return Object.keys(this.achievements).length;
        },

        destroy() {
            this.active = false;
            this.post("setFocus", [false]);
            this.post("vrp:triggerEvent", ["vrp-hud:updateMap", true]);
            this.post("vrp:triggerEvent", ["vrp-hud:setComponentDisplay", {"*": true}]);
        }
    }
})