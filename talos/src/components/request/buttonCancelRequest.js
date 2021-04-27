import React from 'react';
import { withAppState } from "../../shared/containers/containerAppState"

import ButtonReset from "../../shared/items/controls/buttonReset"

const ButtonCancelRequest = props => {
  const {onRequestBegin} = props

  return <ButtonReset onClick={onRequestBegin}>
    {props.children}
  </ButtonReset>
}

export default withAppState(ButtonCancelRequest)
