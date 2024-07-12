const path = require('path');

module.exports = {
  entry: path.join(__dirname, './library/src/js', 'index.js'),
  output: {
    path: path.resolve(__dirname, './library/static/js'),
    filename: 'index.js',
  },
  module: {
    rules: [
      {
        test: /\.?js$/,
        exclude: /node_modules/,
        use: {
          loader: 'babel-loader',
          options: {
            presets: ['@babel/preset-env'],
          },
        },
      },
    ],
  },
};
