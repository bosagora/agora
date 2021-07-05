import React from 'react';

import IsMobileWrapper from "./../../utils/isMobileWrapper"
import IsDesktopWrapper from "./../../utils/isDesktopWrapper"
import DesktopMenuList from "./desktopMenuList"
import MobileMenuList from "./mobileMenuList"

import styles from './stepsMenuControls.module.scss'

const StepsMenuControls = (props) => {
  const { currentIndex, onToStep } = props;

  return (
    <div className={styles.stepsMenuControlsWrapper}>

      <IsMobileWrapper>
        <MobileMenuList currentIndex={currentIndex} />
      </IsMobileWrapper>

      <IsDesktopWrapper>
        <DesktopMenuList currentIndex={currentIndex} onToStep={onToStep} />
      </IsDesktopWrapper>

    </div>
  )
}

export default StepsMenuControls
