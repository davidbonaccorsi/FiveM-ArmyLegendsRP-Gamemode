

let backups = new Array();

window.addEventListener("message", (event) => {
    const data = event.data;

    if (data.interface == "policeBk") {
        if (backups.length > 1) {
            clearTimeout(backups[0].timeout);
            backups[0].div.remove();
            backups.shift();
        }
        
        let bkDiv = $(`
            <div class="backup" style="display: none">
                <div class="header">
                    <div>${data.code}</div>
                    ${data.name ? `<div>${serverHud.truncateText(data.name, 22)}</div>` : ''}
                    <img src="https://cdn.armylegends.ro/elements/pdbk.png">
                </div>
                <p class="description">
                    ${data.description}
                    <span>Locatie: <font>${data.location}</font></span>
                </p>
            </div>
        `);
    
        let backup = {
            div: bkDiv,
            timeout: setTimeout(() => {
                bkDiv.fadeOut(1000, () => {
                    bkDiv.remove();
                });
            }, 5000),
        }

        $(".police-backups").prepend(bkDiv);
        bkDiv.fadeIn(1000);
        backups.push(backup);
    }
})
