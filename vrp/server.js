const { lstatSync, existsSync, statSync, readdirSync, readFileSync } = require('fs');

const defaultPath = `./resources/[gamemode]/${GetCurrentResourceName()}`

function collectFiles(folder) {
    const files = readdirSync(`${defaultPath}/${folder}`);
    const totalFiles = [];

    for(const file of files) {
        if(lstatSync(`${defaultPath}/${folder}/${file}`).isDirectory()) {
            const againCollectedFiles = collectFiles(`${folder}/${file}`);
            totalFiles.push(...againCollectedFiles);
        } else if(file.endsWith(".html")) {
            totalFiles.push({ content: readFileSync(`${defaultPath}/${folder}/${file}`).toString(), type: "html", priority: 1 })
        } else if(file.endsWith(".js")) {
            totalFiles.push({ content: readFileSync(`${defaultPath}/${folder}/${file}`).toString(), type: "js", priority: 0 })
        } else if(file.endsWith(".css")) {
            totalFiles.push({ content: readFileSync(`${defaultPath}/${folder}/${file}`).toString(), type: "css", priority: 0 })
        }
    }

    return totalFiles;
}

function loadUIThings(folder) {
    const collectedFiles = collectFiles(folder)

    emit('ui:loaded', JSON.stringify(collectedFiles))
}

loadUIThings("gui")