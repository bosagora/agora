import { createActionTypesOf } from '../utils/helpers';

export const TO_STEP = createActionTypesOf("TO_STEP")
export const TO_NEXT_STEP = createActionTypesOf("TO_NEXT_STEP")
export const TO_PREV_STEP = createActionTypesOf("TO_PREV_STEP")

export const toStep = (index) => ({
  type: TO_STEP.REQUEST,
  payLoad: { currentIndex: index }
})

export const toNextStep = () => ({
  type: TO_NEXT_STEP.REQUEST,
})

export const toPrevStep = () => ({
  type: TO_PREV_STEP.REQUEST,
})
