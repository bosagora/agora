import React, { Component } from "react";
import { withRouter, Route, Switch } from "react-router-dom";
import get from "lodash/get";
import Icon from "components/common/static/icon";
import { connect } from "react-redux";
import ValidatorAuthentication from "components/admin/integration/validator/validatorAuthentication";
import EncryptionKey from "components/admin/integration/encryption/encryptionContainer";
import AdminIntro from "components/admin/intro/intro";
import styles from "./admin.module.scss";
import Menu from "../common/menu";
import FirstTitle from "../common/static/firstTitle";
import Paragraph from "../common/static/paragraph";
import { Link } from "react-router-dom";

class Admin extends Component {
  render() {
    return (
      <div className={styles.admin}>
        <div className={styles.pageInner}>
          <div className={styles.container_leftSide}>
            <div className={styles.container_title}>
              <FirstTitle>Admin Interface</FirstTitle>
            </div>
            <div className={styles.container_description}>
              <Paragraph>Please select the menu below</Paragraph>
            </div>
            <div className={styles.container_stepsMenu}>
              <Menu />
            </div>
            <div className={styles.container_logo}>
              <Link to={'/admin'}>
                <Icon name="logo" />
              </Link>
            </div>
          </div>
          <div className={styles.container_rightSide}>
            <div className={styles.container_rightSideInner}>
              <Switch>
                <Route exact path="/admin/" component={AdminIntro} />
                <Route
                  path="/admin/validator"
                  component={ValidatorAuthentication}
                />
                <Route path="/admin/encryption" component={EncryptionKey} />
              </Switch>
            </div>
          </div>
        </div>
      </div>
    );
  }
}

const mapStateToProps = (state) => ({
  intro: {
    stepItems: get(state, ["intro", "items"], {}),
  },
});
const mapDispatchToProps = {};
export default withRouter(connect(mapStateToProps, mapDispatchToProps)(Admin));
