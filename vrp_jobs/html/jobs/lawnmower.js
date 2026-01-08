
const lawnmowerJob = new Vue({
    el: ".main-lawnmower",
    data: {
        active: false,
        zoom: 0,
        job: "",
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
				this.destroy();
		},

        onMessage() {
            const data = event.data;

            if (data.job == "lawnmower")
                this.build(data);
        },

		async post(url, data = {}, res = GetParentResourceName()) {
			const response = await fetch(`https://${res}/${url}`, {
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
            this.job = data.group;

            var tog = false;

            this.post("setFocus", [true]);
            this.post("vrp:triggerEvent", ["vrp-hud:updateMap", tog], "vrp");
            this.post("vrp:triggerEvent", ["vrp-hud:setComponentDisplay", {
                serverHud: tog,
                minimapHud: tog,
                bottomRightHud: tog,
                chat: tog
            }], "vrp");

        },

        destroy() {
            this.active = false;

            var tog = true;

            this.post("setFocus", [false]);
            this.post("vrp:triggerEvent", ["vrp-hud:updateMap", tog], "vrp");
            this.post("vrp:triggerEvent", ["vrp-hud:setComponentDisplay", {
                serverHud: tog,
                minimapHud: tog,
                bottomRightHud: tog,
                chat: tog
            }], "vrp");

        },
    }
})

const mowerGame = {
    em: $(".mower-minigame"),
    active: false,
    count: 0,

    onMessage(data) {
        if (data.job == "mowergame")
            this.build();
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
        if (this.active) return;

        this.active = true;
        this.count = 0;

        var maxStones = Math.floor(Math.random() * (8-5)) + 5;

        for (var i = 0; i < maxStones; i++) {
            var position = this.getSpawnPosition(this.em.height() / 2 - 350, 250, this.em.width() / 2 - 350, 750);
            this.em.append(`
                <div id="mower-stone-${i}" class="stone" style="left: ${position.x}px; top: ${position.y}px;"></div>
            `);


            var theStone = $("#mower-stone-" + i);
            theStone.on("click", function() {
                $(this).remove();
                mowerGame.count++;

                if (mowerGame.count >= maxStones) {
                    mowerGame.post("lawnmower:gameDone");
                    mowerGame.destroy();
                }
            })
        }

        this.em.fadeIn(1000);
        this.post("setFocus", [true]);
    },

    getSpawnPosition(top, height, left, width) {
        return {
            x: Math.floor(Math.random() * width) + left,
            y: Math.floor(Math.random() * height) + top,
        }
    },

    destroy() {
        this.active = false;
        this.em.fadeOut(1000);

        this.post("setFocus", [false]);
    },
}

window.addEventListener("message", (event) => {
    mowerGame.onMessage(event.data);
})
