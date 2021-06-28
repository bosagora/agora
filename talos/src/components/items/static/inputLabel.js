import React from 'react'

import styles from "./inputLabel.module.scss"

const InputLabel = props => {
  return (
    <span className={styles.inputLabel}>{props.children}</span>
  )
}

export default React.memo(InputLabel)