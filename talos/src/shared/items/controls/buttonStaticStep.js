import React from 'react'

import styles from "./buttonStaticStep.module.scss"

const ButtonStaticStep = props => {
  const { stepIndex, currentIndex } = props
  const isVisit = stepIndex < currentIndex
  const isActive = stepIndex === currentIndex

  return (
    <div className={isActive ? styles.buttonStaticStepActive : isVisit ? styles.buttonStaticStepVisit : styles.buttonStaticStep}>
      <div className={styles.container_content}>
        {props.children}
      </div>
    </div>
  )
}

export default React.memo(ButtonStaticStep)