module.exports = {
  testMatch: ['**/spec/javascript/**/*-test.{js,jsx}', '**/spec/javascript/**/*.test.{js,jsx}'],
  testEnvironment: 'node',
  transform: {
    '^.+\\.[jt]sx?$': 'babel-jest',
  },
  moduleDirectories: ['node_modules', 'app/assets/javascripts'],
};
