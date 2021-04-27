import React from 'react'

import styles from "./paragraphTitle.module.scss"

const ParagraphTitle = props => {
  return (
    <p className={styles.paragraphTitle}>{props.children}</p>
  )
}

export default React.memo(ParagraphTitle)