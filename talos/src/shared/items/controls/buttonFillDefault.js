import React from 'react'

import styles from "./buttonFillDefault.module.scss"

const ButtonFillDefault = props => {
  const { onClick } = props

  return (
    <div
      className={styles.buttonFillDefault}
      onClick={onClick}
    >
      {props.children}
    </div>
  )
}

export default React.memo(ButtonFillDefault)