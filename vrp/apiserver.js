const express = require('express');
const app = express();
const port = 30122

app.get('/allowDiscord/:id/:username', (req, res) => {
    let user_id = req.params.id;
    let username = req.params.username;

    if (user_id) {
        emit('vrp:allowDiscord', {
            user_id: user_id,
            username: username,
        })
    }
    res.status(200).send('ok')
})

app.listen(port, () => console.log('[vRP] Express Server started on port ' + port));