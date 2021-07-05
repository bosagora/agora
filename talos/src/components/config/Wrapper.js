import React from 'react';

import { withAppState } from "../app/State"

import { Frame } from "../Frame"
import FirstTitle from "../items/static/firstTitle"
import Icon from "../items/static/icon"
import Paragraph from "../items/static/paragraph"
import ButtonReset from "components/items/controls/buttonReset"
import ValidatorStep from "./steps/validator/Wrapper"
import NetworkStep from "./steps/network/Wrapper"
import BanmanStep from "./steps/banman/Wrapper"
import AdminStep from "./steps/admin/Wrapper"
import StepsControls from "./stepsControls"
import StepsMenuControls from "./stepsMenuControls"
import IsMobileWrapper from "../../utils/isMobileWrapper"

import styles from './Wrapper.module.scss'

class ConfigPage extends Frame {
    //
    isDisabled (props) {
        return props.currentIndex === 0;
    }

    //
    isEnabled (props) {
        return props.currentIndex !== 0;
    }

  render() {
    const { currentIndex, prevIndex, onToStep, onToNextStep, onToPrevStep } = this.props

    return this.state.enabled
      ?
      <div className={styles.configPage + (currentIndex > 0 ? '' : ' hidden')}>
        <div className={styles.configPageInner}>
          <div className={styles.container_leftSide}>
            <div className={styles.container_title}>
              <FirstTitle>Node Config</FirstTitle>
            </div>
            <div className={styles.container_description}>
              <Paragraph>Use the following screen to configure your node</Paragraph>
            </div>

            <div className={styles.container_stepsMenu}>
              <StepsMenuControls currentIndex={currentIndex} onToStep={onToStep}/>
            </div>
            <div className={styles.container_logo}>
              <ButtonReset onClick={() => onToStep(0)}>
                <Icon name="logo" />
              </ButtonReset>
            </div>
          </div>
          <div className={styles.container_rightSide}>
            <div className={styles.container_rightSideInner}>
              <ValidatorStep navigationIndex={1} currentIndex={currentIndex} prevIndex={prevIndex} onToNextStep={onToNextStep} onToPrevStep={onToPrevStep} />
              <NetworkStep   navigationIndex={2} currentIndex={currentIndex} prevIndex={prevIndex} onToNextStep={onToNextStep} onToPrevStep={onToPrevStep} />
              <BanmanStep    navigationIndex={3} currentIndex={currentIndex} prevIndex={prevIndex} onToNextStep={onToNextStep} onToPrevStep={onToPrevStep} />
              <AdminStep     navigationIndex={4} currentIndex={currentIndex} prevIndex={prevIndex} onToNextStep={onToNextStep} onToPrevStep={onToPrevStep} />
            </div>

            <div className={styles.container_controlsMobile}>
              <div className={styles.container_controlsMobileInner}>
                <IsMobileWrapper>
                  <StepsControls currentIndex={currentIndex} onToNextStep={onToNextStep} onToPrevStep={onToPrevStep} />
                </IsMobileWrapper>
              </div>
            </div>
          </div>
        </div>
      </div>
      : null
  }
}

export default withAppState(ConfigPage)
