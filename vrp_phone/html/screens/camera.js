
APPS.camera = {

    async build() {
        phoneLayout.removeClass("visible");

        let saved = await post("takePhoto");
        
        phoneLayout.addClass("visible");

        if (saved)
            Notifications.show("Poza a fost salvata in galerie!");
    }

};
