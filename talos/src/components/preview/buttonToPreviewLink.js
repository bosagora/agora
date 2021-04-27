import React from 'react';

import { withAppState } from "../../shared/containers/containerAppState"

import ButtonReset from "../../shared/items/controls/buttonReset"

const ButtonToPreviewLink = props => {
  const { onCloseAppOrder } = props

  return <ButtonReset onClick={onCloseAppOrder}>
    {props.children}
  </ButtonReset>
}

export default withAppState(ButtonToPreviewLink)
