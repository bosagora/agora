import { createActionTypesOf } from 'utils/helpers';
import { validateSecretKey } from 'services/service.validate'

export const CHANGE_VALIDATOR_ITEMS = createActionTypesOf("CHANGE_VALIDATOR_ITEMS")
export const SET_VALID_VALIDATOR_ITEM = createActionTypesOf("SET_VALID_VALIDATOR_ITEM")

export const changeValidatorItems = (name, value, isTouched) => {
  switch (name) {
    case "seed": {
      const isValid = validateSecretKey(value)
      const validString = value.length === 0
        ? "Please input your Secret Seed"
        : value.length > 0 && value.length < 56
          ? "The Secret Seed provided is too short"
          : !isValid
            ? "Invalid input value, please see the tooltip for requirements"
            : ""

      return {
        type: CHANGE_VALIDATOR_ITEMS.REQUEST,
        payload: { name, value, isTouched, isValid, validString },
      }
    }
    default: {
      const isValid = true
      const validString = ""

      return {
        type: CHANGE_VALIDATOR_ITEMS.REQUEST,
        payload: { name, value, isTouched, isValid, validString },
      }
    }
  }
}

export const setValidStateValidatorItem = (name, validState, value) => {
  return {
    type: SET_VALID_VALIDATOR_ITEM.REQUEST,
    payload: { name, validState, value }
  }
}
