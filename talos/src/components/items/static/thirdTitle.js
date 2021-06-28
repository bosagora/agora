import React from 'react'

import styles from "./thirdTitle.module.scss"

const ThirdTitle = props => {
  return (
    <h3 className={styles.thirdTitle}>{props.children}</h3>
  )
}

export default React.memo(ThirdTitle)