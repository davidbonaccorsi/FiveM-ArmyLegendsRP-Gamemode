
APPS.vignette = {
    layout: $(".vignette"),
    carsList: $(".vignette #vignette-cars"),
    categories: $(".vignette .categories"),
    onceOpened: false,

    async build() {

        APPS.home.layout.removeClass("visible");

        this.layout.addClass("visible");

        this.refresh();
    },

    async refresh() {

        if (!this.onceOpened) {
            this.onceOpened = true;

            let vehicles = await post("getVignetteModels");

            var _this = this;
            this.carsList.find("option").remove();

            $.each(vehicles, function(k, v) {
                _this.carsList.append(`<option value='${k}'>${v}</option>`);
            })

            this.layout.find(".pay").removeClass("available");

            if (!(this.categories.find(".selected").length < 1)) {
                this.categories.find(".selected").removeClass("selected");
            }
        } else {
            if ((this.categories.find(".selected").length > 0) && this.carsList.val()) {
                this.layout.find(".pay").addClass("available");
            } else {
                this.layout.find(".pay").removeClass("available");
            }
        }
        
    },

    destroy() {
        this.onceOpened = false;
    },

    ready() {
        var _this = this;
        this.categories.on("click", "div", function() {
            if (!(_this.categories.find(".selected").length < 1)) {
                _this.categories.find(".selected").removeClass(".selected");
            };

            $(this).toggleClass("selected");
            _this.refresh();
        })

        this.layout.on("click", ".pay", function() {
            if (!$(this).hasClass("available")) return;
                
            post("getVignetteForModel", [_this.carsList.val()]);
        })        
    }

}

APPS.vignette.ready();
