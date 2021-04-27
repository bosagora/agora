import React from 'react'

import Icon from "./../static/icon"

import styles from "./popoverButton.module.scss"

const PopoverButton = props => {
  const { onClick } = props

  return (
    <div
      className={styles.popoverButton}
      onClick={onClick}
    >
      <div className={styles.container_popoverIcon}>
        <Icon name="question" />
      </div>
    </div>
  )
}

export default React.memo(PopoverButton)