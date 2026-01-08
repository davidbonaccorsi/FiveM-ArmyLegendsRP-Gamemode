
const dirtyGame = {
    em: $(".dirty-minigame"),
    active: false,
    count: 0,

    onMessage(data) {
        if (data.job == "dirtygame")
            this.build();
    },

     		
    onKey(event) {
        var theKey = event.code;

        if (theKey == "Escape" && this.active) {
            this.destroy();
            this.post("dirty:gameDone", [false]);
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

    build() {
        this.active = true;
        this.count = 0;

        var maxMoneys = Math.floor(Math.random() * (8-5)) + 5;

        for (var i = 0; i < maxMoneys; i++) {
            var position = this.getSpawnPosition(this.em.height() / 2 - 350, 250, this.em.width() / 2 - 450, 650);
            this.em.append(`
                <div id="dirty-money-${i}" class="money" style="left: ${position.x}px; top: ${position.y}px;"></div>
            `);


            var theMoney = $("#dirty-money-" + i);
            theMoney.on("click", function() {
                $(this).remove();
                dirtyGame.count++;

                if (dirtyGame.count >= maxMoneys) {
                    dirtyGame.post("dirty:gameDone", [true]);
                    dirtyGame.destroy();
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
    dirtyGame.onMessage(event.data);
})

window.addEventListener("keydown", (event) => {
    dirtyGame.onKey(event);
});
