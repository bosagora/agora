import React from 'react'

import styles from "./paragraphSmall.module.scss"

const ParagraphSmall = props => {
  return (
    <p className={styles.paragraphSmall}>{props.children}</p>
  )
}

export default React.memo(ParagraphSmall)