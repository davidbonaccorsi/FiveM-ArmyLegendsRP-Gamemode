var dailyReward = new Vue({
    el: '.main-daily',
    data: {
        active: false,
        dailyRewards: [],
        day: 0,
        collectData: [],
        canCollect: true,
        collectCooldown: 0,
    },
    mounted() {
		window.addEventListener("keydown", this.onKey)
    },
    methods: {
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
        build: function(data) {
            this.active = true
            this.dailyRewards = data.dailyRewards
            this.day = data.dailyData.collectedDays
            let lastClaim = data.dailyData.lastClaim
            const currentTime = new Date(new Date().toLocaleString('en-US', { timeZone: 'Europe/Bucharest' })).getTime();
            this.canCollect = lastClaim * 1000 <= currentTime

            if (!this.canCollect) {
                var timeDifference = (lastClaim * 1000) - currentTime; // Convert to milliseconds
                var hours = Math.floor(timeDifference / (1000 * 60 * 60));
                var minutes = Math.floor((timeDifference % (1000 * 60 * 60)) / (1000 * 60));
                var seconds = Math.floor((timeDifference % (1000 * 60)) / 1000);

                this.collectCooldown = hours.toString().padStart(2, '0') + ":" + minutes.toString().padStart(2, '0') + ":" + seconds.toString().padStart(2, '0');
            }

            this.collectData = this.dailyRewards[this.day - 1]
        },
        collectReward: function() {
            this.post('daily:collect').then((data) => {
                this.build(data)
            })
        },

        destroy: function() {
            this.active = false
            this.post('setFocus', [false])
            this.post("vrp:triggerEvent", ["vrp-hud:updateMap", true]);
            this.post("vrp:triggerEvent", ["vrp-hud:setComponentDisplay", {"*": true}]);
        },
    },
});