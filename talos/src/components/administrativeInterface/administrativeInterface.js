import React, { Component } from 'react';

import { withAppState } from "../steps/AppState"

import { Step } from "../Step"
import { isCurrentStep, buildStepClassName } from "../../services/service.step"
import AdministrativeInterfaceContent from "./administrativeInterfaceContent"
import RequestDialog from "./../request/requestDialog"
import IsDesktopWrapper from "./../../utils/isDesktopWrapper"
import StepsControls from "./../steps/stepsControls"


import "./administrativeInterface.scss"
import "./../../services/service.step.scss"
import variables from './../../values.module.scss'

class AdministrativeInterface extends Step {

  componentDidMount() {
      if (this.isEnabled(this.props))
          this.enable();
      else
          this.disable();
  }

  render() {
      const { currentIndex, prevIndex, navigationIndex } = this.props
    const params = {
      className: "wrapperAdministrativeInterface",
      currentIndex: currentIndex,
      prevStepIndex: prevIndex,
      stepIndex: navigationIndex,
    }

    return this.state.enabled ?
      <div className={buildStepClassName({ params })}>
        <AdministrativeInterfaceContent />

        <IsDesktopWrapper>
          <div className="container_controlsDesktop">
            <StepsControls />
          </div>
        </IsDesktopWrapper>

        <RequestDialog />
      </div >
      : null
  }
}

export default withAppState(AdministrativeInterface)
