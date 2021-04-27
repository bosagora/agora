import React from 'react'

import styles from "./secondTitle.module.scss"

const SecondTitle = props => {
  return (
    <h2 className={styles.secondTitle}>{props.children}</h2>
  )
}

export default React.memo(SecondTitle)