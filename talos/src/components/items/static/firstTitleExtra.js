import React from 'react'

import styles from "./firstTitleExtra.module.scss"

const FirstTitleExtra = props => {
  return (
    <h1 className={styles.firstTitleExtra}>{props.children}</h1>
  )
}

export default React.memo(FirstTitleExtra)