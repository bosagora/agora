import { createActionTypesOf } from '../utils/helpers';

export const CHANGE_BANMANAGEMENT_ITEMS = createActionTypesOf("CHANGE_BANMANAGEMENT_ITEMS")

export const changeBanManagementItems = (name, value, isTouched) => {
  const isValid = true
  const validString = ""

  return {
    type: CHANGE_BANMANAGEMENT_ITEMS.REQUEST,
    payload: { name, value, isTouched, isValid, validString },
  }
}
