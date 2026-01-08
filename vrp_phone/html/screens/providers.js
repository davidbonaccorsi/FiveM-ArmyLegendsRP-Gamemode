
APPS.providers = {
    layout: $(".providers"),
    orderList: $(".providers .orders-list"),
    
    async build() {

        let isProvider = await post("isWorkingAsProvider");
        if (!isProvider) return Notifications.show("Nu lucrezi ca Furnizor de stocuri.", 3500);

        APPS.home.layout.removeClass("visible");

        this.layout.addClass("visible");

        this.refreshOrders();
        
    },



    getListItems(items) {
        var list = "";
        $.each(items, function(k, v) {
            list += ("<li>" + (v.amount + " " + v.label + "\n") + "</li>");
        });
        return list;
    },


    async refreshOrders() {
        this.orderList.find("div").fadeOut(500, function() {
            $(this).remove();
        });

        let orders = await post("getProviderOrders");
        
        let _this = this;
        $.each(orders, function(k, v) {

            var div = $(`

                <div class="${v.worker ? 'in-progress' : ''}" style="display: none;">
                    ${v.worker ? '<i class="fa-duotone fa-spinner-third fa-spin" style="--fa-primary-color: #804000; --fa-secondary-color: #804000;"></i>' : ''}
                    
                    <div class="order-header">
                        Magazin ${v.biz}
                        <span>castig: $${v.reward || 0}</span>
                        <i class="far fa-circle-check" onclick="APPS.providers.work(${v.biz}, ${v.worker})"></i>
                    </div>
                    <ul type="circle">
                        ${_this.getListItems(v.order)}
                    </ul>
                </div>
            
            
            `);

            _this.orderList.append(div);
            setTimeout(() => {
                div.fadeIn(1000);
            }, 500);

        })
    },

    work(bizId, worker) {
        if (worker) return;
        
        post("vrp:triggerServerEvent", ["work-provider:workForMarket", bizId], "vrp");
        setTimeout(() => {
            this.refreshOrders();
        }, 250);
    }

}
