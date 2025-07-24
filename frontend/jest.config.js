// frontend/jest.config.js
const nextJest = require('next/jest');

const createJestConfig = nextJest({
  // Tell it where your `next.config.js` is:
  dir: './',
});

const customJestConfig = {
  testEnvironment: 'jest-environment-jsdom',
  moduleNameMapper: {
    '\\.(css|scss|sass|png|jpg|jpeg|svg)$': 'identity-obj-proxy'
  },
  setupFilesAfterEnv: ['<rootDir>/jest.setup.ts'],
};

module.exports = createJestConfig(customJestConfig);
