import { createActionTypesOf } from '../../utils/helpers';
import { validatSecretKey } from '../../services/service.validate'

export const CHANGE_SECRETSEED_ITEMS = createActionTypesOf("CHANGE_SECRETSEED_ITEMS")
export const SET_VALID_SECRETSEED_ITEM = createActionTypesOf("SET_VALID_SECRETSEED_ITEM")

export const changeSecretSeedItems = (name, value, isTouched) => {
  switch (name) {
    case "seed": {
      const isValid = validatSecretKey(value)
      const validString = value.length === 0
        ? "Please input your Secret Seed"
        : value.length > 0 && value.length < 56
          ? "The Secret Seed provided is too short"
          : !isValid
            ? "Invalid input value, please see the tooltip for requirements"
            : ""

      return {
        type: CHANGE_SECRETSEED_ITEMS.REQUEST,
        payload: { name, value, isTouched, isValid, validString },
      }
    }
    default: {
      const isValid = true
      const validString = ""

      return {
        type: CHANGE_SECRETSEED_ITEMS.REQUEST,
        payload: { name, value, isTouched, isValid, validString },
      }
    }
  }
}

export const setValidStateSecretSeedItem = (name, validState, value) => {
  return {
    type: SET_VALID_SECRETSEED_ITEM.REQUEST,
    payload: { name, validState, value }
  }
}
