import React from 'react'

import styles from "./loader.module.scss"

const Loader = () => {
  return (
    <span className={styles.loader}>
      <span className={styles.backRound}>
        <span className={styles.dotRound} />
      </span>
      <span className={styles.shadow} />
    </span>
  )
}

export default React.memo(Loader)