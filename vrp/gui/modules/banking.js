const Banking = new Vue({
	el: ".bank-layout",
	data: {
		active: false,
		type: "atm",
		balance: 0,
		cash: 0,
		faction: false,
		name: "unknown",
		iban: 0,
		location: "",
		notification: "",
		notificationTimer: false,
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
		
			if (data.interface == "bank") {
				if (data.act == "build") {
					this.build(data.data);
				} else if (data.act == "update") {
					this[data.key] = data.value;
				} else if (data.act == "notification") {
					// this.notify(data.text);
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

		build(data) {
			this.active = true;

			this.type = data.machine;
			this.balance = data.balance;
			this.cash = data.cash;
			this.faction = data.faction;
			this.name = data.name;
			this.iban = data.iban;
			this.location = data.location;
			
			this.post("frontendSound", {dict: "ATM_WINDOW", sound: "HUD_FRONTEND_DEFAULT_SOUNDSET"});

			this.post("vrp:triggerEvent", ["vrp-hud:updateMap", false]);
            this.post("vrp:triggerEvent", ["vrp-hud:setComponentDisplay", {"*": false}]);
		},

		notify(text) {
			if (this.notificationTimer){
				clearTimeout(this.notificationTimer);
				$(".bank-notification").addClass("hidden");
			}

			var sound = new Audio("sounds/prompt_request.mp3");
			sound.volume = 0.4;
			sound.play();

			this.notification = text;
			$(".bank-notification").removeClass("hidden")

			this.notificationTimer = setTimeout(() => {
				$(".bank-notification").addClass("hidden");
			}, 2500);
		},

		transfer() {
			this.post("bank:transfer");
		},

		deposit() {
			this.post("bank:deposit");
		},

		withdraw() {
			this.post("bank:withdraw");
		},

		charity() {
			this.post("bank:charity");
		},

		factionReplenish() {
			this.post("bank:factionReplenish");
		},

		factionWithdraw() {
			this.post("bank:factionWithdraw");
		},

		shop() {
			window.invokeNative('openUrl', 'https://store.armylegends.ro');
		},

		destroy() {
			this.active = false;
			this.post("bank:close");
			this.post("frontendSound", {dict: "ATM_WINDOW", sound: "HUD_FRONTEND_DEFAULT_SOUNDSET"});
			
            this.post("vrp:triggerEvent", ["vrp-hud:updateMap", true]);
            this.post("vrp:triggerEvent", ["vrp-hud:setComponentDisplay", {"*": true}]);
		}

	},
})