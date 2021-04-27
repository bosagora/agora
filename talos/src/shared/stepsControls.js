import React from 'react';

import PrevStepControl from "./prevStepControl"
import NextStepControl from "./nextStepControl"

import styles from './stepsControls.module.scss'

const StepsControls = () => {
  return (
    <div className={styles.container_stepControls}>
      <div className={styles.container_prevStepButton}>
        <PrevStepControl />
      </div>
      <div className={styles.container_nextStepButton}>
        <NextStepControl />
      </div>
    </div>
  )
}

export default StepsControls

