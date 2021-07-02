import { createActionTypesOf } from '../../utils/helpers';
import axios from 'axios';

var api = axios.create({});

export const REQUEST = createActionTypesOf("REQUEST")

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

export const requestBegin = () => ({
  type: REQUEST.BEGIN
})

export const requestRequest = () => ({
  type: REQUEST.REQUEST
})

export const responseRequest = (data) => ({
  type: REQUEST.SUCCESS,
  data
})

export const requestFailureRequest = (data) => ({
  type: REQUEST.ERROR,
  data
})

export const request = (data) => {
  return (dispatch) => {

    dispatch(requestRequest())

    api.post('/writeConfig', data)
      .then((result) => {
        dispatch(responseRequest())
      })
      .catch((error) => {
        // Somehow this is a user error (e.g. bad config)
        if (error.response)
          dispatch(requestFailureRequest(error.response.data.status))
        else if (error.request)
          dispatch(requestFailureRequest("No response received from the server"))
        else
          dispatch(requestFailureRequest("Internal error (" + error.message + ")"))
      })
  }
}
