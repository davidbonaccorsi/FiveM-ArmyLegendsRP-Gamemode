const factionStorage = new Vue({
    el: ".main-factionstorage",
    data: {
        active: false,
		faction: "Smurd",
		zoom: 0,
		items: [],
    },
    mounted() {
        window.addEventListener("keydown", this.onKey)
        window.addEventListener("resize", this.handleResize)
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

            if (data.interface == "factionStorage") {
                this.build(data.faction);
			} else if (data.interface == "populateFactionStorage") {
				this.items = data.cfg;
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
        
        getCorrectImage(itemid) {
    
            if (itemid.toLowerCase().startsWith("wbody")) {
                return "wbody";
            } else if (itemid.toLowerCase().startsWith("wammo")) {
                return "wammo";
            }
            
            return itemid;
        },

        
        build(faction) {
            this.active = true;
            this.faction = faction;
            
            this.post("setFocus", [true]);
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
            this.post("setFocus", [false]);
        }

    }
})