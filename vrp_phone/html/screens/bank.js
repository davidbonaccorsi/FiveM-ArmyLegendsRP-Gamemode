
APPS.banking = {
    layout: $(".bank"),
    actionsList: $(".bank > .actions"),
    balance: $(".bank > .balance > h1"),
    iban: $(".bank > .actions > .iban > p:last-of-type"),

    charityPrompt: {
        layout: $(".bank-prompt.charity"),
        confirmBtn: $(".bank-prompt.charity > .confirm"),
        cancelBtn: $(".bank-prompt.charity > header > .actions > .btn"),
        input: $(".bank-prompt.charity > .fields > .box > input"),

        show() {
            this.input.val("");
            this.layout.addClass("visible");
        },

        hide() {
            this.layout.removeClass("visible");
        }
    },

    transferPrompt: {
        layout: $(".bank-prompt.transfer"),
        cancelBtn: $(".bank-prompt.transfer > header > .actions > .btn"),
        confirmBtn: $(".bank-prompt.transfer > .confirm"),
        cancelBtn: $(".bank-prompt.transfer > header > .actions > .btn"),
        money: $(".bank-prompt.transfer > .fields > .box:nth-of-type(1) > input"),
        iban: $(".bank-prompt.transfer > .fields > .box:nth-of-type(2) > input"),

        show() {
            this.money.val("");
            this.iban.val("");
            this.layout.addClass("visible");
        },

        hide() {
            this.layout.removeClass("visible");
        }
    },

    build() {

        APPS.home.layout.removeClass("visible");

        this.layout.addClass("visible");
        
        this.loadBalance();
    },

    async loadBalance() {
        let money = await post("getBankMoney");
        
        this.balance.text(`$${Number(money).toLocaleString()}`)
    },

    async ready() {
        var appData = this;
        
        this.actionsList.on("click", ".action", function(event){
            event.preventDefault();
            
            var action = $(this).data("act");

            if (action == "charity"){
                appData.charityPrompt.show();
            } else if (action == "transfer"){
                appData.transferPrompt.show();
            }

        })

        this.charityPrompt.confirmBtn.on("click", async function(event){
            event.preventDefault();

            var donatedMoney = Number(appData.charityPrompt.input.val());

            if (isNaN(donatedMoney) || donatedMoney <= 0)
                return false;

            let ok = await post("donateToCharity", [donatedMoney]);

            if (!ok)
                return Notifications.show("Nu ai destui bani pentru a dona.");

            appData.loadBalance();
            appData.charityPrompt.hide();
        })


        this.transferPrompt.confirmBtn.on("click", async function(event){
            event.preventDefault();

            var transferedMoney = Number(appData.transferPrompt.money.val());
            var recipientIban = appData.transferPrompt.iban.val();

            if (isNaN(transferedMoney) || transferedMoney <= 0)
                return false;

            if (recipientIban.length < 5)
                return false;

            let notification = await post("transferToIban", [transferedMoney, recipientIban]);

            if (typeof(notification) == "string")
                return Notifications.show(notification);

            appData.loadBalance();
            appData.transferPrompt.hide();
        })



        this.charityPrompt.cancelBtn.on("click", function(event){
            event.preventDefault();

            appData.charityPrompt.hide();
        })

        this.transferPrompt.cancelBtn.on("click", function(event){
            event.preventDefault();

            appData.transferPrompt.hide();
        })


    }

}

APPS.banking.ready();
