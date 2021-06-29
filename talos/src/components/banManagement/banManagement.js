import React from 'react'
import { Step } from "../Step"
import { withAppState } from "../app/State"

import { buildStepClassName } from "../../services/service.step"
import BanManagementContent from "./banManagementContent"
import IsDesktopWrapper from "./../../utils/isDesktopWrapper"
import StepsControls from "./../steps/stepsControls"

import "./banManagement.scss"
import "./../../services/service.step.scss"
import variables from './../../values.module.scss'

class BanManagement extends Step {
  render() {
    const { currentIndex, prevIndex, navigationIndex } = this.props
    const params = {
      className: "wrapperBanManagement",
      currentIndex: currentIndex,
      prevStepIndex: prevIndex,
      stepIndex: navigationIndex,
    }

    return this.state.enabled ?
      <div className={buildStepClassName({ params })}>
        <BanManagementContent />

        <IsDesktopWrapper>
          <div className="container_controlsDesktop">
            <StepsControls />
          </div>
        </IsDesktopWrapper>
      </div>
      : null
  }
}

export default withAppState(BanManagement)
