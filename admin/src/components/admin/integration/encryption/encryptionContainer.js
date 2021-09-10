import React, { Component } from "react";
import { withRouter } from "react-router-dom";
import { connect } from "react-redux";
import { clearEncryptionKey } from "../../../../actions/encryptionKeyAction";
import { isEmptyObject } from "../../../../utils/objectUtil";
import EncryptionForm from "./encryptionForm";
import EncryptionKey from "./encryptionKey";

class EncryptionContainer extends Component {
  constructor(props) {
    super(props);
    this.state = {
      ...this.state,
      appName: "",
      blockHeight: "",
      errors: {
        appName: "",
        blockHeight: "",
      },
    };
  }

  componentWillUnmount() {
    const { onClearEncryptionData } = this.props;
    onClearEncryptionData();
  }

  render() {
    const { qrData } = this.props;
    const isQrCode = isEmptyObject(qrData);
    const { errors } = this.state;
    return (
      <div>
        {isQrCode ? (
          <EncryptionForm errors={errors} />
        ) : (
          <EncryptionKey qrData={qrData} />
        )}
      </div>
    );
  }
}

const mapStateToProps = (state) => {
  return {
    qrData: state.encryptionKey.qrData,
  };
};
const mapDispatchToProps = (dispatch) => ({
  onClearEncryptionData: () => dispatch(clearEncryptionKey()),
});
export default withRouter(
  connect(mapStateToProps, mapDispatchToProps)(EncryptionContainer)
);
