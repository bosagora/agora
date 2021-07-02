import { createReducer } from 'utils/helpers';
import {
  CHANGE_NETWORK_ITEMS,
} from './Action'

const initialState = {
  stepItems: {}
}

const networkReducer = createReducer(initialState, {
  [CHANGE_NETWORK_ITEMS.REQUEST]: (state, { payload: { name, value, isTouched, isValid, validString } }) => {
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
})

export default networkReducer
