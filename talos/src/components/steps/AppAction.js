import { createActionTypesOf } from '../../utils/helpers';
import axios from 'axios';

export const OPEN_ORDER = createActionTypesOf("OPEN_ORDER")
export const CLOSE_ORDER = createActionTypesOf("CLOSE_ORDER")
export const REQUEST = createActionTypesOf("REQUEST")

var api = axios.create({});

export const openAppOrder = () => ({
  type: OPEN_ORDER.REQUEST,
});

export const closeAppOrder = () => ({
  type: CLOSE_ORDER.REQUEST,
});

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

        setTimeout(function () {
          dispatch(responseRequest())
        }, 2000)
      })
      .catch((error) => {
        setTimeout(function () {
          // Somehow this is a user error (e.g. bad config)
          if (error.response)
            dispatch(requestFailureRequest(error.response.data.status))
          else if (error.request)
            dispatch(requestFailureRequest("No response received from the server"))
          else
            dispatch(requestFailureRequest("Internal error (" + error.message + ")"))
        }, 2000)
      })


    // setTimeout(function () {
    //   dispatch(responseRequest())
    // }, 4000)
  }
}
