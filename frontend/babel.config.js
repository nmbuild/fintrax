// frontend/babel.config.js
module.exports = {
  presets: [
    // Compile modern JS down to your Node version (used by Jest)
    ['@babel/preset-env', { targets: { node: 'current' } }],
    // Handle TypeScript
    '@babel/preset-typescript',
    // Handle React JSX (automatic runtime)
    ['@babel/preset-react', { runtime: 'automatic' }],
  ],
};
