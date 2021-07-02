import { createReducer } from 'utils/helpers';
import {
  CHANGE_BANMAN_ITEMS,
} from './Action'

const initialState = {
  stepItems: {}
}

const banmanReducer = createReducer(initialState, {
  [CHANGE_BANMAN_ITEMS.REQUEST]: (state, { payload: { name, value, isTouched, isValid, validString } }) => {
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

export default banmanReducer
