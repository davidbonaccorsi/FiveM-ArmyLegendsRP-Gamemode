const dealership = new Vue({
	el: ".main-dealership",
	data: {
		active: false,
		zoom: 0,
		money: "",
		name: "",
		color: 2,
		trunk: 30,
		stock: 0,
		search: "",
		vehicle: 0,
		category: 0,
		categories: [
			["class_super", "Super"], ["class_highend", "Highend"], ["class_midrange", "Mid Range"], ["class_lowend", "Lowend"], ["cayo", "Cayo Perico"],
			["lowriders", "Lowridere"], ["wanted", "Wanted"], ["class_retro", "Retro"],
			["dube", "Dube"], ["camioane", "Camioane"], ["remorci", "Trailere"],
			["motoare", "Motociclete"],
			["avioane", "Avioane"], ["elicoptere", "Elicoptere"],
			["barci", "Barci"],
		],
		totalVehicles: 0,
		options: {price: 0, name: "", model: "", speed: 4, to100: 0},
		vehicles: {},
		filter: {},
	},
	mounted() {
		window.addEventListener("keydown", this.onKey)
		window.addEventListener("message", this.onMessage)
        window.addEventListener("resize", this.handleResize)

		this.filter = this.vehicles;

        var rotatingDown = false;
        $(document).on("mousedown", (e) => {
            if (!this.active || rotatingDown || (e.button != 0)) return;

            rotatingDown = true;
            this.post("dealership:rotateDown");
		});


        $(document).on("mouseup", (e) => {
            if (!this.active || !rotatingDown || (e.button != 0)) return;

            rotatingDown = false;
            this.post("dealership:rotateUp");
		});

	},
	methods: {
		
		onKey() {
			var theKey = event.code;

			if (theKey == "Escape" && this.active)
				this.destroy();
		},

        onMessage() {
            const data = event.data;

            if (data.interface == "dealership")
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
			this.color = 2;
			this.category = 0;
			this.money = data.money;
			this.name = data.name;

			this.fetchVehicles();
		},

		setColor(color) {
			this.color = color;
			this.post("dealership:setColor", [this.color]);
		},

		testDrive() {
			var model = this.options.model;
			var categ = this.categories[this.category][0];

			this.destroy();
			this.post("dealership:testDrive", [model, categ]);
		},

		buy() {
			var model = this.options.model;
			var categ = this.categories[this.category][0];

			this.destroy();
			this.post("dealership:buy", [model, categ]);
		},

		async moveCategoryIndex(up) {
			let spawning = await this.post("dealership:isSpawning");
			if (spawning) return false;

			if (up) {
				if ((this.category + 1) <= 12)
					this.category++;
			} else {
				if ((this.category - 1) > -1)
					this.category--;
			}

			this.fetchVehicles();
		},

		async moveVehicleIndex(up) {
			let spawning = await this.post("dealership:isSpawning");
			if (spawning) return false;

			if (up) {
				if ((this.vehicle + 1) <= this.totalVehicles) {
					this.vehicle++;
				} else {
					this.vehicle = 0;
				}

				this.spawnVehicle(this.getVehicleByIndex(this.vehicle));
			} else {
				if ((this.vehicle - 1) > -1) {
					this.vehicle--;
				} else {
					this.vehicle = this.totalVehicles;
				}

				this.spawnVehicle(this.getVehicleByIndex(this.vehicle));
			}
		},

		getVehicleIndex() {
			var indx = -1;

			for (const key in this.vehicles){
				indx++;
				
				if (key == this.options.model) break;
			}

			return indx;
		},

		getVehicleByIndex(index) {
			var indx = -1;

			for (const key in this.vehicles){
				indx++;
				
				if (indx == index) return key;
			}
		},

		async fetchVehicles() {
			let vehicles = await this.post("dealership:getVehiclesList", [ this.categories[this.category][0] ]);
			
			this.vehicles = vehicles;
			this.filter = vehicles;

			var totalIndx = -1;
			for (const key in vehicles){
				totalIndx++;
			}

			this.totalVehicles = totalIndx;

			var foundOne = false;
			for (const key in vehicles){
				foundOne = key;
				break
			}

			this.spawnVehicle(foundOne);

		},

		async spawnVehicle(model) {
			let entity = await this.post("dealership:spawn", [model, this.categories[this.category][0]]);
			if (!entity) return false;

			var vehicle = this.vehicles[model];

			if (vehicle){
				this.options = {
					price: vehicle.price,
					name: vehicle.name,
					model: model,
					speed: entity.speed,
					// to100: vehicle.to100,
				};

				this.trunk = entity.trunk;
				this.stock = entity.stock;

				this.vehicle = this.getVehicleIndex();
			}
		},

		refreshSearch(){
			this.filter = Object.fromEntries((Object.entries(this.vehicles)).filter(([key, vehicle]) => {
				return vehicle.name.toLowerCase().includes(this.search.toLowerCase())
			}));
		},

		destroy() {
			this.active = false;
			this.post("dealership:exit");
		},

	},
})

const testDrive = new Vue({
	el: ".main-testdrive",
	data: {
		zoom: 0,
		seconds: 0,
		model: "",
		interval: false,
	},
	mounted() {
		window.addEventListener("message", this.onMessage)
		window.addEventListener("resize", this.handleResize)
	},
	methods: {

		onMessage() {
			const data = event.data;

			if (data.interface == "testdrive"){

				if (data.event == "show") {
					this.build(data.model);
				} else if (data.event == "hide") {
					this.destroy();
				}

			}
		},

        handleResize() {
            var zoomCountOne = $(window).width() / 1920;
            var zoomCountTwo = $(window).height() / 1080;

            if (zoomCountOne < zoomCountTwo) this.zoom = zoomCountOne;else this.zoom = zoomCountTwo;
        },

		build(model) {

			if (this.interval){
				clearInterval(this.interval);
				this.interval = false;
			}

			$(".main-testdrive").fadeIn(1000);
			this.seconds = 60;
			this.model = model;
			
			this.interval = setInterval(() => {
				this.seconds--;
			}, 1000);

			setTimeout(() => {
				this.destroy();
				clearInterval(this.interval);
				this.interval = false;
			}, 60000);
		},

		destroy() {
			$(".main-testdrive").fadeOut(1000, () => {
				this.seconds = 0;
				this.model = "";
			});

			if (this.interval) {
				clearInterval(this.interval);
				this.interval = false;
			}
		},
	},
})
