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

export const requestRequset = () => ({
  type: REQUEST.REQUEST
})

export const responseRequset = (data) => ({
  type: REQUEST.SUCCESS,
  data
})

export const requestFailureRequset = (data) => ({
  type: REQUEST.ERROR,
  data
})

export const request = (data) => {
  return (dispatch) => {

    dispatch(requestRequset())

    RequestService.request(data)
      .then((result) => {

        setTimeout(function () {
          dispatch(responseRequset())
        }, 2000)
      })
      .catch((error) => {

        setTimeout(function () {
          dispatch(requestFailureRequset())
        }, 2000)
      })


    // setTimeout(function () {
    //   dispatch(responseRequset())
    // }, 4000)
  }
}
