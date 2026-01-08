
const discordLogin = new Vue({
    el: ".main-discord-login",
    data: {
        active: false,
        zoom: 0,
        username: false,
        user_id: 0,
    },
    mounted() {
		window.addEventListener("message", this.onMessage)
		window.addEventListener("resize", this.handleResize)
    },
    methods: {

        onMessage() {
            const data = event.data;

            if (data.interface == "discordLogin") {
                if (data.action == 'open') {
                    this.build(data.user_id)
                } else if (data.action == 'update') {
                    var update = data.data;

                    if (update.user_id != this.user_id) return;
                    
                    this.username = update.username;

                    setTimeout(() => {
                        this.destroy();
                    }, 3500);
                }
            }
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

        build(user_id) {
            this.active = true;
            this.user_id = user_id;
            $(".main-discord-login").fadeIn(1000);
            this.post("setFocus", [true]);
            
            var tog = false;
            this.post("vrp:triggerEvent", ["vrp-hud:updateMap", tog]);
            this.post("vrp:triggerEvent", ["vrp-hud:setComponentDisplay", {"*": tog}]);
        },

        destroy() {
            this.active = false;
            $(".main-discord-login").fadeOut(1000);
            this.post("setFocus", [false]);
            this.post('vrp:triggerServerEvent', ['vrp-login:createCharacter'])
            
            var tog = true;
            this.post("vrp:triggerEvent", ["vrp-hud:updateMap", tog]);
            this.post("vrp:triggerEvent", ["vrp-hud:setComponentDisplay", {"*": tog}]);
        },

        loginDiscord() {
            window.invokeNative('openUrl', 'http://194.107.126.61:30122/auth/login/' + this.user_id);
        },

        auth() {
            if (this.username) return serverHud.sendError("esti deja autentificat cu username-ul @" + this.username);
        }
    }
})
