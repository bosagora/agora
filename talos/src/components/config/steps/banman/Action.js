import { createActionTypesOf } from 'utils/helpers';

export const CHANGE_BANMAN_ITEMS = createActionTypesOf("CHANGE_BANMAN_ITEMS")

export const changeBanmanItems = (name, value, isTouched) => {
  const isValid = true
  const validString = ""

  return {
    type: CHANGE_BANMAN_ITEMS.REQUEST,
    payload: { name, value, isTouched, isValid, validString },
  }
}
