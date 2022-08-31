import styles from "./encryptionContainer.module.scss";
import { QRCode } from "react-qr-svg";
import Paragraph from "../../../common/static/paragraph";
import ButtonFill from "../../../common/controls/buttonFill";
import React from "react";
import { clearEncryptionKey } from "../../../../actions/encryptionKeyAction";
import { connect } from "react-redux";

const EncryptionKey = (props) => {
  const { qrData, onPreviousHandler } = props;
  return (
    <div className={styles.wrapper}>
      <div className={styles.qrCode}>
        <QRCode value={JSON.stringify(qrData)} />
      </div>
      <div className={styles.information}>
        <Paragraph align="center">
          Please read this code on the app and continue voting.
        </Paragraph>
      </div>
      <div className={styles.controls}>
        <ButtonFill className={styles.refresh} onClick={onPreviousHandler}>
          Previous
        </ButtonFill>
      </div>
    </div>
  );
};
const mapDispatchToProps = (dispatch) => ({
  onPreviousHandler: () => dispatch(clearEncryptionKey()),
});
export default connect(null, mapDispatchToProps)(EncryptionKey);
