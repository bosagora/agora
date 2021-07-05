import React from 'react';

import { Frame } from 'components/Frame'
import { buildStepClassName } from 'services/service.step'
import AdminContent from "./Content"
import RequestDialog from "components/request/requestDialog"
import IsDesktopWrapper from "utils/isDesktopWrapper"
import StepsControls from "components/config/stepsControls"

import "./Wrapper.scss"
import "services/service.step.scss"

class AdminStep extends Frame {

  componentDidMount() {
      if (this.isEnabled(this.props))
          this.enable();
      else
          this.disable();
  }

  render() {
      const { currentIndex, prevIndex, navigationIndex, onToNextStep, onToPrevStep } = this.props
    const params = {
      currentIndex: currentIndex,
      prevStepIndex: prevIndex,
      stepIndex: navigationIndex,
    }

    return this.state.enabled ?
      <div className={"wrapperAdminStep " + buildStepClassName({ params })}>
        <AdminContent />

        <IsDesktopWrapper>
          <div className="container_controlsDesktop">
            <StepsControls currentIndex={currentIndex} onToNextStep={onToNextStep} onToPrevStep={onToPrevStep} />
          </div>
        </IsDesktopWrapper>

        <RequestDialog />
      </div >
      : null
  }
}

export default AdminStep;
