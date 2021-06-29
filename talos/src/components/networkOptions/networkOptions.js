import React from 'react'
import { Step } from "../Step"
import { withAppState } from "../steps/AppState"

import { buildStepClassName } from "../../services/service.step"
import NetworkOptionsContent from "./networkOptionsContent"
import IsDesktopWrapper from "./../../utils/isDesktopWrapper"
import StepsControls from "./../steps/stepsControls"

import "./networkOptions.scss"
import "./../../services/service.step.scss"
import variables from './../../values.module.scss'

class NetworkOptions extends Step {
  render() {
    const { currentIndex, prevIndex, navigationIndex } = this.props
    const params = {
      className: "wrapperNetworkOptions",
      currentIndex: currentIndex,
      prevStepIndex: prevIndex,
      stepIndex: navigationIndex,
    }

    return this.state.enabled ?
      <div className={buildStepClassName({ params })}>
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
