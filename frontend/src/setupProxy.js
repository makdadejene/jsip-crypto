const { createProxyMiddleware } = require('http-proxy-middleware');

console.log('this is working')
module.exports = function (app) {
    app.use(
        '/api',
        createProxyMiddleware({
            target: 'http://localhost:8080',
            changeOrigin: true,
        })
    );
};