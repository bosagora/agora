import React, { Component } from 'react';
import { steps } from "../steps/static"

import { withAppState } from "../steps/AppState"

import { isCurrentStep, buildStepClassName } from "../../services/service.step"
import SecretSeedContent from "./secretSeedContent"
import IsDesktopWrapper from "../../utils/isDesktopWrapper"
import StepsControls from "../steps/stepsControls"

import "./secretSeed.scss"
import "../../services/service.step.scss"
import variables from './../../values.module.scss'

var timeOut

class SecretSeed extends Component {
  constructor(props) {
    super(props);

    this.state = {
      isOpenSeed: false,
    }
  }

  componentDidMount() {
    const { currentIndex } = this.props
    const { isOpenSeed } = this.state

    if (isCurrentStep(currentIndex, steps.secretSeed) && !isOpenSeed)
      this.setState({ isOpenSeed: true })
  }

  componentDidUpdate(prevProps) {
    const { currentIndex } = this.props
    const { isOpenSeed } = this.state

    if (!isCurrentStep(currentIndex, steps.secretSeed) && prevProps.currentIndex !== currentIndex && prevProps.currentIndex === steps.secretSeed) {

      clearInterval(timeOut)
      timeOut = setTimeout(function () {
        if (isOpenSeed)
          this.setState({
            isOpenSeed: false,
          })
      }.bind(this), parseFloat(variables.animateSteps) * 1000)
    }

    if (isCurrentStep(currentIndex, steps.secretSeed) && prevProps.currentIndex !== currentIndex) {

      clearInterval(timeOut)
      this.setState({
        isOpenSeed: true,
      })
    }
  }

  render() {
    const { currentIndex, prevIndex } = this.props
    const { isOpenSeed } = this.state
    const params = {
      className: "wrapperSecretSeed",
      currentIndex: currentIndex,
      prevStepIndex: prevIndex,
      stepIndex: steps.secretSeed,
    }

    return isOpenSeed ?
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
