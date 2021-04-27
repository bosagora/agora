import React, { Component } from 'react';
import { steps } from "./../../shared/static.steps"

import { withStepsState } from "./../../shared/containers/containerStepsState"

import { isCurrentStep, buildStepClassName } from "../../shared/services/service.step"
import NetworkOptionsContent from "./networkOptionsContent"
import IsDesktopWrapper from "./../../shared/isDesktopWrapper"
import StepsControls from "./../../shared/stepsControls"

import "./networkOptions.scss"
import "./../../shared/services/service.step.scss"
import variables from './../../values.scss'

var timeOut

class NetworkOptions extends Component {
  constructor(props) {
    super(props);

    this.state = {
      isOpenNetwork: false,
    }
  }

  componentDidMount() {
    const { currentIndex } = this.props
    const { isOpenNetwork } = this.state

    if (isCurrentStep(currentIndex, steps.networkOptions) && !isOpenNetwork)
      this.setState({ isOpenNetwork: true })
  }

  componentDidUpdate(prevProps) {
    const { currentIndex } = this.props
    const { isOpenNetwork } = this.state

    if (!isCurrentStep(currentIndex, steps.networkOptions) && prevProps.currentIndex !== currentIndex && prevProps.currentIndex === steps.networkOptions) {

      clearInterval(timeOut)
      timeOut = setTimeout(function () {
        if (isOpenNetwork)
          this.setState({
            isOpenNetwork: false,
          })
      }.bind(this), parseFloat(variables.animateSteps) * 1000)
    }

    if (isCurrentStep(currentIndex, steps.networkOptions) && prevProps.currentIndex !== currentIndex) {
      clearInterval(timeOut)
      this.setState({
        isOpenNetwork: true,
      })
    }
  }

  render() {
    const { currentIndex, prevIndex } = this.props
    const { isOpenNetwork } = this.state
    const params = {
      className: "wrapperNetworkOptions",
      currentIndex: currentIndex,
      prevStepIndex: prevIndex,
      stepIndex: steps.networkOptions,
    }

    return isOpenNetwork ?
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

export default withStepsState(NetworkOptions)
