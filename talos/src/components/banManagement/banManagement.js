import React, { Component } from 'react';
import { steps } from "./../../shared/static.steps"

import { withStepsState } from "../../shared/containers/containerStepsState"

import { isCurrentStep, buildStepClassName } from "../../shared/services/service.step"
import BanManagementContent from "./banManagementContent"
import IsDesktopWrapper from "./../../shared/isDesktopWrapper"
import StepsControls from "./../../shared/stepsControls"

import "./banManagement.scss"
import "./../../shared/services/service.step.scss"
import variables from './../../values.scss'

var timeOut

class BanManagement extends Component {
  constructor(props) {
    super(props);

    this.state = {
      inOpenBanManagement: false,
    }
  }

  componentDidMount() {
    const { currentIndex } = this.props
    const { inOpenBanManagement } = this.state

    if (isCurrentStep(currentIndex, steps.banManagement) && !inOpenBanManagement)
      this.setState({ inOpenBanManagement: true })
  }

  componentDidUpdate(prevProps) {
    const { currentIndex } = this.props
    const { inOpenBanManagement } = this.state

    if (!isCurrentStep(currentIndex, steps.banManagement) && prevProps.currentIndex !== currentIndex && prevProps.currentIndex === steps.banManagement) {

      clearInterval(timeOut)
      timeOut = setTimeout(function () {
        if (inOpenBanManagement)
          this.setState({
            inOpenBanManagement: false,
          })
      }.bind(this), parseFloat(variables.animateSteps) * 1000)
    }

    if (isCurrentStep(currentIndex, steps.banManagement) && prevProps.currentIndex !== currentIndex) {
      clearInterval(timeOut)
      this.setState({
        inOpenBanManagement: true,
      })
    }
  }

  render() {
    const { currentIndex, prevIndex } = this.props
    const { inOpenBanManagement } = this.state
    const params = {
      className: "wrapperBanManagement",
      currentIndex: currentIndex,
      prevStepIndex: prevIndex,
      stepIndex: steps.banManagement,
    }

    return inOpenBanManagement ?
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

export default withStepsState(BanManagement)
