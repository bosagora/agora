import React from 'react';
import { steps } from "./static"

import { withAppState } from "components/app/State"

import ButtonToPreviewLink from "components/intro/buttonToPreviewLink"
import ButtonToPrevStep from "components/items/controls/buttonToPrevStep"
import PrevButton from "components/items/static/prevButton"

const PrevStepControl = props => {
  const { currentIndex } = props

  switch (currentIndex) {
    case steps.validator:
      return <ButtonToPreviewLink>
        <PrevButton>Previous</PrevButton>
      </ButtonToPreviewLink>

    default:
      return <ButtonToPrevStep>
        <PrevButton>Previous</PrevButton>
      </ButtonToPrevStep>
  }

}

export default withAppState(PrevStepControl)
