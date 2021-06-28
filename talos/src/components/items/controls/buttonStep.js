import React from 'react'

import Icon from "./../static/icon"

import styles from "./buttonStep.module.scss"

const ButtonStep = props => {
  const { stepIndex, onClick, currentIndex } = props
  const isVisit = stepIndex <= currentIndex
  const isActive = stepIndex === currentIndex

  return (
    <div
      className={isActive ? styles.buttonStepActive : isVisit ? styles.buttonStepVisit : styles.buttonStep}
      onClick={isVisit ? onClick.bind(this, stepIndex) : () => { }}
    >
      <div className={styles.container_arrow}>
        <Icon name="arrow-right" />
      </div>
      <div className={styles.container_check}>
        <Icon name="check" />
      </div>
      <div className={styles.container_content}>
        {props.children}
      </div>
    </div>
  )
}

export default React.memo(ButtonStep)