var express = require('express');
var app = express();
var fs = require('fs');

app.use('/examples/lib', express.static('public'));

app.listen(8080, function() {
    console.log('Server Start');
})

app.get('/My721TokenWallet', function(req, res){
    fs.readFile('My721TokenWallet.html', function (error, data) {
        if (error) {
            console.log(error);
        } else {
            res.writeHead(200, { 'Content-Type' : 'text/html'});
            res.end(data);
        }
    })
});

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

app.get('/My721TokenWallet', function(req, res){
    fs.readFile('My721TokenWallet.html', function (error, data) {
        if (error) {
            console.log(error);
        } else {
            res.writeHead(200, { 'Content-Type' : 'text/html'});
            res.end(data);
        }
    })
});

app.get('/web3js_ex', function(req, res){
    fs.readFile('web3js_ex.html', function (error, data) {
        if (error) {
            console.log(error);
        } else {
            res.writeHead(200, { 'Content-Type' : 'text/html'});
            res.end(data);
        }
    })
});