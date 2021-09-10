import LoginService from "../services/login.service";

export const LOGIN = "LOGIN";
export const LOGIN_SUCCESS = "LOGIN_SUCCESS";
export const LOGIN_FAILURE = "LOGIN_FAILURE";
export const LOGIN_REQUEST = "LOGIN_REQUEST";
export const LOGOUT = "LOGOUT";
export const SET_MESSAGE = "SET_MESSAGE";

export const login = (username, password) => (dispatch) => {
  dispatch({ type: LOGIN_REQUEST });
  return LoginService.login(username, password).then(
    (data) => {
      if (data.status === 0) {
        dispatch({
          type: LOGIN_SUCCESS,
          payload: { login: data },
          isLoggedIn: true,
          faultMessage: "SUCCESS",
        });
      } else if (data.status === 1) {
        dispatch({
          type: LOGIN_FAILURE,
          faultMessage: "We cannot find an account.",
        });
      } else if (data.status === 2) {
        dispatch({
          type: LOGIN_FAILURE,
          faultMessage: "The password is incorrect.",
        });
      } else {
        dispatch({
          type: LOGIN_FAILURE,
          faultMessage: "Login Failed.",
        });
      }

      return Promise.resolve();
    },
    (error) => {
      const message =
        (error.response &&
          error.response.data &&
          error.response.data.message) ||
        error.message ||
        error.toString();

      dispatch({
        type: LOGIN_FAILURE,
        faultMessage: message,
      });

      dispatch({
        type: SET_MESSAGE,
        payload: message,
      });

      return Promise.reject();
    }
  );
};

export const logout = () => (dispatch) => {
  // LoginService.logout();
  sessionStorage.removeItem("token");
  dispatch({
    type: LOGOUT,
  });
};
