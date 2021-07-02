import { createActionTypesOf } from 'utils/helpers';
import { validatePort, validateAddress } from 'services/service.validate'

export const CHANGE_ADMIN_ITEMS = createActionTypesOf("CHANGE_ADMIN_ITEMS")
export const SET_VALID_ADMIN_ITEM = createActionTypesOf("SET_VALID_ADMIN_ITEM")

export const changeAdminItems = (name, value, isTouched) => {
  switch (name) {
    case "address": {
      const isValid = validateAddress(value)
      const validString = value.length === 0
        ? "Please fill in a valid value"
        : !isValid
          ? 'Please enter a valid value: (userinfo@  IP address ":" port )"'
          : ""

      return {
        type: CHANGE_ADMIN_ITEMS.REQUEST,
        payload: { name, value, isTouched, isValid, validString },
      }
    }
    case "port": {
      const isValid = validatePort(value) && parseInt(value) >= 1 && parseInt(value) <= 65535
      const validString = value.length === 0
        ? "Please fill in a valid value"
        : !isValid
          ? 'Please enter a valid value: 1-65535'
          : ""

      return {
        type: CHANGE_ADMIN_ITEMS.REQUEST,
        payload: { name, value, isTouched, isValid, validString },
      }
    }
    default: {
      const isValid = true
      const validString = ""

      return {
        type: CHANGE_ADMIN_ITEMS.REQUEST,
        payload: { name, value, isTouched, isValid, validString },
      }
    }
  }
}

export const setValidAdminItem = (name, validState, value) => {
  return {
    type: SET_VALID_ADMIN_ITEM.REQUEST,
    payload: { name, validState, value }
  }
}
