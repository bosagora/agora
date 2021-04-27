import { createReducer } from '../utils/helpers';
import { steps } from "./../shared/static.steps"
import {
  TO_STEP,
  TO_NEXT_STEP,
  TO_PREV_STEP,
} from '../actions/stepsStateActions'

const initialState = {
  currentIndex: 0,
  prevIndex: 0,
}

const stepsStateReducer = createReducer(initialState, {
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
})

export default stepsStateReducer
