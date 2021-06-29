import React from 'react'

import Icon from "./icon"
import styles from "./prevButton.module.scss"

const PrevButton = props => {
  const { onClick } = props;

  return (
     <div
      className={styles.buttonText}
      onClick={onClick}
     >
      <div className={styles.prevButton}>
        <div className={styles.container_icon}>
          <Icon name="arrow-left" />
        </div>
        {props.children}
      </div>
    </div>
  )
}

export default React.memo(PrevButton)
