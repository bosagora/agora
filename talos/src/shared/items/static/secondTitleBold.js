import React from 'react'

import styles from "./secondTitleBold.module.scss"

const SecondTitleBold = props => {
  return (
    <h2 className={styles.secondTitleBold}>{props.children}</h2>
  )
}

export default React.memo(SecondTitleBold)