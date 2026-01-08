
APPS.auctions = {
    layout: $(".auctions"),
    noAuctionMsg: $(".auctions .no-auctions"),

    async build() {

        APPS.home.layout.removeClass("visible");

        this.layout.addClass("visible");


        const auction = await post("getActiveAuction");
        if (!auction) {
            $(".auctions .bid-hide").fadeOut(1000, () => {
                this.noAuctionMsg.fadeIn(1000);
            });
        } else {
            this.noAuctionMsg.fadeOut(1000, () => {
                $(".auctions .bid-image").css("--url", `url(${auction.img})`);             
                $(".auctions .bid-hide").fadeIn(1000);
            });
        }

    },


    ready() {
        this.layout.on("click", ".join-bid", function() {
            post("joinActiveAuction");
        })
    },

}

APPS.auctions.ready();
