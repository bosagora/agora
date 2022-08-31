import {
  ENCRYPTION_KEY_SUCCESS,
  ENCRYPTION_KEY_FAILURE,
  ENCRYPTION_KEY_REQUIRED,
  ENCRYPTION_AUTH_CLEAR,
} from "../actions/encryptionKeyAction";

const defaultState = {
  qrData: {},
  isFetch: false,
};

const encryptionKeyReducer = (state = defaultState, action) => {
  switch (action.type) {
    case ENCRYPTION_KEY_REQUIRED:
      return {
        ...state,
        fetchingUpdate: true,
      };
    case ENCRYPTION_KEY_SUCCESS:
      return {
        ...state,
        fetchingUpdate: false,
        qrData: action.payload,
      };
    case ENCRYPTION_KEY_FAILURE:
      return {
        ...state,
        fetchingUpdate: false,
        faultMessage: action.payload,
      };
    case ENCRYPTION_AUTH_CLEAR:
      return {
        ...state,
        qrData: {},
      };
    default:
      return state;
  }
};

export default encryptionKeyReducer;
