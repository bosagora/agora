import React from 'react'

import styles from "./buttonText.module.scss"

const ButtonText = props => {
  const { onClick } = props

  return (
    <div
      className={styles.buttonText}
      onClick={onClick}
    >
      {props.children}
    </div>
  )
}

export default React.memo(ButtonText)