var fuelStock = 0;
var userMoney = 0;
var fuelStationPrice = 0;

const fuelStation = new Vue({
    el: ".fuel-station-layout",
    data: {
        active: false,
        fuelStation: '',
        liters: 0,
        maxLiters: 100,
        payMethode: 'cash',
        fuelPrice: 100,
        // Bussines Menu
        business: false,
        fuelLevel: 0,
        currentPrice: 10,
        bizMoney: 0,
    },
    mounted() {
        window.addEventListener("keydown", this.onKey)
        window.addEventListener("message", this.onMessage)

        $('.fuel-station-layout > div').hide();
        $('.fuel-station-layout > .fuelstation-business').hide();

        const slider = $(".fuel-station-layout > div > .wrapper > .selectors > .slider");
        const slider_bussines = $(".fuel-station-layout > .fuelstation-business > .wrapper > .selectors > .slider-business");

        slider_bussines.slider({
            orientation: "horizontal",
            range: "min",
            min: 6,
            max: 25,
            value: 0,
            slide: function(event, ui) {
                fuelStation.currentPrice = ui.value;
            }
        });

        slider.slider({
            orientation: "horizontal",
            range: "min",
            max: 100,
            value: 15,
            slide: function(event, ui) {
                $('#fuel-station-liters').css('color', ui.value > fuelStock ? '#eb3434' : '#a1c9ff');
                $('#fuel-station-price').css('color', ui.value * fuelStationPrice > userMoney ? '#eb3434' : '#a1c9ff');
                fuelStation.liters = ui.value;
            }
        });
    },
    methods: {
        async post(url, data = {}) {
            const response = await fetch(`https://${GetParentResourceName()}/${url}`, {
                method: 'POST',
                mode: 'no-cors',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify(data)
            });
        
            return await response.json();
		},
        onKey() {
            var theKey = event.code;

            if (theKey == "Escape" && this.active)
                this.destroy();
        },
        onMessage() {
            const data = event.data;
            if (data.interface == "fuelStation") {
                this.build(data.data)
            }
        },
        sendError: function(err) {
            this.post("vrp:triggerEvent", ["vrp-hud:sendApiError", err]);
        },
        // Fuel Station Pump
        setFuelLevel: function(level) {
            if (this.maxLiters >= level) {
                $('#fuel-station-liters').css('color', level > fuelStock ? '#eb3434' : '#eed030');
                $('#fuel-station-price').css('color', level * fuelStationPrice > userMoney ? '#eb3434' : '#eed030');

                const slider = $(".fuel-station-layout > .wrapper > .selectors > .slider");
                slider.slider("option", "value", level)
                this.liters = level;
            }
        },
        changePaymentMethode: function(methode) {
            this.payMethode = methode;
        },
        payFuel: function() {
            if (this.liters <= 0)
                return this.sendError('Valoarea introdusa este invalida!');

            if (this.liters <= fuelStock) {
                this.post('fuelVehicle', [this.fuelStation, this.liters, this.payMethode])
                this.destroy();
            } else {
                this.sendError('Benzinaria nu are destul combustibil!')
            }
        },
        buyProduct: function(product) {
            this.post('fuelStation:buyProduct', [this.fuelStation, product])
            this.destroy();
        },
        // Fuel Station Bussines

        setFuelPrice: function(price) {
            this.currentPrice = price;
            const slider_bussines = $(".fuel-station-layout > .fuelstation-business > .wrapper > .selectors > .slider-business");
            slider_bussines.slider("option", "value", price)
        },
        sellGasStation: function() {
            this.post('fuelStation:sellGasStation', [this.fuelStation])
            this.destroy();
        },
        withdrawBalance: function() {
            this.post('fuelStation:withdrawBalance', [this.fuelStation])
            this.destroy();
        },
        addFuel: function() {
            this.post('fuelStation:addFuel', [this.fuelStation])
            this.destroy();
        },
        build: function(data) {
            this.active = true;
            this.post("setFocus", [true]);
            $(".fuel-station-layout").fadeIn(1000, function() {
                var self = fuelStation
                self.business = data.menu == 'business' ? true : false;
                if (self.business) {
                    $('.fuel-station-layout > .fuelstation-business').fadeIn(500);
                    const slider_bussines = $(".fuel-station-layout > .fuelstation-business > .wrapper > .selectors > .slider-business");
    
                    slider_bussines.slider("option", "max", data.maxPrice)
                    slider_bussines.slider("option", "min", data.minPrice)
                    slider_bussines.slider("option", "value", parseInt(data.currentPrice))

                    self.currentPrice = data.currentPrice;
                    self.fuelStation = data.fuelStation;
                    self.bizMoney = data.money;
                    self.fuelLevel = data.fuelLevel;
                } else {
                    $('#fuel-station-menu').fadeIn(500);
                    $('#fuel-station-liters').css('color', '#a1c9ff');
                    $('#fuel-station-price').css('color', '#a1c9ff');
                    const slider = $(".fuel-station-layout > div > .wrapper > .selectors > .slider");
                    // slider.slider("option", "max", data['vehFuel'])
                    // slider.slider("option", "value", 0)

                    console.log(JSON.stringify(data))

                    self.fuelStation = data.stationId
                    self.maxLiters =  data.vehFuel;
                    self.liters = 0;
                    self.fuelPrice = data.fuelPrice;
                    fuelStationPrice = data.fuelPrice;
                    fuelStock = data.fuelStock;
                    userMoney = data.userMoney;
                }
            })
        },
        destroy: function() {
            this.active = false;
            $(".fuel-station-layout").fadeOut();
            $('#fuel-station-menu').hide();
            $('.fuel-station-layout > .fuelstation-business').hide();

            this.post("setFocus", [false]);
            this.post("vrp:triggerEvent", ["vrp-hud:updateMap", true]);
            this.post("vrp:triggerEvent", ["vrp-hud:setComponentDisplay", {"*": true}]);

            if (this.business)
                this.post('fuelStation:updatePrice', [this.fuelStation, this.currentPrice])
        }
    }
})