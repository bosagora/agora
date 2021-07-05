import React from 'react'

import { Frame } from "components/Frame"
import { buildStepClassName } from 'services/service.step'
import BanmanContent from "./Content"
import IsDesktopWrapper from "utils/isDesktopWrapper"
import StepsControls from "components/config/stepsControls"

import "./Wrapper.scss"
import "services/service.step.scss"

class BanmanStep extends Frame {
  render() {
    const { currentIndex, prevIndex, navigationIndex, onToNextStep, onToPrevStep } = this.props
    const params = {
      currentIndex: currentIndex,
      prevStepIndex: prevIndex,
      stepIndex: navigationIndex,
    }

    return this.state.enabled ?
      <div className={"wrapperBanmanStep " + buildStepClassName({ params })}>
        <BanmanContent />

        <IsDesktopWrapper>
          <div className="container_controlsDesktop">
            <StepsControls currentIndex={currentIndex} onToNextStep={onToNextStep} onToPrevStep={onToPrevStep} />
          </div>
        </IsDesktopWrapper>
      </div>
      : null
  }
}

export default BanmanStep;
