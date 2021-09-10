import IntegrationService from "../services/integration.service";

export const VALIDATOR_AUTH_REQUIRED = "VALIDATOR_AUTH_REQUIRED";
export const VALIDATOR_AUTH_SUCCESS = "VALIDATOR_AUTH_SUCCESS";
export const VALIDATOR_AUTH_FAILURE = "VALIDATOR_AUTH_FAILURE";
export const VALIDATOR_AUTH_CLEAR = "VALIDATOR_AUTH_CLEAR";

export const validatorAuth = () => (dispatch) => {
  dispatch({ type: VALIDATOR_AUTH_REQUIRED });
  return IntegrationService.validatorAuth().then(
    (data) => {
      if (data.status === 200) {
        dispatch({
          type: VALIDATOR_AUTH_SUCCESS,
          payload: { ...data },
        });
      } else {
        dispatch({
          type: VALIDATOR_AUTH_FAILURE,
          payload: { ...data },
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
        type: VALIDATOR_AUTH_FAILURE,
        payload: message,
      });
      return Promise.reject();
    }
  );
};

export const clearValidator = () => (dispatch) => {
  dispatch({
    type: VALIDATOR_AUTH_CLEAR,
  });
};
