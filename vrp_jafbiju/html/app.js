
const vangelicoGame = {
    em: $(".vangelico-minigame"),
    spawn: $(".vangelico-minigame .spawn-zone"),
    basket: $(".vangelico-minigame .drag-zone"),
    active: false,
    count: 0,

    onMessage(data) {
        if (data.interface == "vangelico")
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

    build(data) {
        this.active = true;
        this.count = 0;

        var maxWins = 0;

        for (const key in data.wins) {
            var item = data.wins[key];
            maxWins++;
        
            var position = this.getSpawnPosition(this.spawn.height() / 2 - 350, 250, this.spawn.width() / 2 - 350, 750);
            this.em.append(`
                <div id="vangelico-win-${maxWins}" class="win" style="background-image: url(https://cdn.armylegends.ro/items/biju_${item.id}.webp); left: ${position.x}px; top: ${position.y}px;"></div>
            `);
        
            var theWin = $("#vangelico-win-" + maxWins);
            theWin.draggable({containment: 'window', scroll: false});
        }

        this.basket.droppable({
            drop: (event, ui) => {
                ui.draggable.remove();
                this.count++;

                if (this.count >= maxWins) {
                    this.post("vangelico:gameDone");
                    this.destroy();
                }
            }
        })

        this.em.fadeIn(1000);
        this.post("vrp:triggerEvent", ["vrp-hud:updateMap", false], "vrp");
        this.post("vrp:triggerEvent", ["vrp-hud:setComponentDisplay", {
            serverHud: false,
            minimapHud: false,
            bottomRightHud: false,
            chat: false
        }], "vrp");
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

                    
		this.post("vrp:triggerEvent", ["vrp-hud:updateMap", true], "vrp");
        this.post("vrp:triggerEvent", ["vrp-hud:setComponentDisplay", {
            serverHud: true,
            minimapHud: true,
            bottomRightHud: true,
            chat: true
        }], "vrp");
        this.post("setFocus", [false]);
    },
}

window.addEventListener("message", (event) => {
    vangelicoGame.onMessage(event.data);
})
