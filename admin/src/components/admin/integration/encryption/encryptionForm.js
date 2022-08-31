import styles from "./encryptionContainer.module.scss";
import Paragraph from "../../../common/static/paragraph";
import TextField from "@material-ui/core/TextField";
import ButtonFill from "../../../common/controls/buttonFill";
import React, { useState } from "react";
import { connect, useDispatch } from "react-redux";
import { generateEncryptionKey } from "../../../../actions/encryptionKeyAction";

const EncryptionForm = (props) => {
  const dispatch = useDispatch();
  const [appName, setAppName] = useState("Votera");
  const [blockHeight, setBlockHeight] = useState("");
  const [submitted, setSubmitted] = useState(false);

  const changeHandler = (e) => {
    e.persist();
    const { name, value } = e.target;
    if (name === "appName") {
      setAppName(value);
    } else {
      const onlyNums = value.replace(/[^0-9]/g, "");
      if (onlyNums.length > 0) {
        setBlockHeight(onlyNums);
      }
    }
  };

  const fetchHandler = (e) => {
    e.preventDefault();
    setSubmitted(true);
    if (appName !== "" && blockHeight > 0)
      dispatch(generateEncryptionKey(appName, blockHeight));
  };

  return (
    <div className={styles.wrapper}>
      <div>
        <div className={styles.description}>
          <Paragraph align="center">
            Please enter the information provided by the Votera app below.
          </Paragraph>
        </div>
        <div className={styles.inputSection}>
          <div className={styles.inputBox}>
            <TextField
              id="appName"
              name="appName"
              label="App Name"
              value={appName}
              className={styles.inputComponent}
              onChange={changeHandler}
              error={submitted && appName === "" ? true : false}
              helperText={submitted && appName === "" ? "Enter App Name" : ""}
            />
          </div>
          <div className={styles.inputBox}>
            <TextField
              className={styles.inputComponent}
              id="blockHeight"
              label="Block Height"
              name="blockHeight"
              value={blockHeight}
              onChange={changeHandler}
              error={submitted && !(blockHeight > 0) ? true : false}
              helperText={
                submitted && blockHeight === "" ? "Enter Block Height" : ""
              }
            />
          </div>
        </div>
        <div className={styles.submitSection}>
          <ButtonFill onClick={fetchHandler}>Generate QR Code</ButtonFill>
        </div>
      </div>
    </div>
  );
};

const mapStateToProps = (state) => {
  return {
    isFetch: state.encryptionKey.isFetch,
  };
};
export default connect(mapStateToProps)(EncryptionForm);
