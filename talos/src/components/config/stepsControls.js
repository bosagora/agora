import React from 'react';

import ButtonReset from "components/items/controls/buttonReset"
import PrevButton from "components/items/static/prevButton"
import NextStepControl from "./nextStepControl"

import styles from './stepsControls.module.scss'

const StepsControls = (props) => {
  const { currentIndex, onToNextStep, onToPrevStep } = props;

  return (
    <div className={styles.container_stepControls}>
      <div className={styles.container_prevStepButton}>
        <ButtonReset onClick={onToPrevStep}>
          <PrevButton>Previous</PrevButton>
        </ButtonReset>
        </div>
      <div className={styles.container_nextStepButton}>
        <NextStepControl currentIndex={currentIndex} onToNextStep={onToNextStep} />
      </div>
    </div>
  )
}

export default StepsControls

