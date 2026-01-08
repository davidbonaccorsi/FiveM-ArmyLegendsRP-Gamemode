const policeWarrants = new Vue({
    el: ".warrants-layout",
    data: {
        active: false,
        index: 1,
        maxIndex: 0,
        price: 0,
        warrants: [{description: "", id: 0}],
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
		
			if (data.interface == "policeWarrants")
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

        truncate(text, max) {
            return text.substr(0,max-1)+(text.length>max?'...':''); 
        },

        moveIndex(up) {
            if (up) {
                if ((this.index + 1) <= this.maxIndex) this.index++;
            } else {
                if ((this.index - 1) > 0) this.index--;
            }
        },

        pay() {
            this.post("vrp:triggerServerEvent", ["police:clearWarrants", this.maxIndex]);
            this.destroy();
        },

        build(data) {
            this.active = true;

            this.maxIndex = data.total;
            this.warrants = data.warrants;
            this.price = 50000 * data.total;

            $(".warrants-layout").fadeIn();
            this.post("setFocus", [true]);

            var tog = false;
            this.post("vrp:triggerEvent", ["vrp-hud:updateMap", tog]);
            this.post("vrp:triggerEvent", ["vrp-hud:setComponentDisplay", {"*": tog}]);
        },

        destroy() {
            this.active = false;
            $(".warrants-layout").fadeOut();
            this.post("setFocus", [false]);
            
            var tog = true;
            this.post("vrp:triggerEvent", ["vrp-hud:updateMap", tog]);
            this.post("vrp:triggerEvent", ["vrp-hud:setComponentDisplay", {"*": tog}]);
        },

    },
})