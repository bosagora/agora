import React, { Component } from 'react';

import { steps } from "./../../shared/static.steps"

import { withStepsState } from "../../shared/containers/containerStepsState"
import { withAppState } from "../../shared/containers/containerAppState"

import { isCurrentStep, buildStepClassName } from "../../shared/services/service.step"
import AdministrativeInterfaceContent from "./administrativeInterfaceContent"
import RequestDialog from "./../request/requestDialog"
import IsDesktopWrapper from "./../../shared/isDesktopWrapper"
import StepsControls from "./../../shared/stepsControls"


import "./administrativeInterface.scss"
import "./../../shared/services/service.step.scss"
import variables from './../../values.module.scss'

var timeOut

class AdministrativeInterface extends Component {
  constructor(props) {
    super(props);

    this.state = {
      inOpenAdministrativeInterface: false,
    }
  }

  componentDidMount() {
    const { currentIndex } = this.props
    const { inOpenAdministrativeInterface } = this.state

    if (isCurrentStep(currentIndex, steps.administrativeInterface) && !inOpenAdministrativeInterface)
      this.setState({ inOpenAdministrativeInterface: true })
  }

  componentDidUpdate(prevProps) {
    const { currentIndex } = this.props
    const { inOpenAdministrativeInterface } = this.state

    if (!isCurrentStep(currentIndex, steps.administrativeInterface) && prevProps.currentIndex !== currentIndex && prevProps.currentIndex === steps.administrativeInterface) {

      clearInterval(timeOut)
      timeOut = setTimeout(function () {
        if (inOpenAdministrativeInterface)
          this.setState({
            inOpenAdministrativeInterface: false,
          })
      }.bind(this), parseFloat(variables.animateSteps) * 1000)
    }

    if (isCurrentStep(currentIndex, steps.administrativeInterface) && prevProps.currentIndex !== currentIndex) {
      clearInterval(timeOut)
      this.setState({
        inOpenAdministrativeInterface: true,
      })
    }
  }

  render() {
    const { currentIndex, prevIndex } = this.props
    const { inOpenAdministrativeInterface } = this.state
    const params = {
      className: "wrapperAdministrativeInterface",
      currentIndex: currentIndex,
      prevStepIndex: prevIndex,
      stepIndex: steps.administrativeInterface,
    }

    return inOpenAdministrativeInterface ?
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

export default withAppState(withStepsState(AdministrativeInterface))
