import { createActionTypesOf } from '../utils/helpers';
import { RequestService } from "./../shared/services/requestService"

export const OPEN_ORDER = createActionTypesOf("OPEN_ORDER")
export const CLOSE_ORDER = createActionTypesOf("CLOSE_ORDER")
export const REQUEST = createActionTypesOf("REQUEST")

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

    RequestService.request(data)
      .then((result) => {

        setTimeout(function () {
          dispatch(responseRequest())
        }, 2000)
      })
      .catch((error) => {

        setTimeout(function () {
          dispatch(requestFailureRequest())
        }, 2000)
      })


    // setTimeout(function () {
    //   dispatch(responseRequest())
    // }, 4000)
  }
}
