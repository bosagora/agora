import React from 'react'

import styles from "./paragraph.module.scss"

const Paragraph = props => {
  return (
    <p className={styles.paragraph}>{props.children}</p>
  )
}

export default React.memo(Paragraph)