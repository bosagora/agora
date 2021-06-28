import React from 'react'

import styles from "./firstTitle.module.scss"

const FirstTitle = props => {
  return (
    <h1 className={styles.firstTitle}>{props.children}</h1>
  )
}

export default React.memo(FirstTitle)