import React from 'react';

import { withAppState } from "../steps/AppState"

import ButtonReset from "../items/controls/buttonReset"

const ButtonToPreviewLink = props => {
  const { onCloseAppOrder } = props

  return <ButtonReset onClick={onCloseAppOrder}>
    {props.children}
  </ButtonReset>
}

export default withAppState(ButtonToPreviewLink)
