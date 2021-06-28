import React from 'react'

import styles from "./popoverContent.module.scss"

const PopoverContent = props => {
  return (
    <div className={styles.popoverContent}>{props.children}</div>
  )
}

export default React.memo(PopoverContent)