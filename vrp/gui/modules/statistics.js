const statistics = new Vue({
    el: ".main-statistics",
    data: {
        active: false,
        zoom: 0,

        id: 0,
        playtime: "",
        username: "",
        vehicles: [], //[model] = name
        level: 0,
        hours: 0,
        weekHours: 0,
        warns: 0,
        bans: 0,
        investments: 0,
        houses: 0,
        markets: 0,
        prime: false,
        doubleXp: false,
        top: [],
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

            if (data.interface == "statistics")
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

        handleResize() {
            var zoomCountOne = $(window).width() / 1920;
            var zoomCountTwo = $(window).height() / 1080;

            if (zoomCountOne < zoomCountTwo) this.zoom = zoomCountOne;else this.zoom = zoomCountTwo;
        },
    
        
        build(data) {
            this.active = true;

            this.id = data.id;
            this.playtime = data.playtime;
            this.username = data.username;
            this.vehicles = data.vehicles;
            this.level = data.level,
            this.hours = data.hours,
            this.weekHours = data.weekHours,
            this.prime = data.prime;
            this.doubleXp = data.doubleXp;
            this.markets = data.markets;
            this.houses = data.houses;
            this.investments = data.investments;
            this.top = data.top;
            
            this.post("setFocus", [true]);
            
            this.post("vrp:triggerEvent", ["vrp-hud:updateMap", false]);
            this.post("vrp:triggerEvent", ["vrp-hud:setComponentDisplay", {"*": false}]);
        },

        truncateText(text, max) {
            return text.substr(0,max-1)+(text.length>max?'...':''); 
        },

        countVehicles() {
            var count = 0;
            for (const model in this.vehicles) {
                count++;
            }
            return count;
        },

        destroy() {
            this.active = false;
            this.post("setFocus", [false]);
            
            this.post("vrp:triggerEvent", ["vrp-hud:updateMap", true]);
            this.post("vrp:triggerEvent", ["vrp-hud:setComponentDisplay", {"*": true}]);
        }
    }
})
