
APPS.gps = {
    layout: $(".gps"),
    placesList: $(".gps > .list"),
    backBtn: $(".gps > header > .actions > .return"),

    menuItems: {
        "Locatii importante": {category: "important_places", items: {
            "Aeroport": [-1044.3084716797,-2759.6091308594],
            "Mall Centru": [-554.42065429688,-614.60198974609],
            "Mall Verona": [-293.50143432617,-1929.9401855469],
            "Dealership": [-33.439804077148,-1097.2783203125],
            "Spital Los Santos": [298.04428100586,-583.97277832031],
            "Politie Los Santos": [429.57830810547,-982.27996826172],
        }},
        "Jobs": {category: "jobs", items: {

            "Taietor de iarba": [-1050.9725341797,6.0058469772339],
            "Constructor": [-848.66363525391,-799.65399169922],
            "Pilot Los Santos": [-1185.2652587891,-2674.0170898438],
            "Pilot Cayo Perico": [4427.7822265625,-4451.53125],
            "Pilot Grapeseed": [2139.9816894531,4788.71484375],
            "Culegator de portocale": [2031.8020019531,4733.4189453125],
            "Sofer de autobuz": [454.33969116211,-600.66009521484],
            "Pescar": [-1514.3322753906, 1512.4349365234, 115.28856658936],
            "Curatator de strazi": [1070.5645751953,-780.34704589844],
            "Mecanic": [-1601.3695068359,-832.49853515625],
            "Taxi": [895.46307373047,-179.29476928711],
            "Vanator": [-677.31420898438,5825.65625],
            "Furnizor de stocuri": [846.9814453125,-902.86309814453],

        }},
        "Cluburi": {category: "clubs", items: {

            "Tequila-la": [-553.5546875,284.31051635742],
            "Lux": [-309.74090576172,213.37471008301],
            "Vanilla": [122.04220581055,-1292.5881347656],
            "Yellow Jack": [1984.8952636719,3052.3234863281],
            "Galaxy": [352.15869140625,299.35394287109,104.04096221924],
        }},
        "Car meet": [859.58813476563,-2364.755859375],
    },

    build() {

        APPS.home.layout.removeClass("visible");

        this.layout.addClass("visible");
    
        this.load();

    },

    load() {
        this.placesList.find(".item").remove();
        this.backBtn.addClass("hidden");

        $.each(this.menuItems, function(k, v) {
            if (v) {

                APPS.gps.placesList.append(`
                    <div ${v.category ? 'data-category="'+ v.category +'"' : 'data-x="'+ v[0] +'" data-y="'+ v[1] +'"'} class="item">
                        <p>${k}</p>
                    </div>
                `)

            }
        });
    },

    ready() {
        this.placesList.on("click", ".item", function(event){
            event.preventDefault();
            var category = $(this).data('category');
            
            if (category) {
                APPS.gps.backBtn.removeClass("hidden");

                APPS.gps.placesList.find(".item").remove();

                var categoryList = APPS.gps.menuItems[$(this).children("p").text()].items;

                $.each(categoryList, function(k, v) {
                    if (v) {
            
                        APPS.gps.placesList.append(`
                            <div ${'data-x="'+ v[0] +'" data-y="'+ v[1] +'"'} class="item sub-category">
                                <p>${k}</p>

                                <div class="location-box">
                                    <i class="bi bi-geo-alt"></i>
                                </div>

                            </div>
                        `)
            
                    }
                });

            } else {
                var x = $(this).data("x");
                var y = $(this).data("y");

                Notifications.show("Pozitia a fost setata pe harta!", 2000);
                post("setMapPosition", [x, y]);

            }
        });

        this.backBtn.on("click", function(event) {
            event.preventDefault();
            APPS.gps.load();
        })
    }

};

APPS.gps.ready();
