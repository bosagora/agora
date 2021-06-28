import { createReducer } from '../utils/helpers';
import {
  CHANGE_NETWORKOPTIONS_ITEMS,
} from '../components/networkOptions/Action'

const initialState = {
  stepItems: {}
}

const networkOptionsReducer = createReducer(initialState, {
  [CHANGE_NETWORKOPTIONS_ITEMS.REQUEST]: (state, { payload: { name, value, isTouched, isValid, validString } }) => {
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

export default networkOptionsReducer
