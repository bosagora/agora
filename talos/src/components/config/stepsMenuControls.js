import React from 'react';

import IsMobileWrapper from "./../../utils/isMobileWrapper"
import IsDesktopWrapper from "./../../utils/isDesktopWrapper"
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
