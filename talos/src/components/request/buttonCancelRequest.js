import React from 'react';
import { withAppState } from "../../containers/AppState"

import ButtonReset from "../items/controls/buttonReset"

const ButtonCancelRequest = props => {
  const {onRequestBegin} = props

  return <ButtonReset onClick={onRequestBegin}>
    {props.children}
  </ButtonReset>
}

export default withAppState(ButtonCancelRequest)
