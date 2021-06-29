import React from 'react';

import { withAppState } from "../app/State"

import { Step } from "../Step"
import FirstTitle from "../items/static/firstTitle"
import Icon from "../items/static/icon"
import Paragraph from "../items/static/paragraph"
import ButtonToPreviewLink from "./../preview/buttonToPreviewLink"
import SecretSeed from "./../secretSeed/secretSeed"
import NetworkOptions from "./../networkOptions/networkOptions"
import BanManagement from "./../banManagement/banManagement"
import AdministrativeInterface from "./../administrativeInterface/administrativeInterface"
import StepsControls from "./stepsControls"
import StepsMenuControls from "./stepsMenuControls"
import IsMobileWrapper from "../../utils/isMobileWrapper"

import styles from './stepWrapper.module.scss'

class StepWrapper extends Step {
    //
    isDisabled (props) {
        return props.currentIndex === 0;
    }

    //
    isEnabled (props) {
        return props.currentIndex !== 0;
    }

  render() {
    const { currentIndex } = this.props

    return this.state.enabled
      ?
      <div className={currentIndex > 0 ? styles.stepWrapper : styles.stepWrapperHidden}>
        <div className={styles.stepWrapperInner}>
          <div className={styles.container_leftSide}>
            <div className={styles.container_title}>
              <FirstTitle>Node Config</FirstTitle>
            </div>
            <div className={styles.container_description}>
              <Paragraph>Use the following screen to configure your node</Paragraph>
            </div>

            <div className={styles.container_stepsMenu}>
              <StepsMenuControls />
            </div>
            <div className={styles.container_logo}>
              <ButtonToPreviewLink>
                <Icon name="logo" />
              </ButtonToPreviewLink>
            </div>
          </div>
          <div className={styles.container_rightSide}>
            <div className={styles.container_rightSideInner}>
              <SecretSeed navigationIndex={1} />
              <NetworkOptions navigationIndex={2} />
              <BanManagement navigationIndex={3} />
              <AdministrativeInterface navigationIndex={4} />
            </div>

            <div className={styles.container_controlsMobile}>
              <div className={styles.container_controlsMobileInner}>
                <IsMobileWrapper>
                  <StepsControls />
                </IsMobileWrapper>
              </div>
            </div>
          </div>
        </div>
      </div>
      : null
  }
}

export default withAppState(StepWrapper)
