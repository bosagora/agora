import React from 'react'

import { withStepsState } from "../../containers/containerStepsState"

import ButtonReset from "./buttonReset"

const ButtonToStep = props => {
  const { onToStep, nextStepIndex } = props

  return (
    <ButtonReset onClick={onToStep.bind(this, nextStepIndex)}>
      {props.children}
    </ButtonReset>
  )
}

export default withStepsState(React.memo(ButtonToStep))