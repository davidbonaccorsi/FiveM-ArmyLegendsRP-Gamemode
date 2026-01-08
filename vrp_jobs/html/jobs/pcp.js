
const pcpJob = new Vue({
    el: ".main-pcp",
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

            if (data.job == "pcp")
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


const pcpGame = {
    em: $(".pcp-minigame"),
    spawn: $(".pcp-minigame .spawn-zone"),
    basket: $(".pcp-minigame .drag-zone"),
    active: false,
    count: 0,

    onMessage(data) {
        if (data.job == "pcpgame")
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

        var maxLeafs = Math.floor(Math.random() * 6) + 7;

        for (var i = 0; i < maxLeafs; i++) {
            var position = this.getSpawnPosition(this.spawn.height() / 2 - 350, 250, this.spawn.width() / 2 - 350, 750);
            this.em.append(`
                <div id="pcp-leaf-${i}" class="leaf" style="left: ${position.x}px; top: ${position.y}px;"></div>
            `);


            var theLeaf = $("#pcp-leaf-" + i);
            theLeaf.draggable({containment: 'window', scroll: false});
        }

        this.basket.droppable({
            drop: (event, ui) => {
                ui.draggable.remove();
                this.count++;

                if (this.count >= maxLeafs) {
                    this.post("pcp:gameDone");
                    this.destroy();
                }
            }
        })

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
        this.basket.droppable("destroy");
        this.em.fadeOut(1000);

        this.post("setFocus", [false]);
    },
}

window.addEventListener("message", (event) => {
    pcpGame.onMessage(event.data);
})
