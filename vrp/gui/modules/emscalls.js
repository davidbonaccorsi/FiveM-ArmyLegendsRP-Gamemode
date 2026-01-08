
const emsCalls = {
    active: false,
    choices: [],
    selected: -1,
    el_choices: [],

    build(data) {
        this.active = true;
        this.choices = data.calls;

        $(".emergency-calls").find(".call-box").remove();
        this.el_choices = [];

        for (var i = 0; i < this.choices.length; i++) {
            var v = this.choices[i];
        
            var el = $(`
              <div class="call-box">${v.name} <div>${v.distance}m</div></div>
            `);
        
            this.el_choices.push(el);
            $(".emergency-calls").append(el);
        }

        $(".emergency-calls").fadeIn(1000);
        this.setSelected(0);
    },

    setSelected(i) {
        if (this.selected >= 0 && this.selected < this.el_choices.length) {
            this.el_choices[this.selected].removeClass("selected");
        }

        this.selected = i;
        if (this.selected < 0) this.selected = this.choices.length - 1;
        else if (this.selected >= this.choices.length) this.selected = 0;

        if (this.selected >= 0 && this.selected < this.el_choices.length) {
            this.el_choices[this.selected].addClass("selected");
        }

        var scrollto = $(this.el_choices[this.selected]);
        var container = $(".emergency-calls");
        if (
          scrollto.offset().top < container.offset().top ||
          scrollto.offset().top + scrollto.height() >=
            container.offset().top + container.height()
        )
          container.scrollTop(
            scrollto.offset().top - container.offset().top + container.scrollTop()
          );
    },

    moveUp() {
        if (!this.active) return;
        this.setSelected(this.selected - 1);
    },

    moveDown() {
        if (!this.active) return;
        this.setSelected(this.selected + 1);
    },

    valid() {
        if (!this.active) return;
        this.destroy(true);
    },

    destroy(valid) {
        this.active = false;

        if (valid) post("vrp:triggerServerEvent", ["ems:takeCall", this.choices[this.selected].user_id]);

        this.choices = [];
        $(".emergency-calls").fadeOut(1000);
        post("ems:hideBinds");
    },

}

var emsTime = false;
window.addEventListener("message", (event) => {
    const data = event.data;

    if (data.interface == "emsCalls") {
        if (!emsCalls.active) {
            emsCalls.build(data);
        }
    } else if (data.interface == "emsCallsAlert") {
        if (emsTime) {
            clearTimeout(emsTime);
            $(".emergency-calls-alert").hide();
        }

        $(".emergency-calls-alert").show();

        var audio = new Audio("../public/sounds/emssound.mp3");
        audio.volume = 0.8;
        audio.play();

        emsTime = setTimeout(() => {
            $(".emergency-calls-alert").fadeOut(1000);
            emsTime = false;
        }, 3000);
    }
})
