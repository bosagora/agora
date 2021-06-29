/**
 * The Button at the bottom left part of the screen (on desktop),
 * that will take the user back to the "preview" screen when clicked.
 */
import React from 'react';

import { withAppState } from "../steps/AppState"

import ButtonReset from "../items/controls/buttonReset"

const ButtonToPreviewLink = props => {
  const { onToStep } = props

  return <ButtonReset onClick={() => onToStep(0)}>
    {props.children}
  </ButtonReset>
}

export default withAppState(ButtonToPreviewLink)
