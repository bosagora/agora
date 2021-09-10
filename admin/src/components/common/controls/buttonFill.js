import React from 'react'

import styles from "./buttonFill.module.scss"

const ButtonFill = props => {
  const { onClick } = props

  return (
    <div
      className={styles.buttonFill}
      onClick={onClick}
    >
      {props.children}
    </div>
  )
}

export default React.memo(ButtonFill)