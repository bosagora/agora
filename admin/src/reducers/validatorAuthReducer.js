import {
  VALIDATOR_AUTH_SUCCESS,
  VALIDATOR_AUTH_FAILURE,
  VALIDATOR_AUTH_REQUIRED,
  VALIDATOR_AUTH_CLEAR,
} from "../actions/validatorAuthAction";

const defaultState = {
  qrData: {},
};

const validatorAuthReducer = (state = defaultState, action) => {
  switch (action.type) {
    case VALIDATOR_AUTH_REQUIRED:
      return {
        ...state,
        fetchingUpdate: true,
      };
    case VALIDATOR_AUTH_SUCCESS:
      return {
        ...state,
        fetchingUpdate: false,
        qrData: action.payload.data,
      };
    case VALIDATOR_AUTH_FAILURE:
      return {
        ...state,
        fetchingUpdate: false,
        faultMessage: action.payload,
      };
    case VALIDATOR_AUTH_CLEAR:
      return {
        ...state,
        qrData: {},
      };
    default:
      return state;
  }
};

export default validatorAuthReducer;
