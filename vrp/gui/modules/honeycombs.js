const actionsMenu = {
    layout: $(".honeycombs-layout"),
    active: false,
    id: false,
    rows: [
        [$("#honeycomb-row-1"), 0, 1, 0, 0],
        [$("#honeycomb-row-2"), 0, 2, 0, 1],
        [$("#honeycomb-row-3"), 0, 3, 0, 2],
        [$("#honeycomb-row-4"), 0, 999, 0, 3]
    ],

    findInsertRow() {

        for (i = 1; i < 5; i++) {
            var rowData = this.rows[i-1]

            if ((rowData[1] + 1) <= rowData[2])
                return i;
        }

    },

    build(menu) {
        this.active = true;
        this.id = menu.id;

        this.layout.fadeIn("fast");

        for (i = 1; i < 5; i++) {
            this.rows[i-1][0].find("li").remove();
            this.rows[i-1][1] = 0;
            // this.rows[i-1][3] = 0;
        }

        const choices = Object.entries(menu.choices);

        this.rows[0][2] = choices.length == 2 ? 2 : 1;
        this.rows[0][2] = (choices.length == 4) ? 4 : this.rows[0][2];
        this.rows[0][2] = (choices.length == 5 || choices.length == 12) ? 2 : this.rows[0][2];
        this.rows[1][2] = (choices.length == 5 || choices.length == 7 || choices.length == 12) ? 3 : 2;
        this.rows[2][2] = (choices.length == 7) ? 2 : 3;
        // this.rows[2][2] = (choices.length == 12) ? 4 : this.rows[2][2];

        for (const [key, value] of choices){
            var rowId = ((value[2] || this.findInsertRow()) - 1);

            this.rows[rowId][1]++;

            this.rows[rowId][0].append(`
            
                <li class="animate" id="honey_digit_${Number(key)+1}">
                    <span>${Number(key)+1}</span>
                    <img src="https://cdn.armylegends.ro/honeycombs/${value[1]}">
                    <p>${value[0]}</p>
                </li>

            `);

            // this.rows[rowId][3]++;
        }

        // for (const row of this.rows) {
        //     if (row[2] > 0 && ((row[3] % 2) != 0) && this.rows[row[4-1]] && ((this.rows[row[4-1]][3] % 2) != 0)) {
        //         row[0].addClass("not-even");
        //     } else {
        //         row[0].removeClass("not-even");
        //     }
        // }
    },

    destroy(choice) {
        this.active = false;
        this.layout.fadeOut("fast");
        
        post("useHoneycomb", [this.id, choice]);
        this.id = false;
    },

    ready() {

        var $this = this;

        this.layout.on("click", "li", function(event) {
            var choice = $(this).children("p").text();
            
            $this.destroy(choice);
        })

    }
}

actionsMenu.ready();

window.addEventListener("keydown", function(event){
    var theKey = event.code;

    if (actionsMenu.active) {
        if (theKey == "Escape") {
            actionsMenu.destroy();
        } else {
            for (var i = 1; i <= 9; i++) {
                if (theKey == ("Digit" + i)) {
                    let btn = $("#honey_digit_" + i);
                    
                    if (btn[0]) {
                        actionsMenu.destroy(btn.children("p").text());
                    }
                }
            }
        }
    }
});

window.addEventListener("message", function(event) {
    const data = event.data;

    if (data.interface == "actionsMenu"){

        if (data.type == "open_menu") {
            actionsMenu.build(data.menu);
        } else {
            actionsMenu.destroy();
        }
    }
})