import React from 'react'

import { withAppState } from "../../steps/AppState"

import ButtonReset from "./buttonReset"

const ButtonToPrevStep = props => {
  const { onToPrevStep } = props

  return (
    <ButtonReset onClick={onToPrevStep}>
      {props.children}
    </ButtonReset>
  )
}

export default withAppState(React.memo(ButtonToPrevStep))
