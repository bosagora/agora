import { createReducer } from '../utils/helpers';
import { steps } from "./../components/steps/static"

import {
  TO_STEP,
  TO_NEXT_STEP,
  TO_PREV_STEP,
  REQUEST,
} from '../components/app/Action'

export const initialState = {
  currentIndex: 0,
  prevIndex: 0,
  requestState: REQUEST.BEGIN,
  requestResult: "",
}

const appStateReducer = createReducer(initialState, {
  [TO_STEP.REQUEST]: (state, { payLoad: { currentIndex, prevIndex } }) => ({
    ...state,
    currentIndex: currentIndex,
    prevIndex: prevIndex,
  }),
  [TO_NEXT_STEP.REQUEST]: state => {
    const nextIndex = state.currentIndex + 1
    const prevIndex = state.currentIndex
    const stepsLenght = Object.keys(steps).length

    return nextIndex <= stepsLenght - 1
      ? {
        ...state,
        currentIndex: nextIndex,
        prevIndex: prevIndex,
      }
      : state
  },
  [TO_PREV_STEP.REQUEST]: state => {
    const nextIndex = state.currentIndex - 1
    const prevIndex = state.currentIndex

    return prevIndex >= 0
      ? {
        ...state,
        currentIndex: nextIndex,
        prevIndex: prevIndex,
      }
      : state
  },
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
