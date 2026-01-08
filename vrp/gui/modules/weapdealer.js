const weapDealer = new Vue({
    el: ".main-weapdealer",
    data: {
        active: false,
        zoom: 0,
        weapons: [],
        name: "",
        balance: 0,
        closetime: false,
        faction: "",
    },
    mounted() {
        window.addEventListener("keydown", this.onKey);
        window.addEventListener("message", this.onMessage)
        window.addEventListener("resize", this.handleResize);
    },
    methods: {
		
		onKey() {
			var theKey = event.code;

			if (theKey == "Escape" && this.active)
				this.destroy();
		},

        onMessage() {
            const data = event.data;

            if (data.interface == "weapDealer") {
                if (data.event == "build") {
                    this.build(data);
                } else if (data.event == "setWeapons") {
                    this.weapons = data.weapons;
                    for (const item of this.weapons) {
                        item.amount = 1;
                    }
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

        build(data) {
            this.name = data.name;
            this.faction = data.faction;
            this.balance = data.money;
            if (this.closetime) clearTimeout(this.closetime);
            this.active = 1;
            $(".main-weapdealer").fadeIn(1000);
            this.post("setFocus", [true]);
        },

        buy(item) {
            this.post("vrp:triggerServerEvent", ["vrp-weapdealer:tryBuy", item, this.active]);
        },

        destroy() {
            $(".main-weapdealer").fadeOut(1000);
            this.closetime = setTimeout(() => {
                this.active = false;
                this.closetime = false;
            }, 1000)
            this.post("setFocus", [false]);
        }
    }
})