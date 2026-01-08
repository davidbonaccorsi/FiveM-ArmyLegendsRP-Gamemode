
const scoreboard = new Vue({
    el: ".main-scoreboard",
    data: {
        active: false,
        name: "",
        user_id: 0,
        faction: false,
        hoursPlayed: 0,
        sessionTime: "0 H. 0 M.",
        warns: 0,
        playerList: [],
        filter: [],
        search: "",
    },
    mounted() {
        window.addEventListener("keydown", this.onKey)
        window.addEventListener("message", this.onMessage)
    },
    methods: {
    
		onKey() {
			var theKey = event.code;

			if (theKey == "Escape" && this.active)
				this.destroy();
		},

        onMessage() {
            const data = event.data;

            if (data.interface == "scoreboard")
                this.build(data.data);
        },

		async post(url, data = {}) {
			const response = await fetch(`https://${GetParentResourceName()}/${url}`, {
			    method: 'POST',
			    headers: { 'Content-Type': 'application/json' },
			    body: JSON.stringify(data)
			});
			
			return await response.json();
		},
        
        build(data) {
            this.active = true;

            this.name = data.name,
            this.user_id = data.user_id,
            this.faction = data.faction,
            this.hoursPlayed = data.hoursPlayed,
            this.sessionTime = data.sessionTime,
            this.warns = data.warns,
            this.playerList = data.playerList;
            this.filter = this.playerList;

            this.post("vrp:triggerEvent", ["vrp-hud:updateMap", false]);
            this.post("vrp:triggerEvent", ["vrp-hud:setComponentDisplay", {
                serverHud: false,
                minimapHud: false,
                bottomRightHud: false,
                chat: false
            }]);
            this.post("setFocus", [true]);
            $(".main-scoreboard").fadeIn(1000);
        },

        refreshSearch(){
			this.filter = Object.fromEntries((Object.entries(this.playerList)).filter(([key, player]) => {
				return player.name.toLowerCase().includes(this.search.toLowerCase())
			}));
		},

        destroy() {
            this.active = false;
            this.post("vrp:triggerEvent", ["vrp-hud:updateMap", true]);
            this.post("vrp:triggerEvent", ["vrp-hud:setComponentDisplay", {
                serverHud: true,
                minimapHud: true,
                bottomRightHud: true,
                chat: true
            }]);
            $(".main-scoreboard").fadeOut(1000);
            this.post("setFocus", [false]);
        },
    },
})