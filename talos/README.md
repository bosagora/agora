# Talos: Setup interface for Agora

This directory contains Talos, a user-friendly first-time setup interface for Agora.
Talos is available when running with the `--initialize=$ADDRESS` argument.
For example, the following:
```sh
$ agora --initialize=http://127.0.0.1:3000
```
Will make Talos available to localhost on port 3000.

The rest of this document is aimed towards developer.

## Developer informations

### Structure

The app is fairly simple, as it is intended to be used only once, but target both mobile and desktop.
It mostly uses React (with some leftover Redux usages), and a description of the architecture is available in [the entry point](src/components/app/App.js).

### Available Scripts

This project was bootstrapped with [Create React App](https://github.com/facebook/create-react-app).
This script usually provides a comprehensive README, which can be found [here](https://github.com/facebook/create-react-app/blob/master/packages/cra-template/template/README.md).
A shorter summary is available below:

In the project directory, you can run:

- `npm start`: Runs the app in the development mode. Open [http://localhost:3000](http://localhost:3000) to view it in the browser. The page will reload on edits. The developer tools will be provided with source maps and linter warnings.

- `npm test` Launches the test runner in the interactive watch mode. Note that Talos isn't currently automatically tested.

- `npm run build`: Builds the app for production to the `build` folder. This is run when Agora is built. See the section about [deployment](https://facebook.github.io/create-react-app/docs/deployment) for more information.

- `npm run eject`: Don't do this.
