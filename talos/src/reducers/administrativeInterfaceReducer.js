import { createReducer } from '../utils/helpers';
import { has } from "lodash"
import {
  CHANGE_ADMINISTRATIVEINTERFACE_ITEMS,
  SET_VALID_ADMINISTRATIVEINTERFACE_ITEM,
} from '../components/administrativeInterface/Action'

const initialState = {
  stepItems: {}
}

const administrativeInterfaceReducer = createReducer(initialState, {
  [CHANGE_ADMINISTRATIVEINTERFACE_ITEMS.REQUEST]: (state, { payload: { name, value, isTouched, isValid, validString } }) => {
    var nextStepItems = { ...state.stepItems }

    nextStepItems[name] = {
      value,
      isTouched,
      isValid,
      validString,
    }

    return {
      ...state,
      stepItems: nextStepItems,
    }
  },
  [SET_VALID_ADMINISTRATIVEINTERFACE_ITEM.REQUEST]: (state, { payload: { name, validState, value } }) => {
    var nextStepItems = { ...state.stepItems }

    nextStepItems[name] = has(nextStepItems, [name])
      ? {
        ...nextStepItems[name],
        isValid: validState,
        validString: "",
        value: value,
      }
      : {
        isTouched: true,
        isValid: validState,
        value: value,
        validString: "",
      }

    return {
      ...state,
      stepItems: nextStepItems,
    }
  },
})

export default administrativeInterfaceReducer
