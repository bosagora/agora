import React from 'react';
import { steps } from "./static.steps"

import { withStepsState } from "./containers/containerStepsState"

import ButtonStep from "./items/controls/buttonStep"

import styles from './desktopMenuList.module.scss'

const DesktopMenuList = props => {
  const { currentIndex, onToStep } = props

  return (
    <div className={styles.desktopMenuControls} >
      <div className={styles.desktopItemWrapper}>
        <ButtonStep currentIndex={currentIndex} stepIndex={steps.secretSeed} onClick={onToStep}>Secret Seed</ButtonStep>
      </div>

      <div className={styles.desktopItemWrapper}>
        <ButtonStep currentIndex={currentIndex} stepIndex={steps.networkOptions} onClick={onToStep}>Network Options</ButtonStep>
      </div>

      <div className={styles.desktopItemWrapper}>
        <ButtonStep currentIndex={currentIndex} stepIndex={steps.banManagement} onClick={onToStep}>Ban Management</ButtonStep>
      </div>

      <div className={styles.desktopItemWrapper}>
        <ButtonStep currentIndex={currentIndex} stepIndex={steps.administrativeInterface} onClick={onToStep}>Administrative Interface</ButtonStep>
      </div>
    </div>
  )
}

export default withStepsState(DesktopMenuList)
