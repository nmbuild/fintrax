// frontend/jest.config.js
module.exports = {
  testEnvironment: 'jsdom',                // browser-like environment
  roots: ['<rootDir>'],                    // look here for tests
  transform: {
    '^.+\\.[tj]sx?$': 'babel-jest',        // use Babel-Jest for TS, TSX, JS, JSX
  },
  moduleFileExtensions: [
    'ts','tsx','js','jsx','json','node'
  ],
  testMatch: [
    '**/__tests__/**/*.[jt]s?(x)',
    '**/?(*.)+(spec|test).[tj]s?(x)'
  ],
  moduleNameMapper: {
    '\\.(css|scss|sass|png|jpg|jpeg|svg)$': 'identity-obj-proxy',
  },
  setupFilesAfterEnv: ['<rootDir>/jest.setup.ts'], 
  transformIgnorePatterns: ['/node_modules/'],
};
