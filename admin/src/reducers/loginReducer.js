import {
  LOGIN_REQUEST,
  LOGIN_SUCCESS,
  LOGIN_FAILURE,
  LOGOUT,
} from "../actions/loginAction";

const token = sessionStorage.getItem("token");

const defaultState = token
  ? {
      isLoggedIn: true,
      fetchingUpdate: false,
      login: {},
      faultMessage: "",
    }
  : {
      isLoggedIn: false,
      fetchingUpdate: false,
      login: {},
      faultMessage: "",
    };

const loginReducer = (state = defaultState, action) => {
  switch (action.type) {
    case LOGIN_REQUEST:
      return {
        ...state,
        fetchingUpdate: true,
      };
    case LOGIN_SUCCESS:
      return {
        ...state,
        fetchingUpdate: false,
        isLoggedIn: true,
        login: action.payload.login,
        faultMessage: action.faultMessage,
      };
    case LOGIN_FAILURE:
      return {
        ...state,
        fetchingUpdate: false,
        faultMessage: action.faultMessage,
      };
    case LOGOUT:
      return {
        ...state,
        fetchingUpdate: false,
        isLoggedIn: false,
        login: {},
        faultMessage: "",
      };
    default:
      return state;
  }
};

export default loginReducer;
