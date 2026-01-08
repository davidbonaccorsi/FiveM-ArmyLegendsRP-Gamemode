const vehicleMenu = new Vue({
	el: ".vehicle-menu",
	data: {
		active: false,
	},
	mounted() {
		window.addEventListener("keydown", this.onKey)
		window.addEventListener("message", this.onMessage)
	},
	methods: {
		onMessage() {
			const data = event.data;
			if (data.interface == "vehicleMenu")
				this.build();
		},
		onKey() {
			var theKey = event.code;
			if (theKey == "Escape" && this.active)
				this.destroy();
		},
		async post(url, data = {}) {
			const response = await fetch(`https://${GetParentResourceName()}/${url}`, {
			    method: 'POST',
			    headers: { 'Content-Type': 'application/json' },
			    body: JSON.stringify(data)
			});
			
			return await response.json();
		},
		build() {
			if (this.active) {
				return this.post("setFocus", [false]);
			}

			this.active = true;
			$(".vehicle-menu").show();
		  
			$('.vehicle-menu .item').each(function(index){
			  $(this).delay(100*index).animate({opacity: 1}, 600);
			});
		},		  
		destroy() {
			if (!this.active) return
			$('.vehicle-menu .item').each(function(index){
				$(this).delay(50*index).animate({opacity: 0}, 200);
			});
			
			setTimeout(() => {
				this.active = false
				$(".vehicle-menu").hide();
			}, 800);
	        this.post("setFocus", [false]);
		},
		setSeat(newSeat) {
	        this.post("vehmenu:switchSeat", {seat: newSeat});
			this.post("frontendSound", {dict: "NAV", sound: "HUD_AMMO_SHOP_SOUNDSET"});
		},
		togEngine() {
			this.post("vehmenu:switchEngine");
			this.post("frontendSound", {dict: "NAV", sound: "HUD_AMMO_SHOP_SOUNDSET"});
		},
		togNeons () {
			this.post('vehmenu:toggleNeons');
		},
		togDoor(theDoor) {
			this.post("vehmenu:toggleDoor", {door: theDoor});
			this.post("frontendSound", {dict: "NAV", sound: "HUD_AMMO_SHOP_SOUNDSET"});
		},
	    togWindow(theWindow) {
	        this.post("vehmenu:toggleWindow", {windowId: theWindow});
			this.post("frontendSound", {dict: "NAV", sound: "HUD_AMMO_SHOP_SOUNDSET"});
	    },
	    togLights() {
	    	this.post("vehmenu:togLights");
			this.post("frontendSound", {dict: "NAV", sound: "HUD_AMMO_SHOP_SOUNDSET"});
	    },
	}
})