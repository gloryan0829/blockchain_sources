var express = require('express');
var app = express();
var fs = require('fs');

app.use('/examples/lib', express.static('public'));

app.listen(8080, function() {
    console.log('Server Start');
})

app.get('/MyTokenWallet', function(req, res){
    fs.readFile('MyTokenWallet.html', function (error, data) {
        if (error) {
            console.log(error);
        } else {
            res.writeHead(200, { 'Content-Type' : 'text/html'});
            res.end(data);
        }
    })
});