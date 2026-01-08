
const garages = new Vue({
    el: ".main-garages",
    data: {
        active: false,
        zoom: 0,
        tab: 1,
        search: "",
        gtype: "Public",
        vehicles: [
            {vehicle: "1310s", name: "Dacia 130S", premium: true},
            {vehicle: "evo9mr", name: "Mitsubishi Launcher Evo IX"},
        ],
        filtered: [],
        out: 0,
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
				this.destroy(false);
		},

        onMessage() {
            const data = event.data;

            if (data.interface == "garage")
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

        setTab(tab) {
            this.tab = tab;
        },

        isShown(veh) {
            if (this.tab == 2 && !veh.premium) return false;
            if (this.tab == 3 && !(veh.state == 2)) return false;

            return true;
        },

        refreshSearch(){
			this.filtered = Object.fromEntries((Object.entries(this.vehicles)).filter(([key, vehicle]) => {
				return vehicle.name.toLowerCase().includes(this.search.toLowerCase())
			}));
		},

        build(data) {

            this.vehicles = data.vehicles;
            this.filtered = this.vehicles;
            this.gtype = data.gtype;
            this.out = data.out;

            this.active = true;
        
            this.post("setFocus", [true]);
            
            this.post("vrp:triggerEvent", ["vrp-hud:updateMap", false]);
            this.post("vrp:triggerEvent", ["vrp-hud:setComponentDisplay", {"*": false}]);
        },

        spawn(model, vtype) {
            this.destroy();
			this.post("garages:spawn", [model, vtype, this.gtype]);
        },

        park() {
            this.destroy();
            this.post("garages:despawn", [this.gtype]);
        },

        destroy() {
            this.active = false;
            
            this.post("setFocus", [false]);
            
            this.post("vrp:triggerEvent", ["vrp-hud:updateMap", true]);
            this.post("vrp:triggerEvent", ["vrp-hud:setComponentDisplay", {"*": true}]);
        },
    }
})
