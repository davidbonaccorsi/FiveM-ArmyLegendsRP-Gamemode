
APPS.ishare = {
    layout: $(".ishare"),

    tabs: $(".ishare > footer"),
    feedTab: $(".ishare > footer > .content[data-tab='feed']"),
    publishTab: $(".ishare > footer > .content[data-tab='publish']"),
    
    feedList: $(".ishare > .list"),

    publishPage: $(".ishare > .publish"),
    publishList: $(".ishare > .publish > .list"),
    publishTutorial: $(".ishare > .publish > .tutorial"),

    build() {

        APPS.home.layout.removeClass("visible");

        this.layout.addClass("visible");

        if (this.feedList.hasClass("visible"))
            return this.loadFeed();

        this.loadGallery();
        
    },

    async loadFeed() {
        var appData = this;
        appData.feedList.find(".post").remove();

        var [feed, liked] = await post("getShareFeed");
        var xssID = 0;

        $.each(feed, function(k, v){
            xssID++;

            appData.feedList.prepend(`
            
                <div class="post" data-key="${k+1}">
                    <header>
                        <div class="avatar">
                            <p>${v.name.firstname.charAt(0) + v.name.secondname.charAt(0)}</p>
                        </div>

                        <p>${v.name.firstname + ' ' + v.name.secondname}</p>
                    </header>

                    <img src="${v.image}">

                    <div class="reactions ${liked[k] ? 'liked' : ''}">
                        <i class="bi bi-heart"></i>

                        <div class="count">
                            <p>${v.likes}</p>
                        </div>
                    </div>

                    <p id="ishare-${xssID}"></p>

                    <div class="line"></div>
                </div>
            
            `)

            $("#ishare-" + xssID).text(v.description);
        });
    },

    async loadGallery() {
        var appData = this;

        appData.feedTab.removeClass("active");
        appData.publishTab.addClass("active");

        if (appData.feedList.hasClass("visible")){
            appData.feedList.removeClass("visible");
        }

        appData.publishPage.addClass("visible");
        
        var images = await post("getGalleryImages");

        if (images.length == 0){
            appData.publishList.removeClass("visible");
            appData.publishTutorial.addClass("visible");
        } else {

            appData.publishTutorial.removeClass("visible");

            appData.publishList.find(".item").remove();

            $.each(images, function(k, v){
                appData.publishList.prepend(`
                
                    <div class="item" style="background-image: url(${v})" data-image="${v}" data-key="${k}">
                        <div class="actions">
                            <input placeholder="Type a description..." id="ishareImg-desc-${k}">
                            <i class="fa-regular fa-share-from-square"></i>
                        </div>
                    </div>
                
                `)
            });

            appData.publishList.addClass("visible");

        }
    },

    ready() {

        var appData = this;
        this.tabs.on("click", ".content", async function(event){
            event.preventDefault();

            var tab = $(this).data("tab");

            if (tab == "feed"){
                appData.publishTab.removeClass("active");
                appData.feedTab.addClass("active");

                if (appData.publishPage.hasClass("visible")){
                    appData.publishPage.removeClass("visible");
                }

                appData.feedList.addClass("visible");

                appData.loadFeed();

            } else if (tab == "publish"){
                appData.loadGallery();
            }

        });

        this.feedList.on("click", ".post > .reactions > i", function(event){
            var reactionsObj = $(this).parent();
            var postObj = reactionsObj.parent();

            var key = postObj.data("key");
            var likes = Number(reactionsObj.children(".count").children("p").text());
            var liked = reactionsObj.hasClass("liked");

            if (liked){

                likes--;
                reactionsObj.removeClass("liked");

                post("unlikeShare", [key]);

            } else {

                likes++;
                reactionsObj.addClass("liked");

                post("likeShare", [key]);
            }

            reactionsObj.children(".count").children("p").text(likes);
        })

        this.publishList.on("click", ".item > .actions > i", function(event){
            event.preventDefault();

            var parentObj = $(this).parent().parent();
            var img = parentObj.data("image");
            var key = parentObj.data("key");
            var description = $("#ishareImg-desc-" + key).val();

            post("postShare", [(description || "This share has no description."), img]);
        })

    },

}

APPS.ishare.ready();
