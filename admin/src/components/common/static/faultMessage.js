import React from "react";

import styles from "./faultMessage.module.scss";

const FaultMessage = (props) => {
  return <p className={styles.message}>{props.message}</p>;
};

export default React.memo(FaultMessage);
