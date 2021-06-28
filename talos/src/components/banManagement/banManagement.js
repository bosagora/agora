import React, { Component } from 'react';
import { steps } from "./../steps/static"

import { withStepsState } from "../steps/Container"

import { isCurrentStep, buildStepClassName } from "../../services/service.step"
import BanManagementContent from "./banManagementContent"
import IsDesktopWrapper from "./../../utils/isDesktopWrapper"
import StepsControls from "./../steps/stepsControls"

import "./banManagement.scss"
import "./../../services/service.step.scss"
import variables from './../../values.module.scss'

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
