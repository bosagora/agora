import { createReducer } from '../utils/helpers';
import {
  CHANGE_BANMANAGEMENT_ITEMS,
} from '../components/banManagement/Action'

const initialState = {
  stepItems: {}
}

const banManagementReducer = createReducer(initialState, {
  [CHANGE_BANMANAGEMENT_ITEMS.REQUEST]: (state, { payload: { name, value, isTouched, isValid, validString } }) => {
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

export default banManagementReducer
