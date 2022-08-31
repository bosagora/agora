import React, { Component } from "react";
import { withRouter } from "react-router-dom";
import { QRCode } from "react-qr-svg";
import styles from "./validatorAuthentication.module.scss";
import ButtonFill from "../../../common/controls/buttonFill";
import Paragraph from "../../../common/static/paragraph";
import { connect } from "react-redux";
import PropTypes from "prop-types";
import {
  clearValidator,
  validatorAuth,
} from "../../../../actions/validatorAuthAction";
import { isEmptyObject } from "../../../../utils/objectUtil";

class ValidatorAuthentication extends Component {
  static propTypes = {
    qrData: PropTypes.objectOf(PropTypes.any).isRequired,
  };
  componentDidMount() {
    const { onValidatorAuth } = this.props;
    onValidatorAuth();
  }

  componentWillUnmount() {
    const { onClearValidatorData } = this.props;
    onClearValidatorData();
  }

  render() {
    const { onValidatorAuth } = this.props;
    return (
      <div className={styles.wrapper}>
        {isEmptyObject(this.props.qrData) ? (
          <div className={styles.emptyCode}></div>
        ) : (
          <div>
            <div className={styles.qrCode}>
              <QRCode value={JSON.stringify(this.props.qrData)} />
            </div>
            <div className={styles.information}>
              <Paragraph align="center">
                Select Register Validator in the app to open the screen reading
                this code.
              </Paragraph>
            </div>
          </div>
        )}
        <div className={styles.controls} onClick={onValidatorAuth}>
          <ButtonFill className={styles.refresh}>Refresh</ButtonFill>
        </div>
      </div>
    );
  }
}

const mapStateToProps = (state) => {
  return {
    qrData: state.validatorAuth.qrData,
  };
};
const mapDispatchToProps = (dispatch) => ({
  onValidatorAuth: () => dispatch(validatorAuth()),
  onClearValidatorData: () => dispatch(clearValidator()),
});
export default withRouter(
  connect(mapStateToProps, mapDispatchToProps)(ValidatorAuthentication)
);
