import React from 'react'

import styles from "./bold.module.scss"

const Bold = props => {
  return (
    <p className={styles.bold}>{props.children}</p>
  )
}

export default React.memo(Bold)