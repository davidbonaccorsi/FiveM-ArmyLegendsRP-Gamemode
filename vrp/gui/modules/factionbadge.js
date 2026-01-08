const factionBadge = {
    active: false,
    name: $(".badge-layout > .wrapper > .data.name > p"),
    rank: $(".badge-layout > .wrapper > .data.rank > p"),

    build(data) {
        var $this = this;
        var faction = data.faction.toLowerCase();

        if ($this.active){
            clearTimeout($this.active);

            $this.active = false;
            $(".badge-layout").fadeOut();
        }

        $this.name.text(data.name);
        $this.rank.text(data.rank);
        $(`.badge-layout.${faction}`).fadeIn();

        $this.active = setTimeout(() => {
            $this.active = false;
            $(`.badge-layout.${faction}`).fadeOut();
        }, 7000);
    }

};

window.addEventListener("message", (event) => {
    const data = event.data;

    if (data.interface == "factionBadge") {
        factionBadge.build(data.data);
    }
})