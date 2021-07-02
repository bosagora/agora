import React from 'react'
import { Step } from "../Step"
import { withAppState } from "../app/State"

import { buildStepClassName } from "../../services/service.step"
import NetworkOptionsContent from "./networkOptionsContent"
import IsDesktopWrapper from "./../../utils/isDesktopWrapper"
import StepsControls from "./../steps/stepsControls"

import "./networkOptions.scss"
import "./../../services/service.step.scss"

class NetworkOptions extends Step {
  render() {
    const { currentIndex, prevIndex, navigationIndex } = this.props
    const params = {
      currentIndex: currentIndex,
      prevStepIndex: prevIndex,
      stepIndex: navigationIndex,
    }

    return this.state.enabled ?
      <div className={"wrapperNetworkOptions " + buildStepClassName({ params })}>
        <NetworkOptionsContent />

        <IsDesktopWrapper>
          <div className="container_controlsDesktop">
            <StepsControls />
          </div>
        </IsDesktopWrapper>
      </div>
      : null
  }
}

export default withAppState(NetworkOptions)
