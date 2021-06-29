import React from 'react'
import { Step } from "../Step"
import { withAppState } from "../app/State"

import { buildStepClassName } from "../../services/service.step"
import SecretSeedContent from "./secretSeedContent"
import IsDesktopWrapper from "../../utils/isDesktopWrapper"
import StepsControls from "../steps/stepsControls"

import "./secretSeed.scss"
import "../../services/service.step.scss"

class SecretSeed extends Step {
  render() {
    const { currentIndex, prevIndex, navigationIndex } = this.props
    const params = {
      className: "wrapperSecretSeed",
      currentIndex: currentIndex,
      prevStepIndex: prevIndex,
      stepIndex: navigationIndex,
    }

    return this.state.enabled ?
      <div className={buildStepClassName({ params })}>
        <SecretSeedContent />

        <IsDesktopWrapper>
          <div className="container_controlsDesktop">
            <StepsControls />
          </div>
        </IsDesktopWrapper>
      </div>
      : null
  }
}

export default withAppState(SecretSeed)
