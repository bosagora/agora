import React from "react";

import Icon from "../static/icon";
import ButtonFill from "./../controls/buttonFill";

import styles from "./button.module.scss";

const Button = (props) => {
  return (
    <ButtonFill>
      <div className={styles.button}>
        {props.children}
        <div className={styles.container_icon}>
          <Icon name="arrow-right" />
        </div>
      </div>
    </ButtonFill>
  );
};

export default React.memo(Button);
