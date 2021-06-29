import React from 'react'

import { withAppState } from "../../app/State"

import ButtonReset from "./buttonReset"

const ButtonToStep = props => {
  const { onToStep, nextStepIndex } = props

  return (
    <ButtonReset onClick={onToStep.bind(this, nextStepIndex)}>
      {props.children}
    </ButtonReset>
  )
}

export default withAppState(React.memo(ButtonToStep))
