import React from 'react'

import styles from "./buttonReset.module.scss"

const ButtonReset = props => {
  const { onClick } = props

  return (
    <div
      className={styles.buttonReset}
      onClick={onClick}
    >
      {props.children}
    </div>
  )
}

export default React.memo(ButtonReset)