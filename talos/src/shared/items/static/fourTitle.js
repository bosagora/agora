import React from 'react'

import styles from "./fourTitle.module.scss"

const FourTitle = props => {
  return (
    <h4 className={styles.fourTitle}>{props.children}</h4>
  )
}

export default React.memo(FourTitle)