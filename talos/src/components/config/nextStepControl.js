import React from 'react';
import { steps } from "./static"

import { withAppState } from "components/app/State"
import { withValidator } from "./steps/validator/Container"
import { withNetwork } from "./steps/network/Container"
import { withBanman } from "./steps/banman/Container"
import { withAdmin } from "./steps/admin/Container"

import ButtonToNextStep from "components/items/controls/buttonToNextStep"
import NextButton from "components/items/static/nextButton"
import ButtonRequest from "components/request/buttonRequest"

const NextStepControl = props => {
  const { currentIndex } = props

  switch (currentIndex) {
    case steps.validator:
      return <ButtonToNextStep
        items={props.validator.stepItems}
        handleChange={props.onChangeValidatorItems}
      >
        <NextButton>Next step</NextButton>
      </ButtonToNextStep>

    case steps.network:
      return <ButtonToNextStep
        items={props.network.stepItems}
        handleChange={props.onChangeNetworkItems}
      >
        <NextButton>Next step</NextButton>
      </ButtonToNextStep>

    case steps.banman:
      return <ButtonToNextStep
        items={props.banman.stepItems}
        handleChange={props.onChangeBanmanItems}
      >
        <NextButton>Next step</NextButton>
      </ButtonToNextStep >

    case steps.admin:
      return <ButtonRequest>
        <NextButton>Start</NextButton>
      </ButtonRequest>

    default:
      return null
  }

}

export default withAppState(withValidator(withNetwork(withBanman(withAdmin(NextStepControl)))))
