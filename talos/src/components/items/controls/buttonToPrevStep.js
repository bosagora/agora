import React from 'react'

import { withStepsState } from "./../../../containers/StepsState"

import ButtonReset from "./buttonReset"

const ButtonToPrevStep = props => {
  const { onToPrevStep } = props

  return (
    <ButtonReset onClick={onToPrevStep}>
      {props.children}
    </ButtonReset>
  )
}

export default withStepsState(React.memo(ButtonToPrevStep))
