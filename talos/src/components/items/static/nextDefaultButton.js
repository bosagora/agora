import React from 'react'

import Icon from "./icon"

import styles from "./nextDefaultButton.module.scss"

const NextDefaultButton = props => {
  return (
    <div className={styles.nextDefaultButton}>
      {props.children}
      <div className={styles.container_icon}>
        <Icon name="arrow-right" />
      </div>
    </div>
  )
}

export default React.memo(NextDefaultButton)