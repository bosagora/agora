import React from 'react';
import { steps } from "./static"

import { withAppState } from "components/app/State"

import ButtonStep from "components/items/controls/buttonStep"

import styles from './desktopMenuList.module.scss'

const DesktopMenuList = props => {
  const { currentIndex, onToStep } = props

  return (
    <div className={styles.desktopMenuControls} >
      <div className={styles.desktopItemWrapper}>
        <ButtonStep currentIndex={currentIndex} stepIndex={steps.validator} onClick={onToStep}>Secret Seed</ButtonStep>
      </div>

      <div className={styles.desktopItemWrapper}>
        <ButtonStep currentIndex={currentIndex} stepIndex={steps.network} onClick={onToStep}>Network Options</ButtonStep>
      </div>

      <div className={styles.desktopItemWrapper}>
        <ButtonStep currentIndex={currentIndex} stepIndex={steps.banman} onClick={onToStep}>Ban Management</ButtonStep>
      </div>

      <div className={styles.desktopItemWrapper}>
        <ButtonStep currentIndex={currentIndex} stepIndex={steps.admin} onClick={onToStep}>Administrative Interface</ButtonStep>
      </div>
    </div>
  )
}

export default withAppState(DesktopMenuList)
