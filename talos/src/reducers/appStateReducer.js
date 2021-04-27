import { createReducer } from '../utils/helpers';
import {
  OPEN_ORDER,
  CLOSE_ORDER,
  REQUEST,
} from '../actions/appStateActions'

export const initialState = {
  isOrderOn: false,
  requestState: REQUEST.BEGIN,
  requestResult: "",
}

const appStateReducer = createReducer(initialState, {
  [OPEN_ORDER.REQUEST]: state => ({
    ...state,
    isOrderOn: true
  }),
  [CLOSE_ORDER.REQUEST]: state => ({
    ...state,
    isOrderOn: false,
    requestState: REQUEST.BEGIN,
  }),
  [REQUEST.BEGIN]: state => ({
    ...state,
    requestState: REQUEST.BEGIN,
    requestResult: "",
  }),
  [REQUEST.REQUEST]: state => ({
    ...state,
    requestState: REQUEST.REQUEST
  }),
  [REQUEST.SUCCESS]: state => ({
    ...state,
    requestState: REQUEST.SUCCESS
  }),
  [REQUEST.ERROR]: (state, data) => ({
    ...state,
    requestState: REQUEST.ERROR,
    requestResult: data,
  }),
})

export default appStateReducer
