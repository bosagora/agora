import React from "react";

import styles from "./menuTitle.module.scss";

const MenuTitle = (props) => {
  return <h2 className={styles.menuTitle}>{props.children}</h2>;
};

export default React.memo(MenuTitle);
