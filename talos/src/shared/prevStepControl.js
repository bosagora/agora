import React from 'react';
import { steps } from "./static.steps"

import { withStepsState } from "./containers/containerStepsState"

import ButtonToPreviewLink from "./../components/preview/buttonToPreviewLink"
import ButtonToPrevStep from "./items/controls/buttonToPrevStep"
import PrevButton from "./items/static/prevButton"

const PrevStepControl = props => {
  const { currentIndex } = props

  switch (currentIndex) {
    case steps.secretSeed:
      return <ButtonToPreviewLink>
        <PrevButton>Previous</PrevButton>
      </ButtonToPreviewLink>

    default:
      return <ButtonToPrevStep>
        <PrevButton>Previous</PrevButton>
      </ButtonToPrevStep>
  }

}

export default withStepsState(PrevStepControl)

