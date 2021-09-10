import React, { Component } from "react";

import { connect } from "react-redux";
import FirstTitleExtra from "../common/static/firstTitleExtra";
import ButtonFill from "../common/controls/buttonFill";
import Icon from "../common/static/icon";
import PropTypes from "prop-types";
import styles from "./login.module.scss";
import FaultMessage from "../common/static/faultMessage";
import { withRouter, Redirect } from "react-router-dom";
import TextField from "@material-ui/core/TextField";
import { login } from "../../actions/loginAction";

class Login extends Component {
  constructor(state) {
    super(state);
    this.state = {
      username: "",
      password: "",
      submitted: false,
    };

    this.loginHandler = this.loginHandler.bind(this);
    this.changeHandler = this.changeHandler.bind(this);
  }
  static propTypes = {
    isLoggedIn: PropTypes.bool,
    faultMessage: PropTypes.string,
  };

  loginHandler = (e) => {
    e.preventDefault();
    this.setState({ submitted: true });
    const { username, password } = this.state;
    if (username !== "" && password !== "")
      this.props.dispatch(login(username, password));
  };

  changeHandler = (e) => {
    const { name, value } = e.target;
    this.setState({ [name]: value });
  };

  render() {
    const { username, password, submitted } = this.state;

    return this.props.isLoggedIn ? (
      <Redirect to="/admin" />
    ) : (
      <div className={styles.login}>
        <div className={styles.loginInner}>
          <div className={styles.container_top}>
            <div className={styles.topContainer}>
              <div className={styles.container_mainTitle}>
                <FirstTitleExtra>
                  Welcome to the Admin Interface
                </FirstTitleExtra>
              </div>
              <div className={styles.container_logo}>
                <Icon name="logo" />
              </div>
            </div>
          </div>
          <div className={styles.container_bottom}>
            <div className={styles.bottomContainer}>
              <TextField
                label="User ID"
                name="username"
                value={username}
                onChange={this.changeHandler}
                className={styles.container_userId}
                error={submitted && username === "" ? true : false}
                helperText={
                  submitted && username === "" ? "UserID is required" : ""
                }
              />
              <TextField
                className={styles.container_password}
                name="password"
                label="Password"
                type="password"
                value={password}
                onChange={this.changeHandler}
                error={submitted && password === "" ? true : false}
                helperText={
                  submitted && password === "" ? "password is required" : ""
                }
              />
              <div className={styles.container_loginMessage}>
                <FaultMessage message={this.props.faultMessage} />
              </div>
              <div className={styles.container_loginButton}>
                <ButtonFill onClick={this.loginHandler}>Login</ButtonFill>
              </div>
            </div>
          </div>
        </div>
      </div>
    );
  }
}

const mapStateToProps = (state) => {
  return {
    isLoggedIn: state.login.isLoggedIn,
    faultMessage: state.login.faultMessage,
  };
};
export default withRouter(connect(mapStateToProps)(Login));
