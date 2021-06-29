import React from 'react'
import { get } from "lodash"

import { withAppState } from "../../app/State"

import ButtonReset from "./buttonReset"

const ButtonToNextStep = props => {

  const handleClick = props => {
    const { onToNextStep, items, handleChange } = props
    var isValidStep = true

    Object.keys(items).map(key => {

      const item = items[key]
      if (!!item.isValid) {
        if (!item.isValid)
          isValidStep = false
      }
      else {
        isValidStep = false

        if (!get(item, ["isValid"]) && !get(item, ["isTouched"]))
          handleChange(key, get(item, ["value"]), true)
      }

      return null
    })

    if (isValidStep)
      onToNextStep()
  }

  return (
    <ButtonReset onClick={handleClick.bind(this, props)}>
      {props.children}
    </ButtonReset>
  )
}

export default withAppState(React.memo(ButtonToNextStep))
