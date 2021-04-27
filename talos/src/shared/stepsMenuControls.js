import React from 'react';

import IsMobileWrapper from "./isMobileWrapper"
import IsDesktopWrapper from "./isDesktopWrapper"
import DesktopMenuList from "./desktopMenuList"
import MobileMenuList from "./mobileMenuList"

import styles from './stepsMenuControls.module.scss'

const StepsMenuControls = () => {
  return (
    <div className={styles.stepsMenuControlsWrapper}>

      <IsMobileWrapper>
        <MobileMenuList />
      </IsMobileWrapper>

      <IsDesktopWrapper>
        <DesktopMenuList />
      </IsDesktopWrapper>

    </div>
  )
}

export default StepsMenuControls
