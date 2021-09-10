import React from "react";
import ReactDOM from "react-dom";
import App from "./components/app/app";
import { composeWithDevTools } from "redux-devtools-extension/developmentOnly";
import * as serviceWorker from "./serviceWorker";

import { Provider } from "react-redux";
import { createStore, applyMiddleware, combineReducers } from "redux";
import thunk from "redux-thunk";
import "./assets/fonts/stylesheet.css";
import "./assets/icomoon/style.css";

import loginReducer from "./reducers/loginReducer";
import validatorAuthReducer from "./reducers/validatorAuthReducer";
import encryptionKeyReducer from "./reducers/encryptionKeyReducer";

const reducers = combineReducers({
  login: loginReducer,
  validatorAuth: validatorAuthReducer,
  encryptionKey: encryptionKeyReducer,
});

let store = createStore(reducers, composeWithDevTools(applyMiddleware(thunk)));

ReactDOM.render(
  <Provider store={store}>
    <App />
  </Provider>,
  document.getElementById("root")
);

// If you want your app to work offline and load faster, you can change
// unregister() to register() below. Note this comes with some pitfalls.
// Learn more about service workers: https://bit.ly/CRA-PWA
serviceWorker.unregister();
